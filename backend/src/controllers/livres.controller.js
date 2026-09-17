'use strict';

const sendJson = require('../utils/sendJson');

const livres = [
  { id: 1, titre: 'Les Misérables' },
  { id: 2, titre: "L'Étranger" },
];

function list(req, res) {
  sendJson(res, 200, livres, 'Liste des livres');
}

module.exports = { list };
