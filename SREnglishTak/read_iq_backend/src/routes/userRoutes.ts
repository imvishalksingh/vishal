import { Router, type RequestHandler } from 'express';
import { UserController } from '../controllers/userController.js';
import { authenticate } from '../middleware/authMiddleware.js';

const router = Router();

// Middleware applied to all routes
router.use(authenticate as RequestHandler);

router.get('/progress', UserController.getProgress as unknown as RequestHandler);
router.post('/progress', UserController.updateProgress as unknown as RequestHandler);
router.get('/reading-sessions', UserController.getReadingSessions as unknown as RequestHandler);
router.post('/reading-sessions', UserController.startReadingSession as unknown as RequestHandler);
router.patch('/reading-sessions/:id', UserController.finishReadingSession as unknown as RequestHandler);
router.get('/bookmarks', UserController.getBookmarks as unknown as RequestHandler);
router.post('/bookmarks', UserController.createBookmark as unknown as RequestHandler);
router.delete('/bookmarks/:id', UserController.deleteBookmark as unknown as RequestHandler);
router.get('/notes', UserController.getNotes as unknown as RequestHandler);
router.post('/notes', UserController.createNote as unknown as RequestHandler);
router.delete('/notes/:id', UserController.deleteNote as unknown as RequestHandler);
router.get('/insights', UserController.getInsights as unknown as RequestHandler);
router.get('/achievements', UserController.getAchievements as unknown as RequestHandler);
router.get('/recommendations', UserController.getRecommendations as unknown as RequestHandler);
router.patch('/profile', UserController.updateProfile as unknown as RequestHandler);

export default router;
