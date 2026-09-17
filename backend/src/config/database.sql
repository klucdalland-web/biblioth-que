-- =========================================================
-- Bibliothèque de quartier — Schéma de base de données
-- SGBD : MySQL
-- Akieni Academy — Cohorte 2 — Semaines 14-15
-- =========================================================

-- Décommentez si vous voulez que le script crée la base lui-même
CREATE DATABASE IF NOT EXISTS bibliotheque CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bibliotheque;

-- On repart toujours de zéro (ordre important à cause des clés étrangères)
DROP TABLE IF EXISTS emprunts;
DROP TABLE IF EXISTS livres;
DROP TABLE IF EXISTS adherents;
DROP TABLE IF EXISTS auteurs;
DROP TABLE IF EXISTS utilisateurs;

-- =========================================================
-- Table : utilisateurs (membres du personnel qui se connectent à l'app)
-- =========================================================
CREATE TABLE utilisateurs (
    id_utilisateur     INT AUTO_INCREMENT PRIMARY KEY,
    nom                VARCHAR(100) NOT NULL,
    email              VARCHAR(150) NOT NULL,
    mot_de_passe_hash  VARCHAR(255) NOT NULL,
    role               VARCHAR(50)  NOT NULL DEFAULT 'bibliothecaire',
    created_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_utilisateurs_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================
-- Table : auteurs
-- =========================================================
CREATE TABLE auteurs (
    id_auteur     INT AUTO_INCREMENT PRIMARY KEY,
    nom           VARCHAR(150) NOT NULL,
    nationalite   VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================
-- Table : adherents (membres de la bibliothèque, ne se connectent pas)
-- =========================================================
CREATE TABLE adherents (
    id_adherent   INT AUTO_INCREMENT PRIMARY KEY,
    nom           VARCHAR(150) NOT NULL,
    contact       VARCHAR(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================
-- Table : livres
-- Chaque ligne = un exemplaire physique unique (statut individuel)
-- =========================================================
CREATE TABLE livres (
    id_livre           INT AUTO_INCREMENT PRIMARY KEY,
    titre              VARCHAR(200) NOT NULL,
    annee_publication  INT,
    id_auteur          INT NOT NULL,
    statut             ENUM('disponible', 'emprunte') NOT NULL DEFAULT 'disponible',
    CONSTRAINT fk_livres_auteur
        FOREIGN KEY (id_auteur) REFERENCES auteurs(id_auteur)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Index pour accélérer la recherche par titre / auteur (besoin fonctionnel 3)
CREATE INDEX idx_livres_titre ON livres(titre);
CREATE INDEX idx_livres_id_auteur ON livres(id_auteur);

-- =========================================================
-- Table : emprunts
-- date_retour_reelle = NULL  -> emprunt en cours (ou en retard, calculé, pas stocké)
-- date_retour_reelle renseignée -> livre rendu
-- =========================================================
CREATE TABLE emprunts (
    id_emprunt           INT AUTO_INCREMENT PRIMARY KEY,
    id_adherent          INT NOT NULL,
    id_livre             INT NOT NULL,
    date_emprunt         DATE NOT NULL,
    date_retour_prevue   DATE NOT NULL,
    date_retour_reelle   DATE NULL,
    CONSTRAINT fk_emprunts_adherent
        FOREIGN KEY (id_adherent) REFERENCES adherents(id_adherent)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_emprunts_livre
        FOREIGN KEY (id_livre) REFERENCES livres(id_livre)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Index utiles pour les statistiques et les listes filtrées
CREATE INDEX idx_emprunts_id_adherent ON emprunts(id_adherent);
CREATE INDEX idx_emprunts_id_livre ON emprunts(id_livre);
CREATE INDEX idx_emprunts_date_retour_prevue ON emprunts(date_retour_prevue);

-- =========================================================
-- (Optionnel) Un utilisateur de départ pour pouvoir se connecter
-- Remplacez le hash par un vrai hash généré par votre backend
-- =========================================================
-- INSERT INTO utilisateurs (nom, email, mot_de_passe_hash, role)
-- VALUES ('Admin', 'admin@bibliotheque.local', '<hash_a_generer>', 'bibliothecaire');