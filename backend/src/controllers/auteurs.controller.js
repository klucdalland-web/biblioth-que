'use strict';

const sendJson = require('../utils/sendJson');

const auteurs = [
  { id: 1, nom: 'Hugo', prenom: 'Victor' },
  { id: 2, nom: 'Camus', prenom: 'Albert' },
];

function list(req, res) {
  sendJson(res, 200, auteurs, 'Liste des auteurs');
}

function getOne(req, res) {
  const id = Number(req.params.id);
  const auteur = auteurs.find((a) => a.id === id);

  if (!auteur) {
    sendJson(res, 404, null, 'Auteur introuvable');
    return;
  }

  sendJson(res, 200, auteur, 'Auteur trouvé');
}

module.exports = { list, getOne };
