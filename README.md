# cIAra Mobility
Projet SQL B2 - Gestion de locations de véhicules électriques

![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL-blue?style=for-the-badge&logo=postgresql)
![Status](https://img.shields.io/badge/Status-Terminé-success?style=for-the-badge)
![School](https://img.shields.io/badge/Projet-B2-orange?style=for-the-badge)

---

##  Contexte du Projet

**cIAra Mobility** est une start-up innovante spécialisée dans la mobilité urbaine durable. Elle propose un service moderne de location de véhicules électriques partagés incluant voitures, scooters, vélos et trottinettes.

Face à une forte croissance, l’entreprise doit disposer d’un système d’information centralisé pour gérer efficacement :
*  **Les clients** et utilisateurs du service.
*  **La flotte de véhicules** (électrique).
*  **Les stations et bornes de recharge**.
*  **Les réservations et locations** en temps réel.
*  **Les paiements** et transactions.
*  **La maintenance des véhicules** et les interventions techniques.

---

##  Objectif du Projet

Concevoir et implémenter une base de données relationnelle **PostgreSQL** robuste, cohérente et 
conforme aux bonnes pratiques professionnelles, capable de supporter la montée en charge de l'activité.

---

##  Méthodologie Utilisée

Le projet suit rigoureusement la méthodologie **Merise** et les standards de développement, en plusieurs étapes :

1.  **Analyse du besoin** : Identification des règles de gestion.
2.  **Modélisation conceptuelle (MCD)** : Schématisation des entités et relations.
3.  **Modélisation logique (MLD)** : Transformation en structure relationnelle.
4.  **Implémentation physique** : Écriture des scripts SQL pour PostgreSQL.
5.  **SQL Avancé** : Développement de requêtes complexes, vues, triggers et fonctions.
6.  **Gestion de versions** : Collaboration et historisation via GitHub.
7.  **Documentation** : Production de livrables professionnels.

---

##  Schéma de la base de données

La base de données est structurée autour des entités principales suivantes, garantissant une séparation claire des responsabilités :

### Entités principales
* **CLIENT** : Utilisateurs du service (état civil, contact).
* **TECHNICIEN** : Personnel chargé de la maintenance.
* **STATION** : Lieux physiques de stationnement.
* **BORNE_DE_RECHARGE** : Infrastructures de charge reliées aux stations.
* **TYPE_VEHICULE** : Catalogue (Marque, Modèle, Prix/min, Énergie).
* **VEHICULE** : Flotte physique (Matricule, Autonomie, Statut).
* **RESERVATION** : Planification des usages futurs.
* **LOCATION** : Historique des trajets effectués (Km, Dates).
* **PAIEMENT** : Transactions financières liées aux locations.
* **INTERVENTION** : Suivi des réparations et pannes.

### Relations clés
* Un client peut effectuer plusieurs réservations et locations.
* Un véhicule appartient à un **Type de véhicule** (ex: Kia EV6).
* Un véhicule peut être rattaché à une **Station** (s'il ne roule pas).
* Une station possède plusieurs **Bornes de recharge**.
* Une location génère un **Paiement**.
* Une intervention est réalisée par un **Technicien** sur un **Véhicule**.

### Contraintes d’intégrité
Le schéma respecte strictement les contraintes pour garantir la qualité des données :
* **PRIMARY KEY (PK)** : Identifiants uniques pour chaque table.
* **FOREIGN KEY (FK)** : Maintien de la cohérence référentielle.
* **NOT NULL** : Champs obligatoires sécurisés.
* **UNIQUE** : Pas de doublons (Emails, Immatriculations).
* **CHECK** : Validation logique (ex: `autonomie >= 0`, `prix > 0`).

---

## 🗄️ Technologies utilisées

* **SGBD** : PostgreSQL 14+
* **Langage** : SQL Standard & PL/pgSQL
* **Outils** : pgAdmin 4, VS Code
* **Gestion de version** : Git & GitHub
* **Méthodologie** : Merise (MCD/MLD)

---

## 📂 Structure du dépôt GitHub 

📦 ciara-mobility-sql
 ┣ 📄 README.md             <-- Documentation du projet (ce fichier)
 ┣ 📄 create_tables.sql          <-- Script de création de la structure et insertion des données
 ┣ 📄 queries.sql                     <-- Script contenant les 10+ requêtes, vues, triggers et fonctions
 ┣ 📁 docs                                   <-- Dossier de documentation
 ┃   ┣ 📄 MCD-MLD-Dictionnaire-de-Donnees.pdf      <-- Modèle Conceptuel de Données, Modèle Logique de Données et Dictionnaire de données

---

##  Instructions de lancement

### 1. Installer PostgreSQL
Télécharger PostgreSQL depuis le site officiel : **https://www.postgresql.org/download/**
Installer **PostgreSQL** et **pgAdmin 4**.

### 2. Créer la base de données
Dans **pgAdmin** (Query Tool) ou via le terminal SQL :
**CREATE DATABASE ciara_mobility;**

Si via terminal : se connecter à la base avec \c ciara_mobility

### 3. Créer les tables et importer les données
Ce script crée la structure, nettoie les anciennes tables et
injecte le jeu de données de test.
Ouvrir le fichier **create_tables.sql** dans pgAdmin.
    et 
Exécuter le script complet **(F5)**.

### 4. Tester les requêtes SQL
Exécuter le fichier **queries.sql** pour voir le projet en action. Ce fichier contient :

*  **Requêtes simples (SELECT, WHERE, JOIN)**
*  **Agrégations (COUNT, AVG, MAX)**
*  **Sous-requêtes complexes**
*  **Vues matérialisées**
*  **Triggers et Fonctions**

---

## ⚙️ Fonctionnalités avancées implémentées
Le projet intègre des objets SQL avancés pour automatiser les processus métier :
* **Vues SQL** (vue_locations_details) : Simplifie l'accès aux données en masquant la complexité des jointures pour les développeurs d'application.
* **Trigger Automatique** (trigger_location_vehicule) :
Action : Dès qu'une location est créée (INSERT).
Effet : Le statut du véhicule passe automatiquement de DISPONIBLE à LOUE sans intervention humaine.
* **Fonction Stockée** (calcul_cout_location) :Calcule dynamiquement le prix final d'une course en fonction de la 
durée (en minutes) et du tarif spécifique au modèle de véhicule.

---

## 👥 Travail collaboratif & GitHub 
* **Dépôt GitHub partagé et public.**
* **Commits réguliers suivant la progression du projet.**
* **Historique des versions clair et consultable.** 
* **Documentation technique (README) maintenue à jour.**

---

## Compétences développées 
Ce projet a permis de valider les compétences suivantes :
* **Conception** : Modélisation complexe de bases de données (Merise).
* **Développement** : Maîtrise du SQL avancé sous PostgreSQL.
* **Automatisation** : Création de logique métier en base (Triggers/Fonctions).
* **Collaboration** : Gestion de versions professionnelle avec Git/GitHub.
* **Communication** : Rédaction de documentation technique.

---

## Projet Académique
* Projet réalisé dans le cadre du Projet SQL B2

* Année académique : 2025 – 2026 Auteur : **[ESSOH Sam Dilane & BICTOGO Mehdi]**

---

## Conclusion
Ce projet met en œuvre un cas réel de gestion de mobilité électrique, 
en appliquant des concepts professionnels utilisés dans les entreprises modernes de la Tech et de la Data.