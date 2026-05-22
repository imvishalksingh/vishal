import { supabaseAdmin } from '../config/supabase.js';

type Recommendation = {
    kind: 'book' | 'quiz';
    recommendation_type: 'continue_book' | 'new_book' | 'general_quiz' | 'book_quiz';
    title: string;
    subtitle: string;
    action_label: string;
    book_id?: string;
    quiz_type?: string;
    cover_url?: string | null;
    file_url?: string | null;
    format_type?: string | null;
};

export class RecommendationService {
    static async getForUser(userId: string): Promise<Recommendation[]> {
        const [
            { data: progressRows },
            { data: books },
            { data: quizzes },
            { data: quizResults },
        ] = await Promise.all([
            supabaseAdmin
                .from('user_progress')
                .select('*')
                .eq('user_id', userId)
                .order('last_read_at', { ascending: false }),
            supabaseAdmin
                .from('books')
                .select('*')
                .eq('is_visible', true)
                .order('created_at', { ascending: false }),
            supabaseAdmin
                .from('quizzes')
                .select('id, title, type, book_id')
                .order('created_at', { ascending: false }),
            supabaseAdmin
                .from('quiz_results')
                .select('quiz_id')
                .eq('user_id', userId),
        ]);

        const recommendations: Recommendation[] = [];
        const progress = progressRows || [];
        const visibleBooks = books || [];
        const allQuizzes = quizzes || [];
        const takenQuizIds = new Set((quizResults || []).map((row) => row.quiz_id));

        const inProgressBook = progress.find((row) => row.is_completed !== true);
        if (inProgressBook) {
            const book = visibleBooks.find((item) => item.id === inProgressBook.book_id);
            if (book) {
                recommendations.push({
                    kind: 'book',
                    recommendation_type: 'continue_book',
                    title: `Continue ${book.title}`,
                    subtitle: `Pick up from page ${inProgressBook.current_page || 1}`,
                    action_label: 'Resume',
                    book_id: book.id,
                    cover_url: book.cover_url,
                    file_url: book.file_url,
                    format_type: book.format_type,
                });
            }
        }

        const completedOrStartedBookIds = new Set(progress.map((row) => row.book_id));
        const unreadBook = visibleBooks.find((book) => !completedOrStartedBookIds.has(book.id));
        if (unreadBook) {
            recommendations.push({
                kind: 'book',
                recommendation_type: 'new_book',
                title: `Start ${unreadBook.title}`,
                subtitle: unreadBook.author || unreadBook.category || 'Try something new today',
                action_label: 'Start Reading',
                book_id: unreadBook.id,
                cover_url: unreadBook.cover_url,
                file_url: unreadBook.file_url,
                format_type: unreadBook.format_type,
            });
        }

        const generalQuiz = allQuizzes.find((quiz) => quiz.type === 'general' && !takenQuizIds.has(quiz.id));
        if (generalQuiz) {
            recommendations.push({
                kind: 'quiz',
                recommendation_type: 'general_quiz',
                title: generalQuiz.title,
                subtitle: 'A general challenge to sharpen your skills',
                action_label: 'Take Quiz',
                quiz_type: 'general',
            });
        }

        if (inProgressBook) {
            const relatedQuiz = allQuizzes.find(
                (quiz) =>
                    quiz.book_id === inProgressBook.book_id &&
                    quiz.type !== 'general' &&
                    !takenQuizIds.has(quiz.id)
            );
            if (relatedQuiz) {
                recommendations.push({
                    kind: 'quiz',
                    recommendation_type: 'book_quiz',
                    title: relatedQuiz.title,
                    subtitle: 'Test what you learned from your current book',
                    action_label: 'Practice',
                    book_id: inProgressBook.book_id,
                    quiz_type: 'book',
                });
            }
        }

        return recommendations.slice(0, 4);
    }
}
