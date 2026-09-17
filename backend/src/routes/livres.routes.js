'use strict';

const Router = require('../utils/router');
const {
  asyncHandler,
  authenticate,
  withBody,
  validate,
} = require('../middlewares');
const livresController = require('../controllers/livres.controller');

const router = new Router();

router.get('/', authenticate, asyncHandler(livresController.list));

router.get('/:id', authenticate, asyncHandler(livresController.getOne));

router.post(
  '/',
  authenticate,
  withBody,
  validate({
    titre: { type: 'string', required: true, min: 1 },
    annee_publication: { type: 'number', required: false },
    id_auteur: { type: 'number', required: true },
    statut: {
      type: 'string',
      required: false,
      enum: ['disponible', 'emprunte'],
    },
  }),
  asyncHandler(livresController.create)
);

router.put(
  '/:id',
  authenticate,
  withBody,
  validate({
    titre: { type: 'string', required: false, min: 1 },
    annee_publication: { type: 'number', required: false },
    id_auteur: { type: 'number', required: false },
    statut: {
      type: 'string',
      required: false,
      enum: ['disponible', 'emprunte'],
    },
  }),
  asyncHandler(livresController.update)
);

router.delete('/:id', authenticate, asyncHandler(livresController.remove));

module.exports = router;
