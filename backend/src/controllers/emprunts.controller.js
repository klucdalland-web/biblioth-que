'use strict';

const sendJson = require('../utils/sendJson');
const { AppError } = require('../middlewares/errorHandler');
const empruntsRepo = require('../repositories/emprunts.repository');
const livresRepo = require('../repositories/livres.repository');
const adherentsRepo = require('../repositories/adherents.repository');

const MAX_EMPRUNTS_ACTIFS = 3;
const DUREE_EMPRUNT_JOURS = 14;

function todayYmd() {
  return new Date().toISOString().slice(0, 10);
}

function addDaysYmd(days) {
  const d = new Date();
  d.setDate(d.getDate() + days);
  return d.toISOString().slice(0, 10);
}

async function list(req, res) {
  const emprunts = await empruntsRepo.findAll();
  sendJson(res, 200, emprunts, 'Liste des emprunts');
}

async function listRetard(req, res) {
  const emprunts = await empruntsRepo.findOverdue();
  sendJson(res, 200, emprunts, 'Emprunts en retard');
}

async function create(req, res) {
  const { id_adherent, id_livre, date_emprunt, date_retour_prevue } = req.body;

  const adherent = await adherentsRepo.findById(id_adherent);
  if (!adherent) throw new AppError('Adhérent introuvable', 404);

  const livre = await livresRepo.findById(id_livre);
  if (!livre) throw new AppError('Livre introuvable', 404);

  if (livre.statut !== 'disponible') {
    throw new AppError("Ce livre n'est pas disponible", 409);
  }

  const actif = await empruntsRepo.findActiveByLivreId(id_livre);
  if (actif) {
    throw new AppError('Ce livre est déjà emprunté', 409);
  }

  const nbActifs = await empruntsRepo.countActiveByAdherent(id_adherent);
  if (nbActifs >= MAX_EMPRUNTS_ACTIFS) {
    throw new AppError(
      `Cet adhérent a déjà ${MAX_EMPRUNTS_ACTIFS} emprunts en cours`,
      409
    );
  }

  const emprunt = await empruntsRepo.create({
    id_adherent,
    id_livre,
    date_emprunt: date_emprunt || todayYmd(),
    date_retour_prevue: date_retour_prevue || addDaysYmd(DUREE_EMPRUNT_JOURS),
  });

  await livresRepo.setStatut(id_livre, 'emprunte');

  sendJson(res, 201, emprunt, 'Emprunt créé');
}

async function retour(req, res) {
  const id = Number(req.params.id);
  const emprunt = await empruntsRepo.findById(id);

  if (!emprunt) throw new AppError('Emprunt introuvable', 404);
  if (emprunt.date_retour_reelle) {
    throw new AppError('Cet emprunt est déjà retourné', 409);
  }

  const date_retour_reelle = req.body?.date_retour_reelle || todayYmd();
  const updated = await empruntsRepo.markReturned(id, date_retour_reelle);
  await livresRepo.setStatut(emprunt.id_livre, 'disponible');

  sendJson(res, 200, updated, 'Livre retourné');
}

module.exports = { list, listRetard, create, retour };
