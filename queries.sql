-- =========================================================
-- Projet cIAra Mobility
-- Mission 3 : Requêtes SQL avancées
-- =========================================================

-- =========================================================
-- 1. REQUÊTES DE BASE (SELECT, WHERE, JOIN)
-- =========================================================

-- 1.1 Liste des clients inscrits avec leur email
SELECT id_client, nom, prenom, email
FROM client;

-- 1.2 Liste des véhicules disponibles avec leur type (JOIN)
SELECT v.id_vehicule, v.matricule, v.statut, tv.marque, tv.modele
FROM vehicule v
JOIN type_vehicule tv ON v.id_type = tv.id_type
WHERE v.statut = 'DISPONIBLE';

-- 1.3 Réservations avec le nom du client et le véhicule réservé
SELECT r.id_reservation, c.nom, c.prenom, v.matricule, r.date_debut_prevue, r.date_fin_prevue
FROM reservation r
JOIN client c ON r.id_client = c.id_client
JOIN vehicule v ON r.id_vehicule = v.id_vehicule;

-- 1.4 Liste des locations actuellement en cours (Date de fin non renseignée)
-- Utile pour le dashboard de surveillance en temps réel
SELECT l.id_location, c.nom, v.matricule, l.date_debut
FROM location l
JOIN client c ON l.id_client = c.id_client
JOIN vehicule v ON l.id_vehicule = v.id_vehicule
WHERE l.date_fin IS NULL;

-- =========================================================
-- 2. AGRÉGATIONS (COUNT, AVG, MAX, HAVING)
-- =========================================================

-- 2.1 Nombre total de véhicules par statut
SELECT statut, COUNT(*) AS nombre_vehicules
FROM vehicule
GROUP BY statut;

-- 2.2 Autonomie moyenne des véhicules
SELECT AVG(autonomie) AS autonomie_moyenne
FROM vehicule;

-- 2.3 Montant maximal payé pour une location
SELECT MAX(montant_paiement) AS paiement_max
FROM paiement;

-- 2.4 Chiffre d'affaires généré par Modèle de véhicule (Trié par rentabilité)
-- Jointure  à 4 tables pour lier le Type de véhicule au Paiement
SELECT tv.marque, tv.modele, SUM(p.montant_paiement) AS total_recettes
FROM type_vehicule tv
JOIN vehicule v ON tv.id_type = v.id_type
JOIN location l ON v.id_vehicule = l.id_vehicule
JOIN paiement p ON l.id_location = p.id_location
GROUP BY tv.marque, tv.modele
ORDER BY total_recettes DESC;

-- 2.5 Clients VIP (ceux qui ont dépensé plus de 100€ au total)
-- Utilisation de HAVING pour filtrer après l'agrégation
SELECT c.nom, c.prenom, SUM(p.montant_paiement) as total_depense
FROM client c
JOIN location l ON c.id_client = l.id_client
JOIN paiement p ON l.id_location = p.id_location
GROUP BY c.id_client, c.nom, c.prenom
HAVING SUM(p.montant_paiement) > 100;

-- =========================================================
-- 3. SOUS-REQUÊTES
-- =========================================================

-- 3.1 Clients ayant effectué au moins une réservation
SELECT nom, prenom
FROM client
WHERE id_client IN (
    SELECT id_client
    FROM reservation
);

-- 3.2 Véhicules n'ayant jamais été loués
SELECT id_vehicule, matricule
FROM vehicule
WHERE id_vehicule NOT IN (
    SELECT id_vehicule
    FROM location
);

-- 3.3 Locations dont le montant payé est supérieur à la moyenne
SELECT *
FROM paiement
WHERE montant_paiement > (
    SELECT AVG(montant_paiement)
    FROM paiement
);

-- =========================================================
-- 4. VUES (Simplification de l'accès aux données)
-- =========================================================

-- 4.1 Vue des véhicules avec leurs informations complètes (Marque, Modèle, Prix)
CREATE OR REPLACE VIEW vue_vehicules_complets AS
SELECT v.id_vehicule, v.matricule, v.statut,
       tv.marque, tv.modele, tv.prix_minute, tv.energie
FROM vehicule v
JOIN type_vehicule tv ON v.id_type = tv.id_type;

-- 4.2 Vue des locations avec détails clients et véhicules
CREATE OR REPLACE VIEW vue_locations_details AS
SELECT l.id_location, c.nom, c.prenom, v.matricule,
       l.date_debut, l.date_fin, l.statut
FROM location l
JOIN client c ON l.id_client = c.id_client
JOIN vehicule v ON l.id_vehicule = v.id_vehicule;

-- =========================================================
-- 5. TRIGGERS (Automatisation)
-- =========================================================

-- 5.1 Fonction trigger : mise à jour du statut du véhicule lors d'une location
-- Le véhicule passe automatiquement à 'LOUE' quand une location est créée
CREATE OR REPLACE FUNCTION maj_statut_vehicule_location()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE vehicule
    SET statut = 'LOUE'
    WHERE id_vehicule = NEW.id_vehicule;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 5.2 Trigger qui se déclenche après l'insertion d'une ligne dans LOCATION
DROP TRIGGER IF EXISTS trigger_location_vehicule ON location;
CREATE TRIGGER trigger_location_vehicule
AFTER INSERT ON location
FOR EACH ROW
EXECUTE FUNCTION maj_statut_vehicule_location();

-- =========================================================
-- 6. FONCTIONS (Logique Métier)
-- =========================================================

-- 6.1 Fonction calculant le coût total d'une location
-- Logique : (Date Fin - Date Début) en minutes * Prix à la minute du type de véhicule
CREATE OR REPLACE FUNCTION calcul_cout_location(
    p_id_location INT
)
RETURNS NUMERIC AS $$
DECLARE
    duree_minutes INT;
    prix_unit NUMERIC;
    cout_total NUMERIC;
BEGIN
    -- 1. Calcul de la durée en minutes
    SELECT EXTRACT(EPOCH FROM (l.date_fin - l.date_debut)) / 60
    INTO duree_minutes
    FROM location l
    WHERE l.id_location = p_id_location;

    -- 2. Récupération du prix par minute associé au véhicule loué
    SELECT tv.prix_minute
    INTO prix_unit
    FROM location l
    JOIN vehicule v ON l.id_vehicule = v.id_vehicule
    JOIN type_vehicule tv ON v.id_type = tv.id_type
    WHERE l.id_location = p_id_location;

    -- 3. Calcul final
    -- Sécurité : si la durée est nulle ou négative, on met 0
    IF duree_minutes IS NULL OR duree_minutes < 0 THEN
        cout_total := 0;
    ELSE
        cout_total := duree_minutes * prix_unit;
    END IF;

    RETURN cout_total;
END;
$$ LANGUAGE plpgsql;



-- =========================================================
-- 7. ZONE DE TESTS & PREUVES (À exécuter pour vérifier)
-- =========================================================

-- ---------------------------------------------------------
-- 7.1 TEST DU TRIGGER (Automatisation du statut)
-- ---------------------------------------------------------
-- Objectif : Prouver que le véhicule passe de 'DISPONIBLE' à 'LOUE' automatiquement.

-- A. Choisir un véhicule disponible (ex ici: le premier trouvé)
-- Notez son ID ou Matricule pour vérifier après.
SELECT id_vehicule, matricule, statut 
FROM vehicule 
WHERE statut = 'DISPONIBLE' 
LIMIT 1;

-- B. Créer une location pour ce véhicule (Action qui déclenche le trigger)
-- (Le sous-requête sélectionne automatiquement le 1er véhicule dispo)
INSERT INTO location (id_client, id_vehicule, date_debut)
VALUES (
    (SELECT id_client FROM client LIMIT 1), -- Premier client trouvé
    (SELECT id_vehicule FROM vehicule WHERE statut = 'DISPONIBLE' LIMIT 1), -- Premier véhicule dispo
    CURRENT_TIMESTAMP
);

-- C. Vérifier le résultat (Le statut doit être devenu 'LOUE')
SELECT v.id_vehicule, v.matricule, v.statut 
FROM vehicule v
JOIN location l ON v.id_vehicule = l.id_vehicule
WHERE l.date_fin IS NULL -- Location en cours
ORDER BY l.date_debut DESC 
LIMIT 1;


-- ---------------------------------------------------------
-- 7.2 TEST DE LA FONCTION (Calcul du prix)
-- ---------------------------------------------------------
-- Objectif : Vérifier que le calcul (Durée * Prix/min) est correct.

-- A. Créer une location terminée de 60 minutes pour le test
-- (On force les dates pour avoir une durée exacte de 1h)
INSERT INTO location (id_client, id_vehicule, date_debut, date_fin, statut)
VALUES (
    (SELECT id_client FROM client LIMIT 1),
    (SELECT id_vehicule FROM vehicule LIMIT 1),
    '2026-01-01 10:00:00', -- Début
    '2026-01-01 11:00:00', -- Fin (+60 min)
    'TERMINEE'
);

-- B. Appeler la fonction sur cette dernière location
-- Si le prix du véhicule est de 0.30€/min, le résultat doit être 18.00 (60 * 0.30)
SELECT 
    id_location, 
    calcul_cout_location(id_location) AS prix_total_calcule
FROM location 
ORDER BY id_location DESC 
LIMIT 1;