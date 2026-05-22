import { type Request, type Response } from 'express';
import { VocabularyService } from '../services/vocabularyService.js';

export class VocabularyController {
    static async getAll(req: Request, res: Response) {
        try {
            const items = await VocabularyService.getAll();
            res.json(items);
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async create(req: Request, res: Response) {
        try {
            const item = await VocabularyService.create(req.body);
            res.status(201).json(item);
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async bulkCreate(req: Request, res: Response) {
        try {
            const items = await VocabularyService.bulkCreate(req.body.items);
            res.status(201).json(items);
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async delete(req: Request, res: Response) {
        try {
            await VocabularyService.delete(req.params.id as string);
            res.status(204).send();
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }
}
