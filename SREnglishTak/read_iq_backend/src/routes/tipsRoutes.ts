import { Router, type RequestHandler } from 'express';
import { TipsController } from '../controllers/tipsController.js';
import { authenticate, authorizeAdmin } from '../middleware/authMiddleware.js';

const router = Router();

router.get('/', TipsController.getAll as RequestHandler);
router.post('/', authenticate as RequestHandler, authorizeAdmin as RequestHandler, TipsController.create as RequestHandler);
router.delete('/:id', authenticate as RequestHandler, authorizeAdmin as RequestHandler, TipsController.delete as RequestHandler);

export default router;
