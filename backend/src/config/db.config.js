'use strict';

const mysql = require('mysql2/promise');
const env = require('./env');

const pool = mysql.createPool({
  host: env.db.host,
  port: env.db.port,
  user: env.db.user,
  password: env.db.password,
  database: env.db.database,
  waitForConnections: true,
  connectionLimit: 10,
  namedPlaceholders: true,
});

/**
 * Exécute une requête SQL paramétrée.
 * @param {string} sql
 * @param {object|array} [params]
 * @returns {Promise<[rows, fields]>}
 */
async function query(sql, params) {
  return pool.execute(sql, params);
}

/**
 * Récupère une connexion (ex. transactions).
 */
async function getConnection() {
  return pool.getConnection();
}

async function ping() {
  const conn = await pool.getConnection();
  try {
    await conn.ping();
  } finally {
    conn.release();
  }
}

module.exports = {
  pool,
  query,
  getConnection,
  ping,
};
