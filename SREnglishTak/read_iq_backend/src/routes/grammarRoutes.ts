import { Router, type RequestHandler } from 'express';
import { GrammarController } from '../controllers/grammarController.js';
import { authenticate, authorizeAdmin } from '../middleware/authMiddleware.js';

const router = Router();

// Units
router.get('/units', GrammarController.getUnits as RequestHandler);
router.post('/units', authenticate as RequestHandler, authorizeAdmin as RequestHandler, GrammarController.createUnit as RequestHandler);
router.delete('/units/:id', authenticate as RequestHandler, authorizeAdmin as RequestHandler, GrammarController.deleteUnit as RequestHandler);

// Lessons
router.get('/units/:unitId/lessons', GrammarController.getLessons as RequestHandler);
router.post('/units/:unitId/lessons', authenticate as RequestHandler, authorizeAdmin as RequestHandler, GrammarController.createLesson as RequestHandler);
router.post('/units/:unitId/lessons/bulk', authenticate as RequestHandler, authorizeAdmin as RequestHandler, GrammarController.bulkCreateLessons as RequestHandler);
router.delete('/lessons/:lessonId', authenticate as RequestHandler, authorizeAdmin as RequestHandler, GrammarController.deleteLesson as RequestHandler);

// Progress
router.get('/progress', authenticate as RequestHandler, GrammarController.getProgress as RequestHandler);
router.post('/lessons/:lessonId/complete', authenticate as RequestHandler, GrammarController.markLessonCompleted as RequestHandler);

export default router;
