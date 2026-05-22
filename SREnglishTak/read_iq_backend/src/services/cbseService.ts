import { supabaseAdmin } from '../config/supabase.js';

export class CbseService {
    // Categories
    static async getCategories() {
        const { data, error } = await supabaseAdmin
            .from('cbse_categories')
            .select('*')
            .order('order_index', { ascending: true });
        if (error) throw error;
        return data;
    }

    static async createCategory(categoryData: any) {
        const { data, error } = await supabaseAdmin
            .from('cbse_categories')
            .insert([categoryData])
            .select()
            .single();
        if (error) throw error;
        return data;
    }

    static async deleteCategory(id: string) {
        const { error } = await supabaseAdmin
            .from('cbse_categories')
            .delete()
            .eq('id', id);
        if (error) throw error;
        return true;
    }

    // Materials
    static async getMaterials(categoryId: string) {
        const { data, error } = await supabaseAdmin
            .from('cbse_materials')
            .select('*')
            .eq('category_id', categoryId)
            .order('created_at', { ascending: false });
        if (error) throw error;
        return data;
    }

    static async createMaterial(materialData: any) {
        const { data, error } = await supabaseAdmin
            .from('cbse_materials')
            .insert([materialData])
            .select()
            .single();
        if (error) throw error;
        return data;
    }

    static async deleteMaterial(id: string) {
        const { error } = await supabaseAdmin
            .from('cbse_materials')
            .delete()
            .eq('id', id);
        if (error) throw error;
        return true;
    }
}
