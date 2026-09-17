'use strict';

const { query } = require('../config/db.config');

async function findAll() {
  const [rows] = await query(
    `SELECT id_auteur, nom, nationalite
     FROM auteurs
     ORDER BY nom ASC`
  );
  return rows;
}

async function findById(id) {
  const [rows] = await query(
    `SELECT id_auteur, nom, nationalite
     FROM auteurs
     WHERE id_auteur = :id`,
    { id }
  );
  return rows[0] || null;
}

async function create({ nom, nationalite }) {
  const [result] = await query(
    `INSERT INTO auteurs (nom, nationalite)
     VALUES (:nom, :nationalite)`,
    { nom, nationalite: nationalite ?? null }
  );
  return findById(result.insertId);
}

async function update(id, { nom, nationalite }) {
  await query(
    `UPDATE auteurs
     SET nom = COALESCE(:nom, nom),
         nationalite = COALESCE(:nationalite, nationalite)
     WHERE id_auteur = :id`,
    { id, nom: nom ?? null, nationalite: nationalite ?? null }
  );
  return findById(id);
}

async function remove(id) {
  const [result] = await query(
    `DELETE FROM auteurs WHERE id_auteur = :id`,
    { id }
  );
  return result.affectedRows > 0;
}

module.exports = {
  findAll,
  findById,
  create,
  update,
  remove,
};
