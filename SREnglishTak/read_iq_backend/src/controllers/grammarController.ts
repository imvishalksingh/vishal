import { type Request, type Response } from 'express';
import { GrammarService } from '../services/grammarService.js';

export class GrammarController {
    // Units
    static async getUnits(req: Request, res: Response) {
        try {
            const items = await GrammarService.getUnits();
            res.json(items);
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async createUnit(req: Request, res: Response) {
        try {
            const item = await GrammarService.createUnit(req.body);
            res.status(201).json(item);
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async deleteUnit(req: Request, res: Response) {
        try {
            await GrammarService.deleteUnit(req.params.id as string);
            res.status(204).send();
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    // Lessons
    static async getLessons(req: Request, res: Response) {
        try {
            const items = await GrammarService.getLessons(req.params.unitId as string);
            res.json(items);
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async createLesson(req: Request, res: Response) {
        try {
            const lessonData = { ...req.body, unit_id: req.params.unitId };
            const item = await GrammarService.createLesson(lessonData);
            res.status(201).json(item);
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async bulkCreateLessons(req: Request, res: Response) {
        try {
            const lessons = req.body.lessons.map((l: any) => ({ ...l, unit_id: req.params.unitId }));
            const items = await GrammarService.bulkCreateLessons(lessons);
            res.status(201).json(items);
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async deleteLesson(req: Request, res: Response) {
        try {
            await GrammarService.deleteLesson(req.params.lessonId as string);
            res.status(204).send();
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    // Progress
    static async getProgress(req: Request, res: Response) {
        try {
            const userId = (req as any).user.id;
            const items = await GrammarService.getProgress(userId);
            res.json(items);
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async markLessonCompleted(req: Request, res: Response) {
        try {
            const userId = (req as any).user.id;
            const lessonId = req.params.lessonId as string;
            const item = await GrammarService.markLessonCompleted(userId, lessonId);
            res.json(item);
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }
}
