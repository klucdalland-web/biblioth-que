'use strict';

const bcrypt = require('bcryptjs');
const sendJson = require('../utils/sendJson');
const { AppError } = require('../middlewares/errorHandler');
const RepoAuth = require('../repositories/auth.repository');
const tokensRepo = require('../repositories/tokens.repository');
const { ROLES } = require('./auth.controller');

const SALT_ROUNDS = 10;

async function list(req, res) {
  const users = await RepoAuth.findAll();
  sendJson(res, 200, users, 'Liste des utilisateurs');
}

async function getById(req, res) {
  const id = Number(req.params.id);
  const user = await RepoAuth.findById(id);
  if (!user) throw new AppError('Utilisateur introuvable', 404);
  sendJson(res, 200, user, 'Utilisateur');
}

async function create(req, res) {
  const { nom, mail, password, role = 'bibliothecaire' } = req.body;

  if (!ROLES.includes(role)) {
    throw new AppError(`Rôle invalide (${ROLES.join(', ')})`, 400);
  }

  const existing = await RepoAuth.findByEmail(mail);
  if (existing) throw new AppError('Cet email est déjà utilisé', 409);

  const mot_de_passe_hash = await bcrypt.hash(password, SALT_ROUNDS);
  const user = await RepoAuth.create({
    nom,
    email: mail,
    mot_de_passe_hash,
    role,
  });

  sendJson(res, 201, user, 'Utilisateur créé');
}

async function update(req, res) {
  const id = Number(req.params.id);
  const { nom, mail, role } = req.body;

  const current = await RepoAuth.findById(id);
  if (!current) throw new AppError('Utilisateur introuvable', 404);

  const isSelf = id === Number(req.user.id);
  if (isSelf && role && role !== current.role) {
    throw new AppError(
      'Vous ne pouvez pas modifier votre propre rôle',
      400
    );
  }

  const nextRole = isSelf ? current.role : role || current.role;
  if (!ROLES.includes(nextRole)) {
    throw new AppError(`Rôle invalide (${ROLES.join(', ')})`, 400);
  }

  const nextEmail = mail || current.email;
  if (nextEmail !== current.email) {
    const existing = await RepoAuth.findByEmail(nextEmail);
    if (existing) throw new AppError('Cet email est déjà utilisé', 409);
  }

  const user = await RepoAuth.update(id, {
    nom: nom || current.nom,
    email: nextEmail,
    role: nextRole,
  });

  sendJson(res, 200, user, 'Utilisateur mis à jour');
}

async function remove(req, res) {
  const id = Number(req.params.id);

  if (id === req.user.id) {
    throw new AppError('Vous ne pouvez pas supprimer votre propre compte', 400);
  }

  const current = await RepoAuth.findById(id);
  if (!current) throw new AppError('Utilisateur introuvable', 404);

  await tokensRepo.removeByUser(id);
  await RepoAuth.remove(id);

  sendJson(res, 200, null, 'Utilisateur supprimé');
}

module.exports = { list, getById, create, update, remove };
