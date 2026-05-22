import { Router } from 'express';
import { InterestController } from '../controllers/interestController.js';
import { authenticate } from '../middleware/authMiddleware.js';

const router = Router();

router.get('/:moduleTitle', authenticate as any, InterestController.getInterest as any);
router.post('/', authenticate as any, InterestController.updateInterest as any);

export default router;
