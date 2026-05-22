import { supabaseAdmin } from '../config/supabase.js';

export class AdminService {
    static async getStats() {
        const now = new Date();
        const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate()).toISOString();
        const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000).toISOString();

        const [
            { count: totalBooks },
            { count: totalProfiles },
            { count: totalQuizzes },
            { count: totalReadingSessions },
            { count: completedBooksCount },
            { data: readingSessions },
            { data: quizResults },
            { data: quizzes }
        ] = await Promise.all([
            supabaseAdmin.from('books').select('*', { count: 'exact', head: true }),
            supabaseAdmin.from('profiles').select('*', { count: 'exact', head: true }),
            supabaseAdmin.from('quizzes').select('*', { count: 'exact', head: true }),
            supabaseAdmin.from('reading_sessions').select('*', { count: 'exact', head: true }),
            supabaseAdmin.from('user_progress').select('*', { count: 'exact', head: true }).eq('is_completed', true),
            supabaseAdmin.from('reading_sessions').select('user_id, minutes_spent, started_at'),
            supabaseAdmin.from('quiz_results').select('score, completed_at'),
            supabaseAdmin.from('quizzes').select('type')
        ]);

        const sessions = readingSessions || [];
        const results = quizResults || [];
        const quizRows = quizzes || [];

        const activeReadersSet = new Set(
            sessions
                .filter((session) => session.user_id)
                .map((session) => session.user_id)
        );

        const activeReaders7dSet = new Set(
            sessions
                .filter((session) => session.user_id && session.started_at && session.started_at >= sevenDaysAgo)
                .map((session) => session.user_id)
        );

        const readingMinutesToday = sessions
            .filter((session) => session.started_at && session.started_at >= todayStart)
            .reduce((sum, session) => sum + (session.minutes_spent || 0), 0);

        const quizAttempts = results.length;
        const averageQuizScore = quizAttempts > 0
            ? results.reduce((sum, result) => sum + (result.score || 0), 0) / quizAttempts
            : 0;

        const generalQuizzes = quizRows.filter((quiz) => quiz.type === 'general').length;
        const bookQuizzes = quizRows.filter((quiz) => quiz.type !== 'general').length;

        return {
            total_books: totalBooks || 0,
            total_users: totalProfiles || 0,
            total_quizzes: totalQuizzes || 0,
            active_readers: activeReadersSet.size,
            total_reading_sessions: totalReadingSessions || 0,
            reading_minutes_today: readingMinutesToday,
            active_readers_7d: activeReaders7dSet.size,
            completed_books: completedBooksCount || 0,
            quiz_attempts: quizAttempts,
            average_quiz_score: Number(averageQuizScore.toFixed(1)),
            general_quizzes: generalQuizzes,
            book_quizzes: bookQuizzes
        };
    }

    static async getUsers() {
        const { data, error } = await supabaseAdmin
            .from('profiles')
            .select('id, email, full_name, avatar_url, role, created_at, class, learning_goal')
            .order('created_at', { ascending: false });
        if (error) throw error;
        return data || [];
    }

    static async getUserProgress(userId: string) {
        const [
            progressResult,
            sessionsResult,
            quizResultsResult
        ] = await Promise.all([
            supabaseAdmin
                .from('user_progress')
                .select('*, books(title, author, cover_url)')
                .eq('user_id', userId)
                .order('last_read_at', { ascending: false }),
            supabaseAdmin
                .from('reading_sessions')
                .select('*')
                .eq('user_id', userId)
                .order('started_at', { ascending: false }),
            supabaseAdmin
                .from('quiz_results')
                .select('*, quizzes(title, type)')
                .eq('user_id', userId)
                .order('completed_at', { ascending: false })
        ]);

        if (progressResult.error) {
            console.error('[AdminService] Error fetching book progress:', progressResult.error);
            throw new Error(`Book progress fetch failed: ${progressResult.error.message}`);
        }
        if (sessionsResult.error) {
            console.error('[AdminService] Error fetching reading sessions:', sessionsResult.error);
            throw new Error(`Reading sessions fetch failed: ${sessionsResult.error.message}`);
        }
        if (quizResultsResult.error) {
            console.error('[AdminService] Error fetching quiz results:', quizResultsResult.error);
            throw new Error(`Quiz results fetch failed: ${quizResultsResult.error.message}`);
        }

        const progress = progressResult.data || [];
        const sessions = sessionsResult.data || [];
        const results = quizResultsResult.data || [];

        const totalMinutes = sessions.reduce((sum, s) => sum + (s.minutes_spent || 0), 0);
        
        return {
            book_progress: progress,
            reading_sessions: sessions.slice(0, 20), // Last 20 sessions
            quiz_results: results,
            total_reading_minutes: totalMinutes,
            active_reading_days: new Set(sessions.map(s => s.started_at?.split('T')[0])).size
        };
    }
}
