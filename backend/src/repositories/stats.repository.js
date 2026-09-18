'use strict';

const { query } = require('../config/db.config');

async function counts() {
  const [[auteurs]] = await query(
    `SELECT COUNT(*)::int AS total FROM auteurs`
  );
  const [[livres]] = await query(`SELECT COUNT(*)::int AS total FROM livres`);
  const [[disponibles]] = await query(
    `SELECT COUNT(*)::int AS total FROM livres WHERE statut = 'disponible'`
  );
  const [[adherents]] = await query(
    `SELECT COUNT(*)::int AS total FROM adherents`
  );
  const [[empruntsEnCours]] = await query(
    `SELECT COUNT(*)::int AS total FROM emprunts WHERE date_retour_reelle IS NULL`
  );
  const [[retards]] = await query(
    `SELECT COUNT(*)::int AS total FROM emprunts
     WHERE date_retour_reelle IS NULL AND date_retour_prevue < CURRENT_DATE`
  );

  return {
    auteurs: Number(auteurs.total),
    livres: Number(livres.total),
    livres_disponibles: Number(disponibles.total),
    adherents: Number(adherents.total),
    emprunts_en_cours: Number(empruntsEnCours.total),
    emprunts_en_retard: Number(retards.total),
  };
}

async function topLivres(limit = 5) {
  const [rows] = await query(
    `SELECT l.id_livre, l.titre, COUNT(e.id_emprunt)::int AS nb_emprunts
     FROM livres l
     JOIN emprunts e ON e.id_livre = l.id_livre
     GROUP BY l.id_livre, l.titre
     ORDER BY nb_emprunts DESC
     LIMIT :limit`,
    { limit: Number(limit) }
  );
  return rows;
}

async function topAdherents(limit = 5) {
  const [rows] = await query(
    `SELECT a.id_adherent, a.nom, COUNT(e.id_emprunt)::int AS nb_emprunts
     FROM adherents a
     JOIN emprunts e ON e.id_adherent = a.id_adherent
     GROUP BY a.id_adherent, a.nom
     ORDER BY nb_emprunts DESC
     LIMIT :limit`,
    { limit: Number(limit) }
  );
  return rows;
}

module.exports = {
  counts,
  topLivres,
  topAdherents,
};
