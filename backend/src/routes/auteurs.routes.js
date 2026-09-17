'use strict';

const Router = require('../utils/router');
const { asyncHandler, authenticate } = require('../middlewares');
const auteursController = require('../controllers/auteurs.controller');

const router = new Router();

router.get('/', authenticate, asyncHandler(auteursController.list));
router.get('/:id', authenticate, asyncHandler(auteursController.getOne));

module.exports = router;
