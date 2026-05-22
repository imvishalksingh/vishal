import { Router } from 'express';
import { ChallengeController } from '../controllers/challengeController.js';
import { authenticate, authorizeAdmin } from '../middleware/authMiddleware.js';

const router = Router();

router.get('/', authenticate, ChallengeController.getAll);
router.get('/:id', ChallengeController.getById);
router.post('/', authenticate, authorizeAdmin, ChallengeController.create);
router.delete('/:id', authenticate, authorizeAdmin, ChallengeController.delete);
router.post('/:id/submit', authenticate, ChallengeController.submitAttempt);
router.get('/:id/leaderboard', ChallengeController.getLeaderboard);

export default router;
