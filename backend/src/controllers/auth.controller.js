'use strict';

const sendJson = require('../utils/sendJson');
const RepoAuth = require('../repositories/auth.repository')

const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
// const usersRepository = require('../repositories/utilisateurs.repository');


async function login(req, res) {
    const body = req.body
        // const luc = await RepoAutheur.findAll(1)
        // console.log()
    const trouve = await RepoAuth.findByEmail(body.mail)

    if (!trouve) return sendJson(res, 404, null, "Email ou mot de passe incorrect")
    sendJson(res, 200, {

    }, 'user connecter');
}

function register(req, res) {
    sendJson(res, 200, {

    }, 'user authentifier');

}

module.exports = { login, register };