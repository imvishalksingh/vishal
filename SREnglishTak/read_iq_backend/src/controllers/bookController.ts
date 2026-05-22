import { type Request, type Response } from 'express';
import { BookService } from '../services/bookService.js';

export class BookController {
    static async getAll(req: Request, res: Response) {
        try {
            const books = await BookService.getAll();
            res.json(books);
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async getAllAdmin(req: Request, res: Response) {
        try {
            const books = await BookService.getAllAdmin();
            res.json(books);
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async getById(req: Request, res: Response) {
        try {
            const book = await BookService.getById(req.params.id as string);
            if (!book) return res.status(404).json({ error: 'Book not found' });
            res.json(book);
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async create(req: Request, res: Response) {
        try {
            const book = await BookService.create(req.body);
            res.status(201).json(book);
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async update(req: Request, res: Response) {
        try {
            const book = await BookService.update(req.params.id as string, req.body);
            res.json(book);
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async delete(req: Request, res: Response) {
        try {
            await BookService.delete(req.params.id as string);
            res.status(204).send();
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }
}
