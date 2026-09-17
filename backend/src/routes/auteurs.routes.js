'use strict';

const Router = require('../utils/router');
const { asyncHandler } = require('../middlewares/errorHandler');
const auteursController = require('../controllers/auteurs.controller');

const router = new Router();

// GET http://localhost:3000/api/auteurs
router.get('/', asyncHandler(auteursController.list));

// GET http://localhost:3000/api/auteurs/1
router.get('/:id', asyncHandler(auteursController.getOne));

module.exports = router;
