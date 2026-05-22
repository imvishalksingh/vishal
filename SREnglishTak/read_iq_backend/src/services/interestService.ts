import { supabaseAdmin } from '../config/supabase.js';

export class InterestService {
    static async getModuleInterest(userId: string, moduleTitle: string) {
        // Get the total excited count for this module
        const { count: excitedCount, error: countError } = await supabaseAdmin
            .from('module_interests')
            .select('*', { count: 'exact', head: true })
            .eq('module_title', moduleTitle)
            .eq('is_excited', true);

        if (countError) throw countError;

        // Get the current user's interest
        const { data: userInterest, error: userError } = await supabaseAdmin
            .from('module_interests')
            .select('is_notified, is_excited')
            .eq('user_id', userId)
            .eq('module_title', moduleTitle)
            .maybeSingle();

        if (userError) throw userError;

        return {
            excitedCount: excitedCount || 0,
            isNotified: userInterest?.is_notified ?? false,
            isExcited: userInterest?.is_excited ?? false
        };
    }

    static async updateModuleInterest(userId: string, moduleTitle: string, isNotified?: boolean, isExcited?: boolean) {
        // Fetch existing
        const { data: existing } = await supabaseAdmin
            .from('module_interests')
            .select('*')
            .eq('user_id', userId)
            .eq('module_title', moduleTitle)
            .maybeSingle();

        let dataToUpsert: any = {
            user_id: userId,
            module_title: moduleTitle,
            is_notified: isNotified ?? existing?.is_notified ?? false,
            is_excited: isExcited ?? existing?.is_excited ?? false,
        };

        if (existing) {
            dataToUpsert.id = existing.id;
        }

        const { data, error } = await supabaseAdmin
            .from('module_interests')
            .upsert(dataToUpsert, { onConflict: 'user_id, module_title' })
            .select()
            .single();

        if (error) throw error;
        
        // Return updated stats
        return await this.getModuleInterest(userId, moduleTitle);
    }
}
