import { type Response } from 'express';
import { type AuthRequest } from '../middleware/authMiddleware.js';
import { supabase, supabaseAdmin } from '../config/supabase.js';
import { QuizService } from '../services/quizService.js';

export class QuizController {
    static async getAll(req: AuthRequest, res: Response) {
        try {
            const userId = req.user?.id;
            const quizzes = await QuizService.getAll(userId);
            res.json(quizzes);
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async getById(req: AuthRequest, res: Response) {
        try {
            const { data, error } = await supabase
                .from('quizzes')
                .select('*')
                .eq('id', req.params.id)
                .single();
            if (error) throw error;
            res.json(data);
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async create(req: AuthRequest, res: Response) {
        try {
            const { book_id, title, questions, type } = req.body;
            const quizType = type ?? (book_id ? 'book' : 'general');
            
            // 1. Create the quiz
            const { data: quiz, error: quizError } = await supabaseAdmin
                .from('quizzes')
                .insert({
                    book_id: quizType === 'general' ? null : book_id,
                    title,
                    type: quizType
                })
                .select()
                .single();
            
            if (quizError) throw quizError;

            // 2. Create the questions if provided
            if (questions && Array.isArray(questions) && questions.length > 0) {
                const questionsWithQuizId = questions.map(q => ({
                    ...q,
                    quiz_id: quiz.id
                }));
                
                const { error: questionsError } = await supabaseAdmin
                    .from('questions')
                    .insert(questionsWithQuizId);
                
                if (questionsError) throw questionsError;
            }

            res.status(201).json(quiz);
        } catch (error: any) {
            console.error('Quiz creation error:', error);
            res.status(500).json({ error: error.message });
        }
    }

    static async update(req: AuthRequest, res: Response) {
        try {
            const quiz = await QuizService.update(req.params.id as string, req.body);
            res.json(quiz);
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async delete(req: AuthRequest, res: Response) {
        try {
            const { error } = await supabaseAdmin
                .from('quizzes')
                .delete()
                .eq('id', req.params.id);
            if (error) throw error;
            res.json({ message: 'Quiz deleted successfully' });
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async submitAttempt(req: AuthRequest, res: Response) {
        try {
            const userId = req.user?.id;
            if (!userId) {
                return res.status(401).json({ error: 'Unauthorized' });
            }
            const { score } = req.body;
            const attempt = await QuizService.submitAttempt(userId, req.params.id as string, score);
            res.status(201).json(attempt);
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }
}
