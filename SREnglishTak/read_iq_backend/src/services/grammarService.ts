import { supabaseAdmin } from '../config/supabase.js';

export class GrammarService {
    // Units
    static async getUnits() {
        const { data, error } = await supabaseAdmin
            .from('grammar_units')
            .select('*')
            .order('unit_order', { ascending: true });
        if (error) throw error;
        return data;
    }

    static async createUnit(unitData: any) {
        const { data, error } = await supabaseAdmin
            .from('grammar_units')
            .insert([unitData])
            .select()
            .single();
        if (error) throw error;
        return data;
    }

    static async deleteUnit(id: string) {
        const { error } = await supabaseAdmin
            .from('grammar_units')
            .delete()
            .eq('id', id);
        if (error) throw error;
        return true;
    }

    // Lessons
    static async getLessons(unitId: string) {
        const { data, error } = await supabaseAdmin
            .from('grammar_lessons')
            .select('*')
            .eq('unit_id', unitId)
            .order('lesson_order', { ascending: true });
        if (error) throw error;
        return data;
    }

    static async createLesson(lessonData: any) {
        const { data, error } = await supabaseAdmin
            .from('grammar_lessons')
            .insert([lessonData])
            .select()
            .single();
        if (error) throw error;
        return data;
    }

    static async bulkCreateLessons(lessonsData: any[]) {
        const { data, error } = await supabaseAdmin
            .from('grammar_lessons')
            .insert(lessonsData)
            .select();
        if (error) throw error;
        return data;
    }

    static async deleteLesson(id: string) {
        const { error } = await supabaseAdmin
            .from('grammar_lessons')
            .delete()
            .eq('id', id);
        if (error) throw error;
        return true;
    }

    // Progress
    static async getProgress(userId: string) {
        const { data, error } = await supabaseAdmin
            .from('grammar_progress')
            .select('*')
            .eq('user_id', userId);
        if (error) throw error;
        return data;
    }

    static async markLessonCompleted(userId: string, lessonId: string) {
        const { data, error } = await supabaseAdmin
            .from('grammar_progress')
            .upsert({
                user_id: userId,
                lesson_id: lessonId,
                is_completed: true,
                completed_at: new Date().toISOString()
            }, { onConflict: 'user_id, lesson_id' })
            .select()
            .single();
        if (error) throw error;
        return data;
    }
}
