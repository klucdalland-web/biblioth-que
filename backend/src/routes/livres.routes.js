'use strict';

const Router = require('../utils/router');
const { asyncHandler, authenticate } = require('../middlewares');
const livresController = require('../controllers/livres.controller');

const router = new Router();

router.get('/', authenticate, asyncHandler(livresController.list));

module.exports = router;
