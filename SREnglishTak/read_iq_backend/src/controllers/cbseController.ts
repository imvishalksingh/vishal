import { type Request, type Response } from 'express';
import { CbseService } from '../services/cbseService.js';

export class CbseController {
    // Categories
    static async getCategories(req: Request, res: Response) {
        try {
            const items = await CbseService.getCategories();
            res.json(items);
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async createCategory(req: Request, res: Response) {
        try {
            const item = await CbseService.createCategory(req.body);
            res.status(201).json(item);
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async deleteCategory(req: Request, res: Response) {
        try {
            await CbseService.deleteCategory(req.params.id as string);
            res.status(204).send();
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    // Materials
    static async getMaterials(req: Request, res: Response) {
        try {
            const items = await CbseService.getMaterials(req.params.categoryId as string);
            res.json(items);
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async createMaterial(req: Request, res: Response) {
        try {
            const materialData = { ...req.body, category_id: req.params.categoryId };
            const item = await CbseService.createMaterial(materialData);
            res.status(201).json(item);
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async deleteMaterial(req: Request, res: Response) {
        try {
            await CbseService.deleteMaterial(req.params.materialId as string);
            res.status(204).send();
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }
}
