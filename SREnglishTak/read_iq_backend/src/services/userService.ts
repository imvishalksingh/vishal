import { supabaseAdmin } from '../config/supabase.js';
import { AchievementService } from './achievementService.js';

export class UserService {
    static async getInsightSummary(userId: string) {
        const [
            { data: sessions },
            { data: quizResults },
            { count: completedBooksCount },
        ] = await Promise.all([
            supabaseAdmin
                .from('reading_sessions')
                .select('started_at, minutes_spent')
                .eq('user_id', userId),
            supabaseAdmin
                .from('quiz_results')
                .select('completed_at')
                .eq('user_id', userId),
            supabaseAdmin
                .from('user_progress')
                .select('*', { count: 'exact', head: true })
                .eq('user_id', userId)
                .eq('is_completed', true),
        ]);

        const readingSessions = sessions || [];
        const quizAttempts = quizResults?.length || 0;
        const completedBooks = completedBooksCount || 0;
        const readingMinutesToday = this._getMinutesToday(readingSessions);
        const { currentStreak, longestStreak, activeDays } = this._getStreakStats(readingSessions);

        const summary = {
            current_streak: currentStreak,
            longest_streak: longestStreak,
            reading_minutes_today: readingMinutesToday,
            active_days: activeDays,
            completed_books: completedBooks,
            quiz_attempts: quizAttempts,
            total_sessions: readingSessions.length,
        };

        const achievements = await AchievementService.syncAchievements(userId, summary);

        return {
            ...summary,
            achievements_unlocked: achievements.length,
        };
    }

    static async getAchievements(userId: string) {
        const summary = await this.getInsightSummary(userId);
        const achievements = await AchievementService.getAchievements(userId);
        return {
            summary,
            achievements,
        };
    }

    static async getProgress(userId: string) {
        const { data, error } = await supabaseAdmin
            .from('user_progress')
            .select('*, books(*)')
            .eq('user_id', userId)
            .order('last_read_at', { ascending: false });
        if (error) throw error;
        return data;
    }

    static async getReadingSessions(userId: string, bookId?: string) {
        let query = supabaseAdmin
            .from('reading_sessions')
            .select('*')
            .eq('user_id', userId);
        if (bookId) {
            query = query.eq('book_id', bookId);
        }
        const { data, error } = await query.order('started_at', { ascending: false });
        if (error) throw error;
        return data;
    }

    static async updateProgress(
        userId: string,
        bookId: string,
        payload: {
            page: number;
            isCompleted?: boolean;
            progressPercent?: number;
            totalMinutesRead?: number;
            lastPosition?: string;
        }
    ) {
        const now = new Date().toISOString();
        const { data: existing } = await supabaseAdmin
            .from('user_progress')
            .select('*')
            .eq('user_id', userId)
            .eq('book_id', bookId)
            .maybeSingle();

        const nextTotalMinutes = (existing?.total_minutes_read ?? 0) + (payload.totalMinutesRead ?? 0);
        const resolvedProgressPercent = payload.progressPercent ?? existing?.progress_percent ?? 0;
        const resolvedPage = payload.page > 0 ? payload.page : (existing?.current_page ?? 0);

        const { data, error } = await supabaseAdmin
            .from('user_progress')
            .upsert({
                user_id: userId,
                book_id: bookId,
                current_page: resolvedPage,
                progress_percent: resolvedProgressPercent,
                is_completed: payload.isCompleted ?? existing?.is_completed ?? false,
                total_minutes_read: nextTotalMinutes,
                last_position: payload.lastPosition ?? existing?.last_position,
                last_opened_at: now,
                last_read_at: now,
                started_at: existing?.started_at ?? now,
                completed_at: payload.isCompleted ? now : existing?.completed_at ?? null,
            }, { onConflict: 'user_id, book_id' })
            .select()
            .single();
        if (error) throw error;
        return data;
    }

    static async startReadingSession(
        userId: string,
        bookId: string,
        payload: {
            startPage?: number;
            deviceType?: string;
            source?: string;
        }
    ) {
        const { data, error } = await supabaseAdmin
            .from('reading_sessions')
            .insert({
                user_id: userId,
                book_id: bookId,
                start_page: payload.startPage ?? 0,
                end_page: payload.startPage ?? 0,
                device_type: payload.deviceType,
                source: payload.source,
            })
            .select()
            .single();
        if (error) throw error;
        return data;
    }

    static async finishReadingSession(
        userId: string,
        sessionId: string,
        payload: {
            endPage?: number;
            minutesSpent?: number;
            pagesRead?: number;
            isCompleted?: boolean;
        }
    ) {
        const { data, error } = await supabaseAdmin
            .from('reading_sessions')
            .update({
                ended_at: new Date().toISOString(),
                end_page: payload.endPage ?? 0,
                minutes_spent: payload.minutesSpent ?? 0,
                pages_read: payload.pagesRead ?? 0,
                is_completed: payload.isCompleted ?? false,
            })
            .eq('id', sessionId)
            .eq('user_id', userId)
            .select()
            .single();
        if (error) throw error;
        return data;
    }

    static async getBookmarks(userId: string, bookId?: string) {
        let query = supabaseAdmin
            .from('bookmarks')
            .select('*')
            .eq('user_id', userId);
        if (bookId) {
            query = query.eq('book_id', bookId);
        }
        const { data, error } = await query.order('created_at', { ascending: false });
        if (error) throw error;
        return data;
    }

    static async createBookmark(
        userId: string,
        payload: {
            bookId: string;
            page?: number;
            position?: string;
            label?: string;
        }
    ) {
        const { data, error } = await supabaseAdmin
            .from('bookmarks')
            .insert({
                user_id: userId,
                book_id: payload.bookId,
                page: payload.page ?? 0,
                position: payload.position,
                label: payload.label,
            })
            .select()
            .single();
        if (error) throw error;
        return data;
    }

    static async deleteBookmark(userId: string, bookmarkId: string) {
        const { error } = await supabaseAdmin
            .from('bookmarks')
            .delete()
            .eq('id', bookmarkId)
            .eq('user_id', userId);
        if (error) throw error;
    }

    static async getNotes(userId: string, bookId?: string) {
        let query = supabaseAdmin
            .from('notes')
            .select('*')
            .eq('user_id', userId);
        if (bookId) {
            query = query.eq('book_id', bookId);
        }
        const { data, error } = await query.order('updated_at', { ascending: false });
        if (error) throw error;
        return data;
    }

    static async createNote(
        userId: string,
        payload: {
            bookId: string;
            noteText: string;
            page?: number;
            position?: string;
        }
    ) {
        const now = new Date().toISOString();
        const { data, error } = await supabaseAdmin
            .from('notes')
            .insert({
                user_id: userId,
                book_id: payload.bookId,
                page: payload.page ?? 0,
                position: payload.position,
                note_text: payload.noteText,
                updated_at: now,
            })
            .select()
            .single();
        if (error) throw error;
        return data;
    }

    static async deleteNote(userId: string, noteId: string) {
        const { error } = await supabaseAdmin
            .from('notes')
            .delete()
            .eq('id', noteId)
            .eq('user_id', userId);
        if (error) throw error;
    }

    static async updateProfile(userId: string, payload: { full_name?: string; avatar_url?: string; class?: string; learning_goal?: string }) {
        const { data, error } = await supabaseAdmin
            .from('profiles')
            .update(payload)
            .eq('id', userId)
            .select()
            .single();
        if (error) throw error;
        return data;
    }

    private static _getMinutesToday(sessions: Array<{ started_at?: string; minutes_spent?: number }>) {
        const now = new Date();
        const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime();
        return sessions
            .filter((session): session is { started_at: string; minutes_spent?: number } =>
                typeof session.started_at === 'string'
            )
            .filter((session) => new Date(session.started_at).getTime() >= todayStart)
            .reduce((sum, session) => sum + (session.minutes_spent || 0), 0);
    }

    private static _getStreakStats(sessions: Array<{ started_at?: string }>) {
        const datedSessions = sessions.filter(
            (session): session is { started_at: string } =>
                typeof session.started_at === 'string'
        );
        const dayKeys = Array.from(new Set(
            datedSessions
                .map((session) => new Date(session.started_at).toISOString().slice(0, 10))
        )).sort();

        if (dayKeys.length === 0) {
            return { currentStreak: 0, longestStreak: 0, activeDays: 0 };
        }

        let longestStreak = 1;
        let running = 1;

        for (let i = 1; i < dayKeys.length; i++) {
            const prevKey = dayKeys[i - 1];
            const currentKey = dayKeys[i];
            if (!prevKey || !currentKey) {
                continue;
            }
            const prev = new Date(prevKey);
            const current = new Date(currentKey);
            const diffDays = Math.round((current.getTime() - prev.getTime()) / (1000 * 60 * 60 * 24));
            if (diffDays === 1) {
                running += 1;
                longestStreak = Math.max(longestStreak, running);
            } else {
                running = 1;
            }
        }

        let currentStreak = 0;
        let cursor = new Date();
        while (true) {
            const key = cursor.toISOString().slice(0, 10);
            if (!dayKeys.includes(key)) break;
            currentStreak += 1;
            cursor = new Date(cursor.getTime() - 24 * 60 * 60 * 1000);
        }

        if (currentStreak == 0) {
            const yesterday = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString().slice(0, 10);
            if (dayKeys.includes(yesterday)) {
                cursor = new Date(Date.now() - 24 * 60 * 60 * 1000);
                while (true) {
                    const key = cursor.toISOString().slice(0, 10);
                    if (!dayKeys.includes(key)) break;
                    currentStreak += 1;
                    cursor = new Date(cursor.getTime() - 24 * 60 * 60 * 1000);
                }
            }
        }

        return {
            currentStreak,
            longestStreak,
            activeDays: dayKeys.length,
        };
    }
}
