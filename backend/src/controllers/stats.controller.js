'use strict';

const sendJson = require('../utils/sendJson');
const statsRepo = require('../repositories/stats.repository');

async function getStats(req, res) {
  const [counts, top_livres, top_adherents] = await Promise.all([
    statsRepo.counts(),
    statsRepo.topLivres(5),
    statsRepo.topAdherents(5),
  ]);

  sendJson(
    res,
    200,
    { ...counts, top_livres, top_adherents },
    'Statistiques'
  );
}

module.exports = { getStats };
