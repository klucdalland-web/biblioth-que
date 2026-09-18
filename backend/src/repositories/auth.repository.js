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
    `SELECT id_utilisateur, nom, email, role, created_at
     FROM utilisateurs
     WHERE id_utilisateur = :id`,
    { id }
  );
  return rows[0] || null;
}

async function findByIdWithHash(id) {
  const [rows] = await query(
    `SELECT id_utilisateur, nom, email, mot_de_passe_hash, role
     FROM utilisateurs
     WHERE id_utilisateur = :id`,
    { id }
  );
  return rows[0] || null;
}

async function findAll() {
  const [rows] = await query(
    `SELECT id_utilisateur, nom, email, role, created_at
     FROM utilisateurs
     ORDER BY nom ASC`
  );
  return rows;
}

async function create({ nom, email, mot_de_passe_hash, role = 'bibliothecaire' }) {
  const [result] = await query(
    `INSERT INTO utilisateurs (nom, email, mot_de_passe_hash, role)
     VALUES (:nom, :email, :mot_de_passe_hash, :role)`,
    { nom, email, mot_de_passe_hash, role }
  );

  return findById(result.insertId);
}

async function update(id, { nom, email, role }) {
  await query(
    `UPDATE utilisateurs
     SET nom = :nom, email = :email, role = :role
     WHERE id_utilisateur = :id`,
    { id, nom, email, role }
  );
  return findById(id);
}

async function updatePassword(id, mot_de_passe_hash) {
  await query(
    `UPDATE utilisateurs
     SET mot_de_passe_hash = :mot_de_passe_hash
     WHERE id_utilisateur = :id`,
    { id, mot_de_passe_hash }
  );
}

async function remove(id) {
  const [result] = await query(
    `DELETE FROM utilisateurs WHERE id_utilisateur = :id`,
    { id }
  );
  return result.affectedRows > 0;
}

module.exports = {
  findByEmail,
  findById,
  findByIdWithHash,
  findAll,
  create,
  update,
  updatePassword,
  remove,
};
