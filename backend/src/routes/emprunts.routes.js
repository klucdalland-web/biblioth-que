'use strict';

const Router = require('../utils/router');
const {
  asyncHandler,
  authenticate,
  withBody,
  validate,
} = require('../middlewares');
const empruntsController = require('../controllers/emprunts.controller');

const router = new Router();

router.get('/', authenticate, asyncHandler(empruntsController.list));

// Avant /:id pour éviter le conflit
router.get('/retard', authenticate, asyncHandler(empruntsController.listRetard));

router.post(
  '/',
  authenticate,
  withBody,
  validate({
    id_adherent: { type: 'number', required: true },
    id_livre: { type: 'number', required: true },
    date_emprunt: { type: 'string', required: false },
    date_retour_prevue: { type: 'string', required: false },
  }),
  asyncHandler(empruntsController.create)
);

router.put(
  '/:id/retour',
  authenticate,
  withBody,
  validate({
    date_retour_reelle: { type: 'string', required: false },
  }),
  asyncHandler(empruntsController.retour)
);

module.exports = router;
