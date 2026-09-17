'use strict';

const Router = require('../utils/router');
const {
    asyncHandler,
    authenticate,
    withBody,
    validate,
    deviceKey
} = require('../middlewares');
const adherentsController = require('../controllers/adherents.controller');

const router = new Router();

router.get('/', deviceKey, authenticate, asyncHandler(adherentsController.list));

router.get(
    '/:id/emprunts', deviceKey, authenticate, asyncHandler(adherentsController.listEmprunts)
);

router.get('/:id', authenticate, asyncHandler(adherentsController.getOne));

router.post(
    '/', deviceKey,
    authenticate,
    withBody,
    validate({
        nom: { type: 'string', required: true, min: 1 },
        contact: { type: 'string', required: true, min: 1 },
    }),
    asyncHandler(adherentsController.create)
);

router.put(
    '/:id',
    authenticate, deviceKey,
    withBody,
    validate({
        nom: { type: 'string', required: false, min: 1 },
        contact: { type: 'string', required: false, min: 1 },
    }),
    asyncHandler(adherentsController.update)
);

router.delete('/:id', authenticate, asyncHandler(adherentsController.remove));

module.exports = router;