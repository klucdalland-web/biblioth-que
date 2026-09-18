-- =========================================================
-- Bibliothèque de quartier — Schéma PostgreSQL (Supabase)
-- Converti depuis MySQL — Akieni Academy Cohorte 2
-- =========================================================
--
-- Sur Supabase :
--   1. Ouvre SQL Editor
--   2. Colle et exécute ce script (schéma public)
--   3. Pas besoin de CREATE DATABASE (la base "postgres" existe déjà)
--
-- En local (psql) :
--   CREATE DATABASE bibliotheque ENCODING 'UTF8';
--   \c bibliotheque
--   puis exécuter ce fichier
-- =========================================================

DROP TABLE IF EXISTS emprunts CASCADE;
DROP TABLE IF EXISTS livres CASCADE;
DROP TABLE IF EXISTS adherents CASCADE;
DROP TABLE IF EXISTS auteurs CASCADE;
DROP TABLE IF EXISTS tokens CASCADE;
DROP TABLE IF EXISTS utilisateurs CASCADE;

DROP TYPE IF EXISTS statut_livre;
CREATE TYPE statut_livre AS ENUM ('disponible', 'emprunte');

CREATE TABLE utilisateurs (
    id_utilisateur     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nom                VARCHAR(100) NOT NULL,
    email              VARCHAR(150) NOT NULL,
    mot_de_passe_hash  VARCHAR(255) NOT NULL,
    role               VARCHAR(50)  NOT NULL DEFAULT 'bibliothecaire',
    created_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_utilisateurs_email UNIQUE (email)
);

CREATE TABLE auteurs (
    id_auteur     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nom           VARCHAR(150) NOT NULL,
    nationalite   VARCHAR(100)
);

CREATE TABLE adherents (
    id_adherent   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nom           VARCHAR(150) NOT NULL,
    contact       VARCHAR(150) NOT NULL
);

CREATE TABLE livres (
    id_livre           INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    titre              VARCHAR(200) NOT NULL,
    annee_publication  INT,
    id_auteur          INT NOT NULL,
    statut             statut_livre NOT NULL DEFAULT 'disponible',
    CONSTRAINT fk_livres_auteur
        FOREIGN KEY (id_auteur) REFERENCES auteurs(id_auteur)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE INDEX idx_livres_titre ON livres(titre);
CREATE INDEX idx_livres_id_auteur ON livres(id_auteur);

CREATE TABLE emprunts (
    id_emprunt           INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
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
);

CREATE INDEX idx_emprunts_id_adherent ON emprunts(id_adherent);
CREATE INDEX idx_emprunts_id_livre ON emprunts(id_livre);
CREATE INDEX idx_emprunts_date_retour_prevue ON emprunts(date_retour_prevue);

CREATE TABLE tokens (
    id_token        INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_utilisateur  INT NOT NULL,
    refresh_token   VARCHAR(255) NOT NULL,
    expire_at       TIMESTAMP NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_tokens_user
        FOREIGN KEY (id_utilisateur) REFERENCES utilisateurs(id_utilisateur)
        ON DELETE CASCADE
);

CREATE INDEX idx_tokens_refresh ON tokens(refresh_token);
