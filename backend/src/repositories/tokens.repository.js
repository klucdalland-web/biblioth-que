'use strict';

const { query } = require('../config/db.config');

async function create({ id_utilisateur, refresh_token, expire_at }) {
  const [result] = await query(
    `INSERT INTO tokens (id_utilisateur, refresh_token, expire_at)
     VALUES (:id_utilisateur, :refresh_token, :expire_at)`,
    { id_utilisateur, refresh_token, expire_at }
  );

  return {
    id_token: result.insertId,
    id_utilisateur,
    refresh_token,
    expire_at,
  };
}

async function findByToken(refresh_token) {
  const [rows] = await query(
    `SELECT id_token, id_utilisateur, refresh_token, expire_at, created_at
     FROM tokens
     WHERE refresh_token = :refresh_token
       AND expire_at > NOW()`,
    { refresh_token }
  );
  return rows[0] || null;
}

async function removeByToken(refresh_token) {
  const [result] = await query(
    `DELETE FROM tokens WHERE refresh_token = :refresh_token`,
    { refresh_token }
  );
  return result.affectedRows > 0;
}

async function removeByUser(id_utilisateur) {
  const [result] = await query(
    `DELETE FROM tokens WHERE id_utilisateur = :id_utilisateur`,
    { id_utilisateur }
  );
  return result.affectedRows;
}

module.exports = {
  create,
  findByToken,
  removeByToken,
  removeByUser,
};
