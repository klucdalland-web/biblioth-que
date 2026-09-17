'use strict';

const Router = require('../utils/router');
const {
  asyncHandler,
  authenticate,
  withBody,
  validate,
} = require('../middlewares');
const auteursController = require('../controllers/auteurs.controller');

const router = new Router();

router.get('/', authenticate, asyncHandler(auteursController.list));

router.get('/:id', authenticate, asyncHandler(auteursController.getOne));

router.post(
  '/',
  authenticate,
  withBody,
  validate({
    nom: { type: 'string', required: true, min: 1 },
    nationalite: { type: 'string', required: false },
  }),
  asyncHandler(auteursController.create)
);

router.put(
  '/:id',
  authenticate,
  withBody,
  validate({
    nom: { type: 'string', required: false, min: 1 },
    nationalite: { type: 'string', required: false },
  }),
  asyncHandler(auteursController.update)
);

router.delete('/:id', authenticate, asyncHandler(auteursController.remove));

module.exports = router;
