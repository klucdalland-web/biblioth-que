'use strict';

const { Pool } = require('pg');
const env = require('./env');

/**
 * Convertit les placeholders MySQL-style `:name` en `$1, $2, …` (PostgreSQL).
 */
function toPgParams(sql, params) {
  if (!params) {
    return { text: sql, values: [] };
  }

  if (Array.isArray(params)) {
    return { text: sql, values: params };
  }

  const values = [];
  // (?<!:) évite de confondre les casts Postgres (::int) avec :param
  const text = sql.replace(/(?<!:):([a-zA-Z_][a-zA-Z0-9_]*)/g, (_, key) => {
    if (!(key in params)) {
      throw new Error(`Paramètre SQL manquant: :${key}`);
    }
    values.push(params[key]);
    return `$${values.length}`;
  });

  return { text, values };
}

function buildPool() {
  if (env.db.connectionString) {
    return new Pool({
      connectionString: env.db.connectionString,
      ssl: env.db.ssl ? { rejectUnauthorized: false } : undefined,
      max: 10,
    });
  }

  return new Pool({
    host: env.db.host,
    port: env.db.port,
    user: env.db.user,
    password: env.db.password,
    database: env.db.database,
    ssl: env.db.ssl ? { rejectUnauthorized: false } : undefined,
    max: 10,
  });
}

const pool = buildPool();

/**
 * Exécute une requête SQL.
 * Retourne un tuple compatible mysql2 : [rows, result]
 * - result.insertId : premier champ id_* renvoyé (via RETURNING)
 * - result.affectedRows : rowCount
 */
function explainDbError(err) {
  if (err?.code === 'ENOTFOUND' || err?.code === 'EHOSTUNREACH') {
    err.message =
      `${err.message}\n` +
      '→ Utilise l’URI Session pooler Supabase (pas Direct db.xxx), ' +
      'et remplace YOUR_PASSWORD par le vrai mot de passe Database.';
  }
  return err;
}

async function query(sql, params) {
  const { text, values } = toPgParams(sql, params);
  let res;
  try {
    res = await pool.query(text, values);
  } catch (err) {
    throw explainDbError(err);
  }
  const rows = res.rows;

  let insertId;
  if (rows[0]) {
    const idKey = Object.keys(rows[0]).find((k) => k.startsWith('id_'));
    if (idKey) insertId = rows[0][idKey];
  }

  const result = {
    insertId,
    affectedRows: res.rowCount ?? 0,
  };

  return [rows, result];
}

async function getConnection() {
  return pool.connect();
}

async function ping() {
  await pool.query('SELECT 1');
}

module.exports = {
  pool,
  query,
  getConnection,
  ping,
};
