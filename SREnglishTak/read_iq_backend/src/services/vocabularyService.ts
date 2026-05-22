import { supabaseAdmin } from '../config/supabase.js';

export class VocabularyService {
    static async getAll() {
        const { data, error } = await supabaseAdmin
            .from('vocabulary')
            .select('*')
            .order('created_at', { ascending: false });
        if (error) throw error;
        return data;
    }

    static async create(vocabData: any) {
        const { data, error } = await supabaseAdmin
            .from('vocabulary')
            .insert([vocabData])
            .select()
            .single();
        if (error) throw error;
        return data;
    }

    static async bulkCreate(vocabDataArray: any[]) {
        const { data, error } = await supabaseAdmin
            .from('vocabulary')
            .insert(vocabDataArray)
            .select();
        if (error) throw error;
        return data;
    }

    static async delete(id: string) {
        const { error } = await supabaseAdmin
            .from('vocabulary')
            .delete()
            .eq('id', id);
        if (error) throw error;
        return true;
    }
}
