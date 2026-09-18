'use strict';

const { query } = require('../config/db.config');

async function findAll({ search } = {}) {
  const params = {};
  let where = '';

  if (search) {
    where = ` WHERE nom ILIKE :search OR contact ILIKE :search`;
    params.search = `%${search}%`;
  }

  const [rows] = await query(
    `SELECT id_adherent, nom, contact
     FROM adherents
     ${where}
     ORDER BY nom ASC`,
    params
  );
  return rows;
}

async function findById(id) {
  const [rows] = await query(
    `SELECT id_adherent, nom, contact
     FROM adherents
     WHERE id_adherent = :id`,
    { id }
  );
  return rows[0] || null;
}

async function create({ nom, contact }) {
  const [, result] = await query(
    `INSERT INTO adherents (nom, contact)
     VALUES (:nom, :contact)
     RETURNING id_adherent`,
    { nom, contact }
  );
  return findById(result.insertId);
}

async function update(id, { nom, contact }) {
  await query(
    `UPDATE adherents
     SET nom = COALESCE(:nom, nom),
         contact = COALESCE(:contact, contact)
     WHERE id_adherent = :id`,
    { id, nom: nom ?? null, contact: contact ?? null }
  );
  return findById(id);
}

async function remove(id) {
  const [, result] = await query(
    `DELETE FROM adherents WHERE id_adherent = :id`,
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
