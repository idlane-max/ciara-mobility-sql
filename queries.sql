SELECT 
    v.matricule, 
    t.marque, 
    t.modele, 
    v.statut, 
    s.ville 
FROM VEHICULE v
JOIN TYPE_VEHICULE t ON v.id_type = t.id_type
JOIN STATION s ON v.id_station = s.id_station
ORDER BY s.ville;