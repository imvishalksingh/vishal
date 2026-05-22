import { supabaseAdmin } from '../config/supabase.js';

type InsightSummary = {
    current_streak: number;
    longest_streak: number;
    reading_minutes_today: number;
    active_days: number;
    completed_books: number;
    quiz_attempts: number;
    total_sessions: number;
};

const ACHIEVEMENTS = [
    {
        code: 'first_session',
        title: 'First Session',
        description: 'Completed your first reading session.',
        isUnlocked: (summary: InsightSummary) => summary.total_sessions >= 1,
    },
    {
        code: 'quiz_starter',
        title: 'Quiz Starter',
        description: 'Completed your first quiz attempt.',
        isUnlocked: (summary: InsightSummary) => summary.quiz_attempts >= 1,
    },
    {
        code: 'book_finisher',
        title: 'Book Finisher',
        description: 'Completed your first book.',
        isUnlocked: (summary: InsightSummary) => summary.completed_books >= 1,
    },
    {
        code: 'streak_3',
        title: '3 Day Streak',
        description: 'Stayed active for 3 days in a row.',
        isUnlocked: (summary: InsightSummary) => summary.longest_streak >= 3,
    },
    {
        code: 'streak_7',
        title: '7 Day Streak',
        description: 'Stayed active for 7 days in a row.',
        isUnlocked: (summary: InsightSummary) => summary.longest_streak >= 7,
    },
];

export class AchievementService {
    static async syncAchievements(userId: string, summary: InsightSummary) {
        const unlocked = ACHIEVEMENTS
            .filter((achievement) => achievement.isUnlocked(summary))
            .map((achievement) => ({
                user_id: userId,
                code: achievement.code,
                title: achievement.title,
                description: achievement.description,
            }));

        if (unlocked.length === 0) {
            return [];
        }

        const { error } = await supabaseAdmin
            .from('user_achievements')
            .upsert(unlocked, { onConflict: 'user_id,code' });

        if (error) throw error;

        const { data, error: fetchError } = await supabaseAdmin
            .from('user_achievements')
            .select('*')
            .eq('user_id', userId)
            .order('unlocked_at', { ascending: false });

        if (fetchError) throw fetchError;
        return data || [];
    }

    static async getAchievements(userId: string) {
        const { data, error } = await supabaseAdmin
            .from('user_achievements')
            .select('*')
            .eq('user_id', userId)
            .order('unlocked_at', { ascending: false });

        if (error) throw error;
        return data || [];
    }
}
