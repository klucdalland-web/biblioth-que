'use strict';

const Router = require('../utils/router');
const {
  asyncHandler,
  withBody,
  validate,
  authenticate,
} = require('../middlewares');
const authController = require('../controllers/auth.controller');

const router = new Router();

router.get('/me', authenticate, asyncHandler(authController.me));

router.put(
  '/me',
  authenticate,
  withBody,
  validate({
    nom: { type: 'string', required: true, min: 2 },
    mail: { type: 'string', required: true },
  }),
  asyncHandler(authController.updateMe)
);

router.put(
  '/me/password',
  authenticate,
  withBody,
  validate({
    password_actuel: { type: 'string', required: true },
    password: { type: 'string', required: true, min: 6 },
    confirmation_mdp: { type: 'string', required: true, match: 'password' },
  }),
  asyncHandler(authController.changePassword)
);

router.post(
  '/register',
  withBody,
  validate({
    nom: { type: 'string', required: true, min: 2 },
    mail: { type: 'string', required: true },
    password: { type: 'string', required: true, min: 6 },
    confirmation_mdp: { type: 'string', required: true, match: 'password' },
  }),
  asyncHandler(authController.register)
);

router.post(
  '/login',
  withBody,
  validate({
    mail: { type: 'string', required: true },
    password: { type: 'string', required: true },
  }),
  asyncHandler(authController.login)
);

router.post(
  '/refresh',
  withBody,
  validate({
    refreshToken: { type: 'string', required: true },
  }),
  asyncHandler(authController.refresh)
);

router.post(
  '/logout',
  withBody,
  validate({
    refreshToken: { type: 'string', required: true },
  }),
  asyncHandler(authController.logout)
);

module.exports = router;
