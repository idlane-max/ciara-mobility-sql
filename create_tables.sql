-- ============================================================
-- 1. NETTOYAGE PRÉALABLE (DROP)
-- On supprime les tables dans l'ordre inverse des dépendances
-- ============================================================
DROP TABLE IF EXISTS IMPORT_CSV CASCADE; -- Au cas où la table temporaire existe
DROP TABLE IF EXISTS INTERVENTION CASCADE;
DROP TABLE IF EXISTS PAIEMENT CASCADE;
DROP TABLE IF EXISTS LOCATION CASCADE;
DROP TABLE IF EXISTS RESERVATION CASCADE;
DROP TABLE IF EXISTS BORNE_DE_RECHARGE CASCADE;
DROP TABLE IF EXISTS VEHICULE CASCADE;
DROP TABLE IF EXISTS TYPE_VEHICULE CASCADE;
DROP TABLE IF EXISTS STATION CASCADE;
DROP TABLE IF EXISTS TECHNICIEN CASCADE;
DROP TABLE IF EXISTS CLIENT CASCADE;

-- ============================================================
-- 2. CRÉATION DES TABLES DE RÉFÉRENCE
-- ============================================================

-- Table CLIENT
CREATE TABLE CLIENT (
    id_client SERIAL PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    prenom VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL, -- Contrainte d'unicité
    telephone VARCHAR(20),
    date_inscription DATE DEFAULT CURRENT_DATE
);

-- Table TECHNICIEN
CREATE TABLE TECHNICIEN (
    id_technicien SERIAL PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    specialite VARCHAR(50), -- Ex: Electricité, Pneu...
    disponibilite BOOLEAN DEFAULT TRUE
);

-- Table STATION (Lieu de stockage)
CREATE TABLE STATION (
    id_station SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL, -- Ex: "Station Paris Gare de Lyon"
    adresse VARCHAR(255) DEFAULT 'Adresse inconnue',
    ville VARCHAR(50),
    latitude DECIMAL(9, 6), -- Précision GPS
    longitude DECIMAL(9, 6)
);

-- Table TYPE_VEHICULE (Le catalogue)
-- Mise à jour pour correspondre au CSV (Marque/Modèle séparés)
CREATE TABLE TYPE_VEHICULE (
    id_type SERIAL PRIMARY KEY,
    marque VARCHAR(50) NOT NULL,    -- Ex: Kia
    modele VARCHAR(50) NOT NULL,    -- Ex: EV6
    energie VARCHAR(30) DEFAULT 'Electrique',
    libelle VARCHAR(100),           -- Ex: "Kia EV6" (Concaténation)
    prix_minute DECIMAL(5, 2) NOT NULL CHECK (prix_minute > 0),
    CONSTRAINT uk_type_modele UNIQUE (marque, modele) -- On évite les doublons de modèles
);

-- ============================================================
-- 3. CRÉATION DES TABLES PRINCIPALES (Avec Clés Étrangères)
-- ============================================================

-- Table VEHICULE (L'objet physique)
CREATE TABLE VEHICULE (
    id_vehicule SERIAL PRIMARY KEY,
    matricule VARCHAR(20) UNIQUE,   -- Plaque d'immatriculation (CSV)
    annee INT,                      -- Année du modèle (CSV)
    autonomie INT CHECK (autonomie >= 0), -- En km (CSV), doit être positif
    statut VARCHAR(20) DEFAULT 'DISPONIBLE' CHECK (statut IN ('DISPONIBLE', 'LOUE', 'MAINTENANCE', 'EN_CHARGE')),
    
    -- Clés Étrangères
    id_type INT NOT NULL REFERENCES TYPE_VEHICULE(id_type),
    id_station INT REFERENCES STATION(id_station) -- Peut être NULL si le véhicule roule
);

-- Table BORNE_DE_RECHARGE (Infrastructure)
CREATE TABLE BORNE_DE_RECHARGE (
    id_borne SERIAL PRIMARY KEY,
    puissance INT CHECK (puissance > 0), -- En kW
    statut VARCHAR(20) DEFAULT 'FONCTIONNEL',
    id_station INT NOT NULL REFERENCES STATION(id_station) ON DELETE CASCADE
);

-- ============================================================
-- 4. CRÉATION DES TABLES DE FLUX (Transactions)
-- ============================================================

-- Table RESERVATION
CREATE TABLE RESERVATION (
    id_reservation SERIAL PRIMARY KEY,
    date_reservation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_debut_prevue TIMESTAMP NOT NULL,
    date_fin_prevue TIMESTAMP NOT NULL,
    statut VARCHAR(20) DEFAULT 'CONFIRMEE',
    
    id_client INT NOT NULL REFERENCES CLIENT(id_client),
    id_vehicule INT NOT NULL REFERENCES VEHICULE(id_vehicule),
    
    CHECK (date_fin_prevue > date_debut_prevue) -- Cohérence des dates
);

-- Table LOCATION (Le trajet réel)
CREATE TABLE LOCATION (
    id_location SERIAL PRIMARY KEY,
    date_debut TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_fin TIMESTAMP, -- Null tant que la location n'est pas finie
    kilometrage INT DEFAULT 0,
    statut VARCHAR(20) DEFAULT 'EN_COURS',
    
    id_client INT NOT NULL REFERENCES CLIENT(id_client),
    id_vehicule INT NOT NULL REFERENCES VEHICULE(id_vehicule)
);

-- Table PAIEMENT
CREATE TABLE PAIEMENT (
    id_paiement SERIAL PRIMARY KEY,
    montant_paiement DECIMAL(10, 2) NOT NULL CHECK (montant_paiement >= 0),
    date_paiement TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    moyen_paiement VARCHAR(50),
    statut_paiement VARCHAR(20) DEFAULT 'VALIDE',
    
    id_location INT NOT NULL REFERENCES LOCATION(id_location)
);

-- Table INTERVENTION (Maintenance)
CREATE TABLE INTERVENTION (
    id_intervention SERIAL PRIMARY KEY,
    date_intervention DATE DEFAULT CURRENT_DATE,
    type_intervention VARCHAR(100),
    commentaire TEXT,
    cout_intervention DECIMAL(10, 2),
    
    id_technicien INT NOT NULL REFERENCES TECHNICIEN(id_technicien),
    id_vehicule INT NOT NULL REFERENCES VEHICULE(id_vehicule)
);

-- ============================================================
-- 5. PRÉPARATION POUR L'IMPORT CSV (Table Temporaire)
-- ============================================================
-- Exécute cette partie pour préparer l'importation de ton fichier
CREATE TABLE IMPORT_CSV (
    id INT, 
    marque VARCHAR(50),
    modele VARCHAR(50),
    annee INT,
    energie VARCHAR(50),
    autonomie_km INT,
    immatriculation VARCHAR(20),
    etat VARCHAR(50),
    localisation VARCHAR(50)
);