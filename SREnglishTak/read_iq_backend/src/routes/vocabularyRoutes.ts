import { Router, type RequestHandler } from 'express';
import { VocabularyController } from '../controllers/vocabularyController.js';
import { authenticate, authorizeAdmin } from '../middleware/authMiddleware.js';

const router = Router();

router.get('/', VocabularyController.getAll as RequestHandler);
router.post('/', authenticate as RequestHandler, authorizeAdmin as RequestHandler, VocabularyController.create as RequestHandler);
router.post('/bulk', authenticate as RequestHandler, authorizeAdmin as RequestHandler, VocabularyController.bulkCreate as RequestHandler);
router.delete('/:id', authenticate as RequestHandler, authorizeAdmin as RequestHandler, VocabularyController.delete as RequestHandler);

export default router;
