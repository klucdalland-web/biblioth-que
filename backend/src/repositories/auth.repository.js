'use strict';

const { query } = require('../config/db.config');

async function findByEmail(email) {
  const [rows] = await query(
    `SELECT id_utilisateur, nom, email, mot_de_passe_hash, role
     FROM utilisateurs
     WHERE email = :email`,
    { email }
  );
  return rows[0] || null;
}

async function findById(id) {
  const [rows] = await query(
    `SELECT id_utilisateur, nom, email, role
     FROM utilisateurs
     WHERE id_utilisateur = :id`,
    { id }
  );
  return rows[0] || null;
}

async function create({ nom, email, mot_de_passe_hash, role = 'bibliothecaire' }) {
  const [result] = await query(
    `INSERT INTO utilisateurs (nom, email, mot_de_passe_hash, role)
     VALUES (:nom, :email, :mot_de_passe_hash, :role)`,
    { nom, email, mot_de_passe_hash, role }
  );

  return {
    id_utilisateur: result.insertId,
    nom,
    email,
    role,
  };
}

module.exports = {
  findByEmail,
  findById,
  create,
};
