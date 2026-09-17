'use strict';

const { query } = require('../config/db.config');

async function findAll({ en_cours, en_retard } = {}) {
  let sql = `
    SELECT e.id_emprunt, e.id_adherent, e.id_livre,
           e.date_emprunt, e.date_retour_prevue, e.date_retour_reelle,
           l.titre AS livre_titre,
           a.nom AS adherent_nom,
           CASE
             WHEN e.date_retour_reelle IS NOT NULL THEN 'retourne'
             WHEN e.date_retour_prevue < CURDATE() THEN 'en_retard'
             ELSE 'en_cours'
           END AS statut
    FROM emprunts e
    JOIN livres l ON l.id_livre = e.id_livre
    JOIN adherents a ON a.id_adherent = e.id_adherent
  `;
  const params = {};
  const conditions = [];

  if (en_cours) {
    conditions.push('e.date_retour_reelle IS NULL');
  }
  if (en_retard) {
    conditions.push(
      'e.date_retour_reelle IS NULL AND e.date_retour_prevue < CURDATE()'
    );
  }

  if (conditions.length > 0) {
    sql += ` WHERE ${conditions.join(' AND ')}`;
  }

  sql += ` ORDER BY e.date_emprunt DESC`;
  const [rows] = await query(sql, params);
  return rows;
}

async function findById(id) {
  const [rows] = await query(
    `SELECT e.id_emprunt, e.id_adherent, e.id_livre,
            e.date_emprunt, e.date_retour_prevue, e.date_retour_reelle,
            l.titre AS livre_titre,
            a.nom AS adherent_nom,
            CASE
              WHEN e.date_retour_reelle IS NOT NULL THEN 'retourne'
              WHEN e.date_retour_prevue < CURDATE() THEN 'en_retard'
              ELSE 'en_cours'
            END AS statut
     FROM emprunts e
     JOIN livres l ON l.id_livre = e.id_livre
     JOIN adherents a ON a.id_adherent = e.id_adherent
     WHERE e.id_emprunt = :id`,
    { id }
  );
  return rows[0] || null;
}

async function findActiveByLivreId(idLivre) {
  const [rows] = await query(
    `SELECT id_emprunt, id_adherent, id_livre,
            date_emprunt, date_retour_prevue, date_retour_reelle
     FROM emprunts
     WHERE id_livre = :idLivre AND date_retour_reelle IS NULL
     LIMIT 1`,
    { idLivre }
  );
  return rows[0] || null;
}

async function countActiveByAdherent(idAdherent) {
  const [rows] = await query(
    `SELECT COUNT(*) AS total
     FROM emprunts
     WHERE id_adherent = :idAdherent AND date_retour_reelle IS NULL`,
    { idAdherent }
  );
  return rows[0].total;
}

async function create({
  id_adherent,
  id_livre,
  date_emprunt,
  date_retour_prevue,
}) {
  const [result] = await query(
    `INSERT INTO emprunts
       (id_adherent, id_livre, date_emprunt, date_retour_prevue)
     VALUES
       (:id_adherent, :id_livre, :date_emprunt, :date_retour_prevue)`,
    { id_adherent, id_livre, date_emprunt, date_retour_prevue }
  );
  return findById(result.insertId);
}

async function markReturned(id, date_retour_reelle) {
  await query(
    `UPDATE emprunts
     SET date_retour_reelle = :date_retour_reelle
     WHERE id_emprunt = :id`,
    { id, date_retour_reelle }
  );
  return findById(id);
}

async function findOverdue() {
  const [rows] = await query(
    `SELECT e.id_emprunt, e.id_adherent, e.id_livre,
            e.date_emprunt, e.date_retour_prevue, e.date_retour_reelle,
            l.titre AS livre_titre,
            a.nom AS adherent_nom,
            DATEDIFF(CURDATE(), e.date_retour_prevue) AS jours_retard
     FROM emprunts e
     JOIN livres l ON l.id_livre = e.id_livre
     JOIN adherents a ON a.id_adherent = e.id_adherent
     WHERE e.date_retour_reelle IS NULL
       AND e.date_retour_prevue < CURDATE()
     ORDER BY e.date_retour_prevue ASC`
  );
  return rows;
}

module.exports = {
  findAll,
  findById,
  findActiveByLivreId,
  countActiveByAdherent,
  create,
  markReturned,
  findOverdue,
};
