'use strict';

const { query } = require('../config/db.config');

async function findAll({ search, statut, id_auteur, page = 1, limit = 10 } = {}) {
  const params = {};
  const conditions = [];

  if (statut) {
    conditions.push('l.statut = :statut');
    params.statut = statut;
  }
  if (search) {
    conditions.push('(l.titre ILIKE :search OR a.nom ILIKE :search)');
    params.search = `%${search}%`;
  }
  if (id_auteur) {
    conditions.push('l.id_auteur = :id_auteur');
    params.id_auteur = id_auteur;
  }

  const where =
    conditions.length > 0 ? ` WHERE ${conditions.join(' AND ')}` : '';

  const [[countRow]] = await query(
    `SELECT COUNT(*)::int AS total
     FROM livres l
     JOIN auteurs a ON a.id_auteur = l.id_auteur
     ${where}`,
    params
  );

  const total = Number(countRow.total);
  const safePage = Math.max(1, Number(page) || 1);
  const safeLimit = Math.min(100, Math.max(1, Number(limit) || 10));
  const offset = (safePage - 1) * safeLimit;

  params.limit = safeLimit;
  params.offset = offset;

  const [rows] = await query(
    `SELECT l.id_livre, l.titre, l.annee_publication, l.id_auteur, l.statut,
            a.nom AS auteur_nom, a.nationalite AS auteur_nationalite
     FROM livres l
     JOIN auteurs a ON a.id_auteur = l.id_auteur
     ${where}
     ORDER BY l.titre ASC
     LIMIT :limit OFFSET :offset`,
    params
  );

  return {
    items: rows,
    pagination: {
      page: safePage,
      limit: safeLimit,
      total,
      totalPages: Math.ceil(total / safeLimit) || 1,
    },
  };
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
  const [, result] = await query(
    `INSERT INTO livres (titre, annee_publication, id_auteur, statut)
     VALUES (:titre, :annee_publication, :id_auteur, :statut)
     RETURNING id_livre`,
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
  await query(`UPDATE livres SET statut = :statut WHERE id_livre = :id`, {
    id,
    statut,
  });
  return findById(id);
}

async function remove(id) {
  const [, result] = await query(`DELETE FROM livres WHERE id_livre = :id`, {
    id,
  });
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
