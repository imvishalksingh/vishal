import { Router, type RequestHandler } from 'express';
import { QuizController } from '../controllers/quizController.js';
import { authenticate, authorizeAdmin } from '../middleware/authMiddleware.js';

const router = Router();

// Public / Auth
router.get('/', authenticate as RequestHandler, QuizController.getAll as RequestHandler);
router.get('/:id', QuizController.getById as RequestHandler);

// Admin
router.post('/', authenticate as RequestHandler, authorizeAdmin as RequestHandler, QuizController.create as RequestHandler);
router.patch('/:id', authenticate as RequestHandler, authorizeAdmin as RequestHandler, QuizController.update as RequestHandler);
router.delete('/:id', authenticate as RequestHandler, authorizeAdmin as RequestHandler, QuizController.delete as RequestHandler);

// User
router.post('/:id/submit', authenticate as RequestHandler, QuizController.submitAttempt as RequestHandler);

export default router;
