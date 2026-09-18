'use strict';

const sendJson = require('../utils/sendJson');
const { AppError } = require('../middlewares/errorHandler');
const auteursRepo = require('../repositories/auteurs.repository');

async function list(req, res) {
  const auteurs = await auteursRepo.findAll();
  sendJson(res, 200, auteurs, 'Liste des auteurs');
}

async function getOne(req, res) {
  const auteur = await auteursRepo.findById(Number(req.params.id));
  if (!auteur) throw new AppError('Auteur introuvable', 404);
  sendJson(res, 200, auteur, 'Auteur trouvé');
}

async function create(req, res) {
  const auteur = await auteursRepo.create(req.body);
  sendJson(res, 201, auteur, 'Auteur créé');
}

async function update(req, res) {
  const id = Number(req.params.id);
  const existing = await auteursRepo.findById(id);
  if (!existing) throw new AppError('Auteur introuvable', 404);

  const auteur = await auteursRepo.update(id, req.body);
  sendJson(res, 200, auteur, 'Auteur mis à jour');
}

async function remove(req, res) {
  const id = Number(req.params.id);
  const existing = await auteursRepo.findById(id);
  if (!existing) throw new AppError('Auteur introuvable', 404);

  try {
    await auteursRepo.remove(id);
  } catch (err) {
    if (err.code === '23503') {
      throw new AppError(
        'Impossible de supprimer : cet auteur a encore des livres',
        409
      );
    }
    throw err;
  }

  sendJson(res, 200, null, 'Auteur supprimé');
}

module.exports = { list, getOne, create, update, remove };
