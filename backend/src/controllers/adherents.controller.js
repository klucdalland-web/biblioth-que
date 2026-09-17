'use strict';

const sendJson = require('../utils/sendJson');
const { AppError } = require('../middlewares/errorHandler');
const adherentsRepo = require('../repositories/adherents.repository');
const empruntsRepo = require('../repositories/emprunts.repository');

async function list(req, res) {
  const adherents = await adherentsRepo.findAll();
  sendJson(res, 200, adherents, 'Liste des adhérents');
}

async function getOne(req, res) {
  const adherent = await adherentsRepo.findById(Number(req.params.id));
  if (!adherent) throw new AppError('Adhérent introuvable', 404);
  sendJson(res, 200, adherent, 'Adhérent trouvé');
}

async function create(req, res) {
  const adherent = await adherentsRepo.create(req.body);
  sendJson(res, 201, adherent, 'Adhérent créé');
}

async function update(req, res) {
  const id = Number(req.params.id);
  const existing = await adherentsRepo.findById(id);
  if (!existing) throw new AppError('Adhérent introuvable', 404);

  const adherent = await adherentsRepo.update(id, req.body);
  sendJson(res, 200, adherent, 'Adhérent mis à jour');
}

async function remove(req, res) {
  const id = Number(req.params.id);
  const existing = await adherentsRepo.findById(id);
  if (!existing) throw new AppError('Adhérent introuvable', 404);

  try {
    await adherentsRepo.remove(id);
  } catch (err) {
    if (err.code === 'ER_ROW_IS_REFERENCED_2' || err.errno === 1451) {
      throw new AppError(
        'Impossible de supprimer : cet adhérent a encore des emprunts',
        409
      );
    }
    throw err;
  }

  sendJson(res, 200, null, 'Adhérent supprimé');
}

async function listEmprunts(req, res) {
  const id = Number(req.params.id);
  const adherent = await adherentsRepo.findById(id);
  if (!adherent) throw new AppError('Adhérent introuvable', 404);

  const emprunts = await empruntsRepo.findByAdherentId(id);
  sendJson(res, 200, emprunts, "Emprunts de l'adherent");
}

module.exports = { list, getOne, create, update, remove, listEmprunts };
