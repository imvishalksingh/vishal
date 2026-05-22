import { type Request, type Response } from 'express';
import { TipsService } from '../services/tipsService.js';

export class TipsController {
    static async getAll(req: Request, res: Response) {
        try {
            const items = await TipsService.getAll();
            res.json(items);
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async create(req: Request, res: Response) {
        try {
            const item = await TipsService.create(req.body);
            res.status(201).json(item);
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async delete(req: Request, res: Response) {
        try {
            await TipsService.delete(req.params.id as string);
            res.status(204).send();
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }
}
