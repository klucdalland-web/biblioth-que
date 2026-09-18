-- =========================================================
-- Bibliothèque de quartier — Insertion des données
-- Converti depuis un export phpMyAdmin (MariaDB) vers PostgreSQL
-- À exécuter APRÈS le script de création des tables
-- =========================================================

-- Ordre respectant les clés étrangères :
-- utilisateurs, auteurs, adherents -> livres -> tokens, emprunts

-- ---------------------------------------------------------
-- utilisateurs
-- ---------------------------------------------------------
INSERT INTO utilisateurs (id_utilisateur, nom, email, mot_de_passe_hash, role, created_at) OVERRIDING SYSTEM VALUE VALUES
(2, 'luc Dalland Nkodia De Matsika', 'lucdalland@gmail.com', '$2b$10$xGVFyVOFi4/ceu2CpYzB7Os/FDHV.C9k9bsEvRZGUwRD0yRkTfVVK', 'admin', '2026-09-17 17:27:50'),
(3, 'Demo', 'demo1789694089@biblio.local', '$2b$10$ibl8dFYpRszOfuzaCgugEeNPJZ6Qq9S0YMgs1h3TeEDFMAnPXRRNC', 'admin', '2026-09-18 01:14:49'),
(4, 'StatsTest', 'stats@mail.com', '$2b$10$2e4GbQ4I3qML0nr5itKbLutL2wCsGPtIJSruviD86orjLQ6tiwl7q', 'bibliothecaire', '2026-09-18 01:28:11'),
(5, 'aka', 'aa@gmail.com', '$2b$10$Q2k.9ZxOyy0hGUWq9NWhL.2PbXR58/ax9XhtYgNfdE.hZcO/7RlnW', 'bibliothecaire', '2026-09-18 02:44:53'),
(6, 'doko', 'ss@gddmail.com', '$2b$10$FJwIYYFAjdBwNgkvwcknlO54CpejRMrmHcuMF8lJVUtxCStFBimGO', 'bibliothecaire', '2026-09-18 03:26:17');

-- ---------------------------------------------------------
-- auteurs
-- ---------------------------------------------------------
INSERT INTO auteurs (id_auteur, nom, nationalite) OVERRIDING SYSTEM VALUE VALUES
(1, 'lkflklf', 'flkflf'),
(2, 'lkflklf', 'flkflf'),
(3, 'Victor Hugo', 'Française'),
(4, 'J.K. Rowling', 'Britannique'),
(5, 'Chinua Achebe', 'Nigériane'),
(6, 'Gabriel García Márquez', 'Colombienne'),
(7, 'Ngũgĩ wa Thiong''o', 'Kényane');

-- ---------------------------------------------------------
-- adherents
-- ---------------------------------------------------------
INSERT INTO adherents (id_adherent, nom, contact) OVERRIDING SYSTEM VALUE VALUES
(1, 'Jean Dupont', 'jean.dupont@email.com'),
(2, 'Marie Ossa', '06 12 34 56 78'),
(3, 'Paul Mabiala', 'paul.mabiala@email.com'),
(4, 'Sophie Koumba', '06 98 76 54 32');

-- ---------------------------------------------------------
-- livres
-- ---------------------------------------------------------
INSERT INTO livres (id_livre, titre, annee_publication, id_auteur, statut) OVERRIDING SYSTEM VALUE VALUES
(1, 'Les Misérables', 1862, 1, 'disponible'),
(2, 'Notre-Dame de Paris', 1831, 1, 'disponible'),
(3, 'Harry Potter à l''école des sorciers', 1997, 2, 'disponible'),
(4, 'Le Monde s''effondre', 1958, 3, 'disponible'),
(5, 'Cent ans de solitude', 1967, 4, 'disponible'),
(6, 'Une place au soleil', 1965, 5, 'disponible'),
(7, 'Voyage après la mere', 2026, 3, 'disponible');

-- ---------------------------------------------------------
-- tokens
-- ---------------------------------------------------------
INSERT INTO tokens (id_token, id_utilisateur, refresh_token, expire_at, created_at) OVERRIDING SYSTEM VALUE VALUES
(1, 2, '5515212f307aa3395964a127f3bef04856cfac32080bdf0e6ad8159ae6385d6f5d17a50c6a2404ba', '2026-09-24 17:27:50', '2026-09-17 17:27:50'),
(2, 2, '23f47854b0c89b8aff3c32b75462cef3b4649d4e40c1d7ed11519210d4c6566ae7fd2e8e47a86694', '2026-09-24 17:28:16', '2026-09-17 17:28:16'),
(3, 2, '2c4874dc69e43daa54732d46fc1fdc7e694810c37ede2f9a4c787ec91885fbc892b0be6fad1d7ebc', '2026-09-24 17:28:24', '2026-09-17 17:28:24'),
(4, 2, '0d3ec88ccbf3c2d757035dfc9f2e206f25318540cbe15960fc4e0a22abfea7c04d8e5ed4aa0a9c52', '2026-09-24 18:26:17', '2026-09-17 18:26:17'),
(5, 2, '926937d1bde430a6150c3608515cc318f9cbda6d3dcbcc364d0c87cf8e5703f184e500b1b877f043', '2026-09-24 18:26:30', '2026-09-17 18:26:30'),
(6, 2, '234236c78790ad7cab1824de897e1841c3191058937143b755e847e96152a9d2045433bae4102aa5', '2026-09-24 18:32:30', '2026-09-17 18:32:30'),
(7, 2, '29ee905210c8a24b0a77b4cb77052ec49ebbbdc780c9da39bd54d6ba6e56bbe9611c5d5ab73121c0', '2026-09-24 18:32:51', '2026-09-17 18:32:51'),
(8, 2, '65397953be217a02ca2d533d76a77ff6154851c985944882d9490df341c92b9d88ceb5f6f50fa1f1', '2026-09-24 23:21:13', '2026-09-17 23:21:13'),
(9, 2, 'bca5240ea9288b8b038dba2f5f7ffd1fc795145df3c5c3bfbdb9adeae9318fa3114a27e8baf6856d', '2026-09-24 23:33:40', '2026-09-17 23:33:40'),
(10, 2, '1dfb54f0968b9974a8f0db31c7ca4a95060bdff414edd8383c179fb2a2c0d8d01eec76b59c275678', '2026-09-25 00:06:01', '2026-09-18 00:06:01'),
(11, 3, '3925959565370fc69faa02e931f55ef88097835ae915db1a8095f0796e96c551cf70d3595f0c741c', '2026-09-25 01:14:49', '2026-09-18 01:14:49'),
(12, 3, '21eee0d9cf64050d6d9b5e602fa20bbbae2d8af8467cb7fc71a27a7b1044b5fea7df555ae5fbe08e', '2026-09-25 01:14:49', '2026-09-18 01:14:49'),
(13, 2, 'bb49dc7bfb55b82b82106940a69649280d5554198e7eef39f6100f1561f31aaa6922e32c2b426e22', '2026-09-25 01:15:49', '2026-09-18 01:15:49'),
(14, 2, 'fb9101a41b0b695c914285cb9c580f22050a86e87f42da8c7782b33511f20f7d538bb63e8031c8a5', '2026-09-25 01:18:36', '2026-09-18 01:18:36'),
(15, 2, '2f431048150c0a27414e341473b6c869f37676f104741d9729e377ebd93be3a3a2c8cbf2f5c3186b', '2026-09-25 01:18:37', '2026-09-18 01:18:37'),
(17, 4, 'ef15566d680e07364196c81721f793ab80ddee90701f5dc4725319affc7c8d64b279e5272f01b9f9', '2026-09-25 01:28:11', '2026-09-18 01:28:11'),
(18, 4, '7ec0f38c60a98ca6dd3acd7a95ed99aac93f7696dd1fb9f7f6e82d0a0fe61d385f72208d22902efc', '2026-09-25 01:28:11', '2026-09-18 01:28:11'),
(19, 2, '7712c93f2604077f48b3c20154322305a918487797aaad8419c047949ab2394c6bfa1f07b98806e6', '2026-09-25 01:28:57', '2026-09-18 01:28:57'),
(20, 4, 'f13064961e5baebca173fc991abd666a5cab3948cab5dd76f09cadfd8b51022ff6e29ae086d6799e', '2026-09-25 01:30:32', '2026-09-18 01:30:32'),
(23, 6, '75beb3b1b426eb50679a902fe61e3e63c87b77b61dce0f305ee189943e1e639fe8ed0f8c7fc7c741', '2026-09-25 03:26:17', '2026-09-18 03:26:17'),
(24, 2, '27ec49c6904aaa31dbdb895e1fafd045d51212835c6aa0ea84ccf4b265a7ec056da21ecdc47c188b', '2026-09-25 04:09:26', '2026-09-18 04:09:26'),
(25, 2, 'f603e9f6128ac1a5204349d78f6fddc0702b41d23e65e14d569fb6124e4889db0ec700d45f061741', '2026-09-25 09:12:12', '2026-09-18 09:12:12'),
(26, 2, 'f83ceb1c8248c3d2e5f13df7f4ab50c67892cd7b21f1ebcf3aa65d566f10659ab1cd7c48292bd186', '2026-09-25 09:12:13', '2026-09-18 09:12:13'),
(27, 2, '498d28d5a66b03661c1d9aad2908a2f123e40eab3ede35f9a9b63157019a6d51e5353bf3944cee88', '2026-09-25 09:12:12', '2026-09-18 09:12:13'),
(28, 2, '4e328d294af18979238a165ada496d955f4bf43692c1ecc8d5bef75fc4fc7f4e7811873ea42f2195', '2026-09-25 09:12:13', '2026-09-18 09:12:13'),
(29, 2, '3dc8d0a4581d349b022ff1dae528be2d8d17eec2fd32e9830f98ce4f76911cc0ba796a1489ab003d', '2026-09-25 09:12:13', '2026-09-18 09:12:13'),
(30, 2, '9ebfd211f54300343a8f880ef273a6a02742b68747a504b1c1eca1a5ab89a03d4330587c05deb0aa', '2026-09-25 09:13:50', '2026-09-18 09:13:50'),
(31, 2, '247639694229c6445357de0f1c5a3ee4e5680188d647fc3399447cafd8200dc0c301f8868a62187a', '2026-09-25 09:13:50', '2026-09-18 09:13:50'),
(32, 2, '670845a32e09e612d53a5352ae853e7f76ab18d2bfc507c056c9b9d801728a3d812bdf474de77a56', '2026-09-25 09:18:40', '2026-09-18 09:18:40'),
(33, 2, 'c067a55c5464366255cfdf10d83e9d36074c7e62e755132a450fe6f9b438061e0b94ca9339cd2a07', '2026-09-25 09:29:05', '2026-09-18 09:29:05'),
(34, 2, 'e692e0167934ad4483bad4761b8b8e7cac4d18dcf35e0453b2923bd068363801f8811bf14b109966', '2026-09-25 09:38:41', '2026-09-18 09:38:41');

-- ---------------------------------------------------------
-- emprunts
-- ---------------------------------------------------------
INSERT INTO emprunts (id_emprunt, id_adherent, id_livre, date_emprunt, date_retour_prevue, date_retour_reelle) OVERRIDING SYSTEM VALUE VALUES
(1, 1, 1, '2026-09-18', '2026-10-02', '2026-09-18'),
(2, 2, 3, '2026-08-19', '2026-09-02', '2026-09-18'),
(3, 2, 1, '2026-09-18', '2026-10-02', '2026-09-18');

-- =========================================================
-- Remise à niveau des séquences (identity)
-- Indispensable après un OVERRIDING SYSTEM VALUE, sinon les
-- prochains INSERT sans ID explicite entreront en conflit
-- avec les ID déjà insérés.
-- =========================================================
SELECT setval(pg_get_serial_sequence('utilisateurs', 'id_utilisateur'), (SELECT MAX(id_utilisateur) FROM utilisateurs));
SELECT setval(pg_get_serial_sequence('auteurs', 'id_auteur'), (SELECT MAX(id_auteur) FROM auteurs));
SELECT setval(pg_get_serial_sequence('adherents', 'id_adherent'), (SELECT MAX(id_adherent) FROM adherents));
SELECT setval(pg_get_serial_sequence('livres', 'id_livre'), (SELECT MAX(id_livre) FROM livres));
SELECT setval(pg_get_serial_sequence('tokens', 'id_token'), (SELECT MAX(id_token) FROM tokens));
SELECT setval(pg_get_serial_sequence('emprunts', 'id_emprunt'), (SELECT MAX(id_emprunt) FROM emprunts));