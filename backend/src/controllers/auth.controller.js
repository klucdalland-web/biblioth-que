'use strict';

const bcrypt = require('bcryptjs');
const sendJson = require('../utils/sendJson');
const env = require('../config/env');
const { AppError } = require('../middlewares/errorHandler');
const RepoAuth = require('../repositories/auth.repository');
const tokensRepo = require('../repositories/tokens.repository');
const authService = require('../services/auth.service');

const SALT_ROUNDS = 10;
const ROLES = ['bibliothecaire', 'admin'];

async function register(req, res) {
  const { nom, mail, password } = req.body;

  const existing = await RepoAuth.findByEmail(mail);
  if (existing) {
    throw new AppError('Cet email est déjà utilisé', 409);
  }

  const mot_de_passe_hash = await bcrypt.hash(password, SALT_ROUNDS);

  const user = await RepoAuth.create({
    nom,
    email: mail,
    mot_de_passe_hash,
  });

  const tokens = await authService.issueTokens(user);
  sendJson(res, 201, tokens, 'Compte créé');
}

async function login(req, res) {
  const { mail, password } = req.body;

  const user = await RepoAuth.findByEmail(mail);
  if (!user) {
    throw new AppError('Email ou mot de passe incorrect', 401);
  }

  const ok = await bcrypt.compare(password, user.mot_de_passe_hash);
  if (!ok) {
    throw new AppError('Email ou mot de passe incorrect', 401);
  }

  const tokens = await authService.issueTokens(user);
  sendJson(res, 200, tokens, 'Connecté');
}

async function refresh(req, res) {
  const { refreshToken } = req.body;

  const row = await tokensRepo.findByToken(refreshToken);
  if (!row) {
    throw new AppError('Refresh token invalide ou expiré', 401);
  }

  const user = await RepoAuth.findById(row.id_utilisateur);
  if (!user) {
    throw new AppError('Utilisateur introuvable', 401);
  }

  const accessToken = authService.signAccessToken(user);
  sendJson(
    res,
    200,
    { accessToken, expiresIn: env.jwt.expiresIn },
    'Token renouvelé'
  );
}

async function logout(req, res) {
  const { refreshToken } = req.body;

  await tokensRepo.removeByToken(refreshToken);
  sendJson(res, 200, null, 'Déconnecté');
}

async function me(req, res) {
  const user = await RepoAuth.findById(req.user.id);
  if (!user) throw new AppError('Utilisateur introuvable', 404);
  sendJson(res, 200, user, 'Profil');
}

async function updateMe(req, res) {
  const { nom, mail } = req.body;
  const id = req.user.id;

  const current = await RepoAuth.findById(id);
  if (!current) throw new AppError('Utilisateur introuvable', 404);

  if (mail && mail !== current.email) {
    const existing = await RepoAuth.findByEmail(mail);
    if (existing) throw new AppError('Cet email est déjà utilisé', 409);
  }

  const user = await RepoAuth.update(id, {
    nom: nom || current.nom,
    email: mail || current.email,
    role: current.role,
  });

  sendJson(res, 200, user, 'Profil mis à jour');
}

async function changePassword(req, res) {
  const { password_actuel, password, confirmation_mdp } = req.body;
  const id = req.user.id;

  if (password !== confirmation_mdp) {
    throw new AppError('Les mots de passe ne correspondent pas', 400);
  }

  const user = await RepoAuth.findByIdWithHash(id);
  if (!user) throw new AppError('Utilisateur introuvable', 404);

  const ok = await bcrypt.compare(password_actuel, user.mot_de_passe_hash);
  if (!ok) {
    throw new AppError('Mot de passe actuel incorrect', 401);
  }

  const mot_de_passe_hash = await bcrypt.hash(password, SALT_ROUNDS);
  await RepoAuth.updatePassword(id, mot_de_passe_hash);
  await tokensRepo.removeByUser(id);

  sendJson(res, 200, null, 'Mot de passe modifié');
}

module.exports = {
  login,
  register,
  refresh,
  logout,
  me,
  updateMe,
  changePassword,
  ROLES,
};
