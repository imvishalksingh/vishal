import { type Response } from 'express';
import { type AuthRequest } from '../middleware/authMiddleware.js';
import { UserService } from '../services/userService.js';
import { RecommendationService } from '../services/recommendationService.js';

export class UserController {
    static async getProgress(req: AuthRequest, res: Response) {
        try {
            const userId = req.user?.id;
            if (!userId) {
                return res.status(401).json({ error: 'Unauthorized' });
            }
            const progress = await UserService.getProgress(userId);
            return res.json(progress);
        } catch (error: any) {
            return res.status(500).json({ error: error.message });
        }
    }

    static async getReadingSessions(req: AuthRequest, res: Response) {
        try {
            const userId = req.user?.id;
            if (!userId) {
                return res.status(401).json({ error: 'Unauthorized' });
            }
            const bookId = typeof req.query.book_id === 'string' ? req.query.book_id : undefined;
            const sessions = await UserService.getReadingSessions(userId, bookId);
            return res.json(sessions);
        } catch (error: any) {
            return res.status(500).json({ error: error.message });
        }
    }

    static async updateProgress(req: AuthRequest, res: Response) {
        try {
            const userId = req.user?.id;
            if (!userId) {
                return res.status(401).json({ error: 'Unauthorized' });
            }
            const { book_id, page, current_page, is_completed, progress_percent, total_minutes_read, last_position } = req.body;
            const resolvedPage = typeof current_page === 'number' ? current_page : page;
            if (!book_id || typeof resolvedPage !== 'number') {
                return res.status(400).json({ error: 'Missing book_id or page' });
            }
            const payload: {
                page: number;
                isCompleted?: boolean;
                progressPercent?: number;
                totalMinutesRead?: number;
                lastPosition?: string;
            } = {
                page: resolvedPage,
            };

            if (typeof is_completed === 'boolean') {
                payload.isCompleted = is_completed;
            }
            if (typeof progress_percent === 'number') {
                payload.progressPercent = progress_percent;
            }
            if (typeof total_minutes_read === 'number') {
                payload.totalMinutesRead = total_minutes_read;
            }
            if (typeof last_position === 'string') {
                payload.lastPosition = last_position;
            }

            const progress = await UserService.updateProgress(userId, book_id, payload);
            return res.json(progress);
        } catch (error: any) {
            return res.status(500).json({ error: error.message });
        }
    }

    static async startReadingSession(req: AuthRequest, res: Response) {
        try {
            const userId = req.user?.id;
            if (!userId) {
                return res.status(401).json({ error: 'Unauthorized' });
            }
            const { book_id, start_page, device_type, source } = req.body;
            if (!book_id) {
                return res.status(400).json({ error: 'Missing book_id' });
            }
            const payload: {
                startPage?: number;
                deviceType?: string;
                source?: string;
            } = {};

            if (typeof start_page === 'number') {
                payload.startPage = start_page;
            }
            if (typeof device_type === 'string') {
                payload.deviceType = device_type;
            }
            if (typeof source === 'string') {
                payload.source = source;
            }

            const session = await UserService.startReadingSession(userId, book_id, payload);
            return res.status(201).json(session);
        } catch (error: any) {
            return res.status(500).json({ error: error.message });
        }
    }

    static async finishReadingSession(req: AuthRequest, res: Response) {
        try {
            const userId = req.user?.id;
            if (!userId) {
                return res.status(401).json({ error: 'Unauthorized' });
            }
            const { end_page, minutes_spent, pages_read, is_completed } = req.body;
            const sessionId = typeof req.params.id === 'string' ? req.params.id : undefined;
            if (!sessionId) {
                return res.status(400).json({ error: 'Missing session id' });
            }
            const session = await UserService.finishReadingSession(userId, sessionId, {
                endPage: typeof end_page === 'number' ? end_page : 0,
                minutesSpent: typeof minutes_spent === 'number' ? minutes_spent : 0,
                pagesRead: typeof pages_read === 'number' ? pages_read : 0,
                isCompleted: is_completed === true,
            });
            return res.json(session);
        } catch (error: any) {
            return res.status(500).json({ error: error.message });
        }
    }

    static async getBookmarks(req: AuthRequest, res: Response) {
        try {
            const userId = req.user?.id;
            if (!userId) {
                return res.status(401).json({ error: 'Unauthorized' });
            }
            const bookId = typeof req.query.book_id === 'string' ? req.query.book_id : undefined;
            const bookmarks = await UserService.getBookmarks(userId, bookId);
            return res.json(bookmarks);
        } catch (error: any) {
            return res.status(500).json({ error: error.message });
        }
    }

    static async createBookmark(req: AuthRequest, res: Response) {
        try {
            const userId = req.user?.id;
            if (!userId) {
                return res.status(401).json({ error: 'Unauthorized' });
            }
            const { book_id, page, position, label } = req.body;
            if (!book_id) {
                return res.status(400).json({ error: 'Missing book_id' });
            }
            const payload: {
                bookId: string;
                page?: number;
                position?: string;
                label?: string;
            } = { bookId: book_id };
            if (typeof page === 'number') payload.page = page;
            if (typeof position === 'string') payload.position = position;
            if (typeof label === 'string') payload.label = label;
            const bookmark = await UserService.createBookmark(userId, payload);
            return res.status(201).json(bookmark);
        } catch (error: any) {
            return res.status(500).json({ error: error.message });
        }
    }

    static async deleteBookmark(req: AuthRequest, res: Response) {
        try {
            const userId = req.user?.id;
            if (!userId) {
                return res.status(401).json({ error: 'Unauthorized' });
            }
            const bookmarkId = typeof req.params.id === 'string' ? req.params.id : undefined;
            if (!bookmarkId) {
                return res.status(400).json({ error: 'Missing bookmark id' });
            }
            await UserService.deleteBookmark(userId, bookmarkId);
            return res.status(204).send();
        } catch (error: any) {
            return res.status(500).json({ error: error.message });
        }
    }

    static async getNotes(req: AuthRequest, res: Response) {
        try {
            const userId = req.user?.id;
            if (!userId) {
                return res.status(401).json({ error: 'Unauthorized' });
            }
            const bookId = typeof req.query.book_id === 'string' ? req.query.book_id : undefined;
            const notes = await UserService.getNotes(userId, bookId);
            return res.json(notes);
        } catch (error: any) {
            return res.status(500).json({ error: error.message });
        }
    }

    static async createNote(req: AuthRequest, res: Response) {
        try {
            const userId = req.user?.id;
            if (!userId) {
                return res.status(401).json({ error: 'Unauthorized' });
            }
            const { book_id, note_text, page, position } = req.body;
            if (!book_id || typeof note_text !== 'string' || !note_text.trim()) {
                return res.status(400).json({ error: 'Missing book_id or note_text' });
            }
            const payload: {
                bookId: string;
                noteText: string;
                page?: number;
                position?: string;
            } = {
                bookId: book_id,
                noteText: note_text.trim(),
            };
            if (typeof page === 'number') payload.page = page;
            if (typeof position === 'string') payload.position = position;
            const note = await UserService.createNote(userId, payload);
            return res.status(201).json(note);
        } catch (error: any) {
            return res.status(500).json({ error: error.message });
        }
    }

    static async deleteNote(req: AuthRequest, res: Response) {
        try {
            const userId = req.user?.id;
            if (!userId) {
                return res.status(401).json({ error: 'Unauthorized' });
            }
            const noteId = typeof req.params.id === 'string' ? req.params.id : undefined;
            if (!noteId) {
                return res.status(400).json({ error: 'Missing note id' });
            }
            await UserService.deleteNote(userId, noteId);
            return res.status(204).send();
        } catch (error: any) {
            return res.status(500).json({ error: error.message });
        }
    }

    static async getInsights(req: AuthRequest, res: Response) {
        try {
            const userId = req.user?.id;
            if (!userId) {
                return res.status(401).json({ error: 'Unauthorized' });
            }
            const insights = await UserService.getInsightSummary(userId);
            return res.json(insights);
        } catch (error: any) {
            return res.status(500).json({ error: error.message });
        }
    }

    static async getAchievements(req: AuthRequest, res: Response) {
        try {
            const userId = req.user?.id;
            if (!userId) {
                return res.status(401).json({ error: 'Unauthorized' });
            }
            const data = await UserService.getAchievements(userId);
            return res.json(data);
        } catch (error: any) {
            return res.status(500).json({ error: error.message });
        }
    }

    static async getRecommendations(req: AuthRequest, res: Response) {
        try {
            const userId = req.user?.id;
            if (!userId) {
                return res.status(401).json({ error: 'Unauthorized' });
            }
            const recommendations = await RecommendationService.getForUser(userId);
            return res.json(recommendations);
        } catch (error: any) {
            return res.status(500).json({ error: error.message });
        }
    }

    static async updateProfile(req: AuthRequest, res: Response) {
        try {
            const userId = req.user?.id;
            if (!userId) {
                return res.status(401).json({ error: 'Unauthorized' });
            }
            const { full_name, avatar_url, class: className, learning_goal } = req.body;
            const updated = await UserService.updateProfile(userId, { 
                full_name, 
                avatar_url, 
                class: className, 
                learning_goal 
            });
            return res.json(updated);
        } catch (error: any) {
            return res.status(500).json({ error: error.message });
        }
    }
}
