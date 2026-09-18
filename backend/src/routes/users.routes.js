'use strict';

const Router = require('../utils/router');
const {
  asyncHandler,
  withBody,
  validate,
  authenticate,
  requireAdmin,
} = require('../middlewares');
const usersController = require('../controllers/users.controller');

const router = new Router();

router.get(
  '/',
  authenticate,
  requireAdmin,
  asyncHandler(usersController.list)
);
router.get(
  '/:id',
  authenticate,
  requireAdmin,
  asyncHandler(usersController.getById)
);

router.post(
  '/',
  authenticate,
  requireAdmin,
  withBody,
  validate({
    nom: { type: 'string', required: true, min: 2 },
    mail: { type: 'string', required: true },
    password: { type: 'string', required: true, min: 6 },
    role: { type: 'string', required: false },
  }),
  asyncHandler(usersController.create)
);

router.put(
  '/:id',
  authenticate,
  requireAdmin,
  withBody,
  validate({
    nom: { type: 'string', required: false, min: 2 },
    mail: { type: 'string', required: false },
    role: { type: 'string', required: false },
  }),
  asyncHandler(usersController.update)
);

router.delete(
  '/:id',
  authenticate,
  requireAdmin,
  asyncHandler(usersController.remove)
);

module.exports = router;
