import { supabase, supabaseAdmin } from '../config/supabase.js';

export class QuizService {
    static async getAll(userId?: string) {
        // 1. Fetch all quizzes with questions
        const { data: quizzes, error: quizzesError } = await supabaseAdmin
            .from('quizzes')
            .select('*, questions(*)')
            .order('created_at', { ascending: false });
        
        if (quizzesError) throw quizzesError;

        // 2. If userId is provided, check which quizzes they've submitted
        if (userId && quizzes) {
            const { data: results, error: resultsError } = await supabaseAdmin
                .from('quiz_results')
                .select('quiz_id')
                .eq('user_id', userId);
            
            if (resultsError) throw resultsError;

            const submittedQuizIds = new Set(results?.map(r => r.quiz_id));
            return quizzes.map(quiz => ({
                ...quiz,
                has_submitted: submittedQuizIds.has(quiz.id)
            }));
        }

        return quizzes?.map(quiz => ({ ...quiz, has_submitted: false })) || [];
    }

    static async update(id: string, data: any) {
        const { questions, ...quizData } = data;

        // 1. Update quiz basic info
        if (Object.keys(quizData).length > 0) {
            const { error: quizError } = await supabaseAdmin
                .from('quizzes')
                .update(quizData)
                .eq('id', id);
            if (quizError) throw quizError;
        }

        // 2. Update questions if provided
        if (questions && Array.isArray(questions)) {
            // Delete existing questions
            const { error: deleteError } = await supabaseAdmin
                .from('questions')
                .delete()
                .eq('quiz_id', id);
            if (deleteError) throw deleteError;

            // Insert new questions
            const questionsWithQuizId = questions.map(q => ({
                ...q,
                quiz_id: id
            }));
            const { error: insertError } = await supabaseAdmin
                .from('questions')
                .insert(questionsWithQuizId);
            if (insertError) throw insertError;
        }

        return this.getById(id);
    }

    static async getById(id: string) {
        const { data, error } = await supabaseAdmin
            .from('quizzes')
            .select('*, questions(*)')
            .eq('id', id)
            .single();
        if (error) throw error;
        return data;
    }

    static async submitAttempt(userId: string, quizId: string, score: number) {
        // Use supabaseAdmin to bypass RLS for server-side insertion
        const { data, error } = await supabaseAdmin
            .from('quiz_results')
            .insert([{ user_id: userId, quiz_id: quizId, score }])
            .select()
            .single();
        
        if (error) {
            console.error('Error submitting quiz attempt:', error);
            throw error;
        }
        return data;
    }
}
