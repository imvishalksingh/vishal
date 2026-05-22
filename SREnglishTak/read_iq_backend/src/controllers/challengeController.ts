import { type Request, type Response } from 'express';
import { type AuthRequest } from '../middleware/authMiddleware.js';
import { supabase, supabaseAdmin } from '../config/supabase.js';

export class ChallengeController {
    static async getAll(req: AuthRequest, res: Response) {
        try {
            const userId = req.user?.id;
            
            const { data: challenges, error } = await supabase
                .from('challenges')
                .select(`
                    *,
                    challenge_questions (*)
                `);
            if (error) throw error;

            if (userId && challenges) {
                const { data: results } = await supabaseAdmin
                    .from('challenge_results')
                    .select('challenge_id')
                    .eq('user_id', userId);
                
                const submittedIds = new Set(results?.map(r => r.challenge_id) || []);
                
                const enriched = challenges.map(c => ({
                    ...c,
                    has_submitted: submittedIds.has(c.id)
                }));
                return res.json(enriched);
            }

            res.json(challenges);
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async getById(req: Request, res: Response) {
        try {
            const { data, error } = await supabase
                .from('challenges')
                .select(`
                    *,
                    challenge_questions (*)
                `)
                .eq('id', req.params.id)
                .single();
            if (error) throw error;
            res.json(data);
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async create(req: Request, res: Response) {
        try {
            const { name, description, prize_text, image_url, start_time, end_time, duration_minutes, questions } = req.body;
            
            // 1. Create the challenge
            const { data: challenge, error: challengeError } = await supabaseAdmin
                .from('challenges')
                .insert({
                    name,
                    description,
                    prize_text,
                    image_url,
                    start_time,
                    end_time,
                    duration_minutes
                })
                .select()
                .single();
            
            if (challengeError) throw challengeError;

            // 2. Create the questions if provided
            if (questions && Array.isArray(questions) && questions.length > 0) {
                const questionsWithId = questions.map(q => ({
                    ...q,
                    challenge_id: challenge.id
                }));
                
                const { error: questionsError } = await supabaseAdmin
                    .from('challenge_questions')
                    .insert(questionsWithId);
                
                if (questionsError) throw questionsError;
            }

            res.status(201).json(challenge);
        } catch (error: any) {
            console.error('Challenge creation error:', error);
            res.status(500).json({ error: error.message });
        }
    }

    static async delete(req: Request, res: Response) {
        try {
            const { error } = await supabaseAdmin
                .from('challenges')
                .delete()
                .eq('id', req.params.id);
            if (error) throw error;
            res.json({ message: 'Challenge deleted successfully' });
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
            const { score, time_taken_ms } = req.body;
            const challengeId = req.params.id;

            const { data, error } = await supabaseAdmin
                .from('challenge_results')
                .insert({
                    user_id: userId,
                    challenge_id: challengeId,
                    score,
                    time_taken_ms
                })
                .select()
                .single();

            if (error) throw error;
            res.status(201).json(data);
        } catch (error: any) {
            // Usually 23505 is unique violation in postgres (already submitted)
            if (error.code === '23505') {
                return res.status(400).json({ error: 'You have already submitted an attempt for this challenge.' });
            }
            res.status(500).json({ error: error.message });
        }
    }

    static async getLeaderboard(req: Request, res: Response) {
        try {
            const challengeId = req.params.id;
            
            // Supabase allows joins on FKs
            const { data, error } = await supabase
                .from('challenge_results')
                .select(`
                    id,
                    score,
                    time_taken_ms,
                    completed_at,
                    profiles (
                        id,
                        full_name,
                        avatar_url
                    )
                `)
                .eq('challenge_id', challengeId)
                // Order by score DESC, time_taken_ms ASC
                .order('score', { ascending: false })
                .order('time_taken_ms', { ascending: true });

            if (error) throw error;

            res.json(data);
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }
}
