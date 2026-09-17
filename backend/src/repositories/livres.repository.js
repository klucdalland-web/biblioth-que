'use strict';

const { query } = require('../config/db.config');

async function findAll({ statut, titre, id_auteur } = {}) {
  let sql = `
    SELECT l.id_livre, l.titre, l.annee_publication, l.id_auteur, l.statut,
           a.nom AS auteur_nom, a.nationalite AS auteur_nationalite
    FROM livres l
    JOIN auteurs a ON a.id_auteur = l.id_auteur
  `;
  const params = {};
  const conditions = [];

  if (statut) {
    conditions.push('l.statut = :statut');
    params.statut = statut;
  }
  if (titre) {
    conditions.push('l.titre LIKE :titre');
    params.titre = `%${titre}%`;
  }
  if (id_auteur) {
    conditions.push('l.id_auteur = :id_auteur');
    params.id_auteur = id_auteur;
  }

  if (conditions.length > 0) {
    sql += ` WHERE ${conditions.join(' AND ')}`;
  }

  sql += ` ORDER BY l.titre ASC`;
  const [rows] = await query(sql, params);
  return rows;
}

async function findById(id) {
  const [rows] = await query(
    `SELECT l.id_livre, l.titre, l.annee_publication, l.id_auteur, l.statut,
            a.nom AS auteur_nom, a.nationalite AS auteur_nationalite
     FROM livres l
     JOIN auteurs a ON a.id_auteur = l.id_auteur
     WHERE l.id_livre = :id`,
    { id }
  );
  return rows[0] || null;
}

async function create({ titre, annee_publication, id_auteur, statut }) {
  const [result] = await query(
    `INSERT INTO livres (titre, annee_publication, id_auteur, statut)
     VALUES (:titre, :annee_publication, :id_auteur, :statut)`,
    {
      titre,
      annee_publication: annee_publication ?? null,
      id_auteur,
      statut: statut ?? 'disponible',
    }
  );
  return findById(result.insertId);
}

async function update(id, { titre, annee_publication, id_auteur, statut }) {
  await query(
    `UPDATE livres
     SET titre = COALESCE(:titre, titre),
         annee_publication = COALESCE(:annee_publication, annee_publication),
         id_auteur = COALESCE(:id_auteur, id_auteur),
         statut = COALESCE(:statut, statut)
     WHERE id_livre = :id`,
    {
      id,
      titre: titre ?? null,
      annee_publication: annee_publication ?? null,
      id_auteur: id_auteur ?? null,
      statut: statut ?? null,
    }
  );
  return findById(id);
}

async function setStatut(id, statut) {
  await query(
    `UPDATE livres SET statut = :statut WHERE id_livre = :id`,
    { id, statut }
  );
  return findById(id);
}

async function remove(id) {
  const [result] = await query(
    `DELETE FROM livres WHERE id_livre = :id`,
    { id }
  );
  return result.affectedRows > 0;
}

module.exports = {
  findAll,
  findById,
  create,
  update,
  setStatut,
  remove,
};
