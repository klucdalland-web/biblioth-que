'use strict';

const Router = require('../utils/router');
const { asyncHandler, authenticate } = require('../middlewares');
const statsController = require('../controllers/stats.controller');

const router = new Router();

router.get('/', authenticate, asyncHandler(statsController.getStats));

module.exports = router;
