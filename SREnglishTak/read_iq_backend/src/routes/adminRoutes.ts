import { Router, type RequestHandler } from 'express';
import { AdminController } from '../controllers/adminController.js';
import { authenticate, authorizeAdmin } from '../middleware/authMiddleware.js';

const router = Router();

router.get('/stats', authenticate as RequestHandler, authorizeAdmin as RequestHandler, AdminController.getStats as RequestHandler);
router.get('/users', authenticate as RequestHandler, authorizeAdmin as RequestHandler, AdminController.getUsers as RequestHandler);
router.get('/users/:userId/progress', authenticate as RequestHandler, authorizeAdmin as RequestHandler, AdminController.getUserProgress as RequestHandler);

export default router;
