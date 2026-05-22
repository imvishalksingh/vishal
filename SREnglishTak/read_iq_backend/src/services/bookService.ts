import { supabaseAdmin } from '../config/supabase.js';

export class BookService {
    static async getAll() {
        const { data, error } = await supabaseAdmin
            .from('books')
            .select('*')
            .eq('is_visible', true);
        if (error) throw error;
        return data;
    }

    static async getAllAdmin() {
        const { data, error } = await supabaseAdmin
            .from('books')
            .select('*')
            .order('created_at', { ascending: false });
        if (error) throw error;
        return data;
    }

    static async getById(id: string) {
        const { data, error } = await supabaseAdmin
            .from('books')
            .select('*')
            .eq('id', id)
            .single();
        if (error) throw error;
        return data;
    }

    static async create(bookData: any) {
        const { data, error } = await supabaseAdmin
            .from('books')
            .insert([bookData])
            .select()
            .single();
        if (error) throw error;
        return data;
    }

    static async update(id: string, updateData: any) {
        const { data, error } = await supabaseAdmin
            .from('books')
            .update(updateData)
            .eq('id', id)
            .select()
            .single();
        if (error) throw error;
        return data;
    }

    static async delete(id: string) {
        const { error } = await supabaseAdmin
            .from('books')
            .delete()
            .eq('id', id);
        if (error) throw error;
        return true;
    }
}
