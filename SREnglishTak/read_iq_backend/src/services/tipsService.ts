import { supabaseAdmin } from '../config/supabase.js';

export class TipsService {
    static async getAll() {
        const { data, error } = await supabaseAdmin
            .from('daily_tips')
            .select('*')
            .order('created_at', { ascending: false });
        if (error) throw error;
        return data;
    }

    static async create(tipData: any) {
        const { data, error } = await supabaseAdmin
            .from('daily_tips')
            .insert([tipData])
            .select()
            .single();
        if (error) throw error;
        return data;
    }

    static async delete(id: string) {
        const { error } = await supabaseAdmin
            .from('daily_tips')
            .delete()
            .eq('id', id);
        if (error) throw error;
        return true;
    }
}
