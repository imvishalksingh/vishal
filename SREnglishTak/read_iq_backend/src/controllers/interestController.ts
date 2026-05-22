import { type Response } from 'express';
import { InterestService } from '../services/interestService.js';
import { type AuthRequest } from '../middleware/authMiddleware.js';

export class InterestController {
    static async getInterest(req: AuthRequest, res: Response) {
        try {
            const moduleTitle = req.params.moduleTitle as string;
            const userId = req.user.id;
            const data = await InterestService.getModuleInterest(userId, moduleTitle);
            res.json(data);
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async updateInterest(req: AuthRequest, res: Response) {
        try {
            const { moduleTitle, isNotified, isExcited } = req.body;
            const userId = req.user.id;
            
            if (!moduleTitle) {
                return res.status(400).json({ error: 'moduleTitle is required' });
            }

            const data = await InterestService.updateModuleInterest(userId, moduleTitle, isNotified, isExcited);
            res.json(data);
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }
}
