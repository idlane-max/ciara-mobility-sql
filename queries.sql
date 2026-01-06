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
-- Jointure complexe à 4 tables pour lier le Type au Paiement
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