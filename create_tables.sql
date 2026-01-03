-- ================================
-- Projet cIAra Mobility
-- Création des tables PostgreSQL
-- ================================

-- ====================
-- TABLE : client
-- ====================
CREATE TABLE client (
    id_client SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    telephone VARCHAR(20),
    date_inscription DATE NOT NULL DEFAULT CURRENT_DATE
);

-- ====================
-- TABLE : technicien
-- ====================
CREATE TABLE technicien (
    id_technicien SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL
);

-- ====================
-- TABLE : station
-- ====================
CREATE TABLE station (
    id_station SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    adresse TEXT NOT NULL,
    ville VARCHAR(100) NOT NULL
);

-- ====================
-- TABLE : borne
-- ====================
CREATE TABLE borne (
    id_borne SERIAL PRIMARY KEY,
    id_station INT NOT NULL,
    statut VARCHAR(20) NOT NULL CHECK (statut IN ('libre', 'occupee', 'hors_service')),
    CONSTRAINT fk_borne_station
        FOREIGN KEY (id_station)
        REFERENCES station(id_station)
        ON DELETE CASCADE
);

-- ====================
-- TABLE : vehicule
-- ====================
CREATE TABLE vehicule (
    id_vehicule SERIAL PRIMARY KEY,
    type VARCHAR(20) NOT NULL CHECK (type IN ('voiture', 'velo', 'scooter', 'trottinette')),
    marque VARCHAR(50),
    modele VARCHAR(50),
    autonomie_km INT CHECK (autonomie_km > 0),
    statut VARCHAR(20) NOT NULL CHECK (statut IN ('disponible', 'reserve', 'loue', 'maintenance')),
    id_station INT,
    CONSTRAINT fk_vehicule_station
        FOREIGN KEY (id_station)
        REFERENCES station(id_station)
        ON DELETE SET NULL
);

-- ====================
-- TABLE : reservation
-- ====================
CREATE TABLE reservation (
    id_reservation SERIAL PRIMARY KEY,
    id_client INT NOT NULL,
    id_vehicule INT NOT NULL,
    date_reservation TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    debut TIMESTAMP NOT NULL,
    fin TIMESTAMP NOT NULL,
    CONSTRAINT fk_reservation_client
        FOREIGN KEY (id_client)
        REFERENCES client(id_client)
        ON DELETE CASCADE,
    CONSTRAINT fk_reservation_vehicule
        FOREIGN KEY (id_vehicule)
        REFERENCES vehicule(id_vehicule)
        ON DELETE CASCADE
);

-- ====================
-- TABLE : location
-- ====================
CREATE TABLE location (
    id_location SERIAL PRIMARY KEY,
    id_client INT NOT NULL,
    id_vehicule INT NOT NULL,
    debut TIMESTAMP NOT NULL,
    fin TIMESTAMP,
    cout_total NUMERIC(8,2),
    CONSTRAINT fk_location_client
        FOREIGN KEY (id_client)
        REFERENCES client(id_client),
    CONSTRAINT fk_location_vehicule
        FOREIGN KEY (id_vehicule)
        REFERENCES vehicule(id_vehicule)
);

-- ====================
-- TABLE : paiement
-- ====================
CREATE TABLE paiement (
    id_paiement SERIAL PRIMARY KEY,
    id_location INT NOT NULL,
    montant NUMERIC(8,2) NOT NULL CHECK (montant >= 0),
    date_paiement TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    mode_paiement VARCHAR(20) CHECK (mode_paiement IN ('carte', 'paypal', 'especes')),
    CONSTRAINT fk_paiement_location
        FOREIGN KEY (id_location)
        REFERENCES location(id_location)
        ON DELETE CASCADE
);

-- ====================
-- TABLE : maintenance
-- ====================
CREATE TABLE maintenance (
    id_maintenance SERIAL PRIMARY KEY,
    id_vehicule INT NOT NULL,
    id_technicien INT NOT NULL,
    date_intervention DATE NOT NULL,
    description TEXT,
    CONSTRAINT fk_maintenance_vehicule
        FOREIGN KEY (id_vehicule)
        REFERENCES vehicule(id_vehicule)
        ON DELETE CASCADE,
    CONSTRAINT fk_maintenance_technicien
        FOREIGN KEY (id_technicien)
        REFERENCES technicien(id_technicien)
        ON DELETE CASCADE
);
