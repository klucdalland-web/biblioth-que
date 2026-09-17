'use strict';

const sendJson = require('../utils/sendJson');
const { AppError } = require('../middlewares/errorHandler');
const livresRepo = require('../repositories/livres.repository');
const auteursRepo = require('../repositories/auteurs.repository');

async function list(req, res) {
  const { search, page, limit, statut, id_auteur } = req.query;
  const result = await livresRepo.findAll({
    search: search || undefined,
    statut: statut || undefined,
    id_auteur: id_auteur ? Number(id_auteur) : undefined,
    page: page ? Number(page) : 1,
    limit: limit ? Number(limit) : 10,
  });
  sendJson(res, 200, result, 'Liste des livres');
}

async function getOne(req, res) {
  const livre = await livresRepo.findById(Number(req.params.id));
  if (!livre) throw new AppError('Livre introuvable', 404);
  sendJson(res, 200, livre, 'Livre trouvé');
}

async function create(req, res) {
  const auteur = await auteursRepo.findById(req.body.id_auteur);
  if (!auteur) throw new AppError('Auteur introuvable', 404);

  const livre = await livresRepo.create(req.body);
  sendJson(res, 201, livre, 'Livre créé');
}

async function update(req, res) {
  const id = Number(req.params.id);
  const existing = await livresRepo.findById(id);
  if (!existing) throw new AppError('Livre introuvable', 404);

  if (req.body.id_auteur != null) {
    const auteur = await auteursRepo.findById(req.body.id_auteur);
    if (!auteur) throw new AppError('Auteur introuvable', 404);
  }

  const livre = await livresRepo.update(id, req.body);
  sendJson(res, 200, livre, 'Livre mis à jour');
}

async function remove(req, res) {
  const id = Number(req.params.id);
  const existing = await livresRepo.findById(id);
  if (!existing) throw new AppError('Livre introuvable', 404);

  try {
    await livresRepo.remove(id);
  } catch (err) {
    if (err.code === 'ER_ROW_IS_REFERENCED_2' || err.errno === 1451) {
      throw new AppError(
        'Impossible de supprimer : ce livre a encore des emprunts',
        409
      );
    }
    throw err;
  }

  sendJson(res, 200, null, 'Livre supprimé');
}

module.exports = { list, getOne, create, update, remove };
