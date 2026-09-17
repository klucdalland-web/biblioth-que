'use strict';

const Router = require('../utils/router');
const {
    asyncHandler,
    withBody,
    validate,
    deviceKey,
} = require('../middlewares');
const authController = require('../controllers/auth.controller');

const router = new Router();

router.post(
    '/register',
    withBody,
    validate({
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

module.exports = router;