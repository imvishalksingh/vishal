import { Router, type RequestHandler } from 'express';
import { AuthController } from '../controllers/authController.js';
import { authenticate } from '../middleware/authMiddleware.js';

const router = Router();

router.post('/register', AuthController.register as RequestHandler);
router.post('/login', AuthController.login as RequestHandler);
router.post('/google', AuthController.googleSignIn as RequestHandler);
router.post('/refresh', AuthController.refreshToken as RequestHandler);
router.post('/forgot-password', AuthController.forgotPassword as RequestHandler);
router.post('/logout', authenticate as RequestHandler, AuthController.logout as unknown as RequestHandler);
router.get('/me', authenticate as RequestHandler, AuthController.getMe as unknown as RequestHandler);

export default router;
