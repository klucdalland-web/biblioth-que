'use strict';

const Router = require('../utils/router');
const {
    asyncHandler,
    withBody,
    validate,
    deviceKey,
    authenticate,
} = require('../middlewares');
const authController = require('../controllers/auth.controller');

const router = new Router();

router.post(
    '/register',
    deviceKey, withBody,
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
    deviceKey,
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