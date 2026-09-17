'use strict';
const Router = require('../utils/router');
const { asyncHandler } = require('../middlewares/errorHandler');
const livresController = require('../controllers/livres.controller');
const router = new Router();
// GET /api/livres
router.get('/', asyncHandler(livresController.list));
module.exports = router;