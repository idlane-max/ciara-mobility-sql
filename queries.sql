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