import { type Request, type Response } from 'express';
import { AdminService } from '../services/adminService.js';

export class AdminController {
    static async getStats(req: Request, res: Response) {
        try {
            const stats = await AdminService.getStats();
            res.json(stats);
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async getUsers(req: Request, res: Response) {
        try {
            const users = await AdminService.getUsers();
            res.json(users);
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async getUserProgress(req: Request, res: Response) {
        try {
            const { userId } = req.params;
            if (!userId || typeof userId !== 'string') {
                console.error('[AdminController] Invalid or missing userId:', userId);
                return res.status(400).json({ error: 'Valid User ID is required' });
            }
            const progress = await AdminService.getUserProgress(userId);
            res.json(progress);
        } catch (error: any) {
            console.error('[AdminController] Error in getUserProgress:', error);
            res.status(500).json({ error: error.message || 'Internal server error' });
        }
    }
}
