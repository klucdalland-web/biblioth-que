'use strict';

const { query } = require('../config/db.config');

async function findByEmail(email) {
    const [rows] = await query(
        `SELECT id_utilisateur, nom, email, mot_de_passe_hash, role
     FROM utilisateurs
     WHERE email = :email`, { email }
    );
    return rows[0] || null;
}

async function findById(id) {
    const [rows] = await query(
        `SELECT id_utilisateur, nom, email, role
     FROM utilisateurs
     WHERE id_utilisateur = :id`, { id }
    );
    return rows[0] || null;
}

module.exports = {
    findByEmail,
    findById,
};