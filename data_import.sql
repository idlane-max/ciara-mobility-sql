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