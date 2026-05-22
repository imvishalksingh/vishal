import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import '../models/quiz.dart';
import '../models/user_progress.dart';
import '../models/reading_session.dart';
import '../models/bookmark.dart';
import '../models/reader_note.dart';
import '../models/stats.dart';
import '../models/admin_user.dart';
import '../models/user_insights.dart';
import '../models/user_achievement.dart';
import '../models/user_recommendation.dart';
import '../models/vocabulary.dart';
import '../models/daily_tip.dart';
import '../models/challenge.dart';
import '../models/challenge_leaderboard.dart';
import '../models/cbse_category.dart';
import '../models/cbse_material.dart';
import '../models/grammar_unit.dart';
import '../models/grammar_lesson.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'https://book-backned.vercel.app/api';
  static const Duration _timeout = Duration(seconds: 15);
  static final http.Client _client = http.Client();

  static Future<http.Response> _get(String path, {Map<String, String>? headers}) {
    return _client
        .get(Uri.parse('$baseUrl$path'), headers: headers)
        .timeout(_timeout);
  }

  static Future<http.Response> _post(String path, {Map<String, String>? headers, Object? body}) {
    return _client
        .post(Uri.parse('$baseUrl$path'), headers: headers, body: body)
        .timeout(_timeout);
  }

  static Future<http.Response> _patch(String path, {Map<String, String>? headers, Object? body}) {
    return _client
        .patch(Uri.parse('$baseUrl$path'), headers: headers, body: body)
        .timeout(_timeout);
  }

  static Future<http.Response> _delete(String path, {Map<String, String>? headers}) {
    return _client
        .delete(Uri.parse('$baseUrl$path'), headers: headers)
        .timeout(_timeout);
  }

  // --- Books ---
  static Future<List<Book>> getBooks() async {
    final response = await _get('/books');
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load books');
    }
  }

  static Future<List<Book>> getAdminBooks() async {
    final response = await _get('/books/admin/all', headers: await AuthService.headers);
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load admin books');
    }
  }

  static Future<Book> createBook(Book book) async {
    final response = await _post(
      '/books',
      headers: await AuthService.headers,
      body: json.encode(book.toJson()),
    );
    if (response.statusCode == 201) {
      return Book.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create book: ${response.body}');
    }
  }

  static Future<String> uploadFile(String filePath) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
    if (AuthService.token != null) {
      request.headers.addAll({'Authorization': 'Bearer ${AuthService.token}'});
    }
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    
    var streamedResponse = await request.send().timeout(_timeout);
    var response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['url'];
    } else {
      throw Exception('Failed to upload file: ${response.body}');
    }
  }

  static Future<Book> updateBook(String id, Map<String, dynamic> data) async {
    final response = await _patch(
      '/books/$id',
      headers: await AuthService.headers,
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      return Book.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update book');
    }
  }

  static Future<void> deleteBook(String id) async {
    final response = await _delete('/books/$id', headers: await AuthService.headers);
    if (response.statusCode != 204) {
      throw Exception('Failed to delete book');
    }
  }

  // --- Quizzes ---
  static Future<List<Quiz>> getQuizzes() async {
    final response = await _get('/quizzes', headers: await AuthService.headers);
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((json) => Quiz.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load quizzes');
    }
  }

  static Future<Quiz> getQuizById(String id) async {
    final response = await _get('/quizzes/$id');
    if (response.statusCode == 200) {
      return Quiz.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load quiz');
    }
  }

  static Future<Quiz> createQuiz(Map<String, dynamic> quizData) async {
    final response = await _post(
      '/quizzes',
      headers: await AuthService.headers,
      body: json.encode(quizData),
    );
    if (response.statusCode == 201) {
      return Quiz.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create quiz: ${response.body}');
    }
  }

  static Future<Quiz> updateQuiz(String id, Map<String, dynamic> quizData) async {
    final response = await _patch(
      '/quizzes/$id',
      headers: await AuthService.headers,
      body: json.encode(quizData),
    );
    if (response.statusCode == 200) {
      return Quiz.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update quiz: ${response.body}');
    }
  }

  static Future<void> deleteQuiz(String id) async {
    final response = await _delete(
      '/quizzes/$id',
      headers: await AuthService.headers,
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete quiz: ${response.body}');
    }
  }

  static Future<void> submitQuizResult(String quizId, int score) async {
    final response = await _post(
      '/quizzes/$quizId/submit',
      headers: await AuthService.headers,
      body: json.encode({
        'score': score,
      }),
    );
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      String errorMessage = 'Failed to submit quiz attempt';
      try {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('error')) {
          errorMessage = data['error'];
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  // --- User Progress ---
  static Future<List<UserProgress>> getProgress() async {
    final response = await _get('/user/progress', headers: await AuthService.headers);
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((json) => UserProgress.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load progress');
    }
  }

  static Future<void> updateProgress(
    String bookId,
    int currentPage, {
    double? progressPercent,
    bool? isCompleted,
    int? totalMinutesRead,
    String? lastPosition,
  }) async {
    final response = await _post(
      '/user/progress',
      headers: await AuthService.headers,
      body: json.encode({
        'book_id': bookId,
        'page': currentPage,
        if (progressPercent != null) 'progress_percent': progressPercent,
        if (isCompleted != null) 'is_completed': isCompleted,
        if (totalMinutesRead != null) 'total_minutes_read': totalMinutesRead,
        if (lastPosition != null) 'last_position': lastPosition,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update progress');
    }
  }

  static Future<List<ReadingSession>> getReadingSessions({String? bookId}) async {
    final suffix = bookId != null ? '?book_id=$bookId' : '';
    final response = await _get('/user/reading-sessions$suffix', headers: await AuthService.headers);
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => ReadingSession.fromJson(json)).toList();
    }
    throw Exception('Failed to load reading sessions');
  }

  static Future<ReadingSession> startReadingSession(
    String bookId, {
    int startPage = 0,
    String? deviceType,
    String? source,
  }) async {
    final response = await _post(
      '/user/reading-sessions',
      headers: await AuthService.headers,
      body: json.encode({
        'book_id': bookId,
        'start_page': startPage,
        if (deviceType != null) 'device_type': deviceType,
        if (source != null) 'source': source,
      }),
    );
    if (response.statusCode == 201) {
      return ReadingSession.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to start reading session: ${response.body}');
  }

  static Future<ReadingSession> finishReadingSession(
    String sessionId, {
    int endPage = 0,
    int minutesSpent = 0,
    int pagesRead = 0,
    bool isCompleted = false,
  }) async {
    final response = await _patch(
      '/user/reading-sessions/$sessionId',
      headers: await AuthService.headers,
      body: json.encode({
        'end_page': endPage,
        'minutes_spent': minutesSpent,
        'pages_read': pagesRead,
        'is_completed': isCompleted,
      }),
    );
    if (response.statusCode == 200) {
      return ReadingSession.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to finish reading session: ${response.body}');
  }

  static Future<List<Bookmark>> getBookmarks({String? bookId}) async {
    final suffix = bookId != null ? '?book_id=$bookId' : '';
    final response = await _get('/user/bookmarks$suffix', headers: await AuthService.headers);
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Bookmark.fromJson(json)).toList();
    }
    throw Exception('Failed to load bookmarks');
  }

  static Future<Bookmark> createBookmark(
    String bookId, {
    int page = 0,
    String? position,
    String? label,
  }) async {
    final response = await _post(
      '/user/bookmarks',
      headers: await AuthService.headers,
      body: json.encode({
        'book_id': bookId,
        'page': page,
        if (position != null) 'position': position,
        if (label != null) 'label': label,
      }),
    );
    if (response.statusCode == 201) {
      return Bookmark.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to create bookmark: ${response.body}');
  }

  static Future<void> deleteBookmark(String bookmarkId) async {
    final response = await _delete('/user/bookmarks/$bookmarkId', headers: await AuthService.headers);
    if (response.statusCode != 204) {
      throw Exception('Failed to delete bookmark');
    }
  }

  static Future<List<ReaderNote>> getNotes({String? bookId}) async {
    final suffix = bookId != null ? '?book_id=$bookId' : '';
    final response = await _get('/user/notes$suffix', headers: await AuthService.headers);
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => ReaderNote.fromJson(json)).toList();
    }
    throw Exception('Failed to load notes');
  }

  static Future<ReaderNote> createNote(
    String bookId,
    String noteText, {
    int page = 0,
    String? position,
  }) async {
    final response = await _post(
      '/user/notes',
      headers: await AuthService.headers,
      body: json.encode({
        'book_id': bookId,
        'note_text': noteText,
        'page': page,
        if (position != null) 'position': position,
      }),
    );
    if (response.statusCode == 201) {
      return ReaderNote.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to create note: ${response.body}');
  }

  static Future<void> deleteNote(String noteId) async {
    final response = await _delete('/user/notes/$noteId', headers: await AuthService.headers);
    if (response.statusCode != 204) {
      throw Exception('Failed to delete note');
    }
  }

  static Future<UserInsights> getUserInsights() async {
    final response = await _get('/user/insights', headers: await AuthService.headers);
    if (response.statusCode == 200) {
      return UserInsights.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load user insights');
  }

  static Future<UserAchievementBundle> getUserAchievements() async {
    final response = await _get('/user/achievements', headers: await AuthService.headers);
    if (response.statusCode == 200) {
      return UserAchievementBundle.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load user achievements');
  }

  static Future<List<UserRecommendation>> getUserRecommendations() async {
    final response = await _get('/user/recommendations', headers: await AuthService.headers);
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => UserRecommendation.fromJson(json)).toList();
    }
    throw Exception('Failed to load recommendations');
  }

  // --- Vocabulary ---
  static Future<List<Vocabulary>> getVocabularyList() async {
    final response = await _get('/vocabulary');
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((json) => Vocabulary.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load vocabulary');
    }
  }

  static Future<Vocabulary> createVocabulary(Map<String, dynamic> data) async {
    final response = await _post(
      '/vocabulary',
      headers: await AuthService.headers,
      body: json.encode(data),
    );
    if (response.statusCode == 201) {
      return Vocabulary.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create vocabulary: ${response.body}');
    }
  }

  static Future<void> deleteVocabulary(String id) async {
    final response = await _delete('/vocabulary/$id', headers: await AuthService.headers);
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete vocabulary');
    }
  }

  // --- Daily Tips ---
  static Future<List<DailyTip>> getDailyTips() async {
    final response = await _get('/tips');
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((json) => DailyTip.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load daily tips');
    }
  }

  static Future<DailyTip> createDailyTip(Map<String, dynamic> data) async {
    final response = await _post(
      '/tips',
      headers: await AuthService.headers,
      body: json.encode(data),
    );
    if (response.statusCode == 201) {
      return DailyTip.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create daily tip: ${response.body}');
    }
  }

  static Future<void> deleteDailyTip(String id) async {
    final response = await _delete('/tips/$id', headers: await AuthService.headers);
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete tip: ${response.statusCode}');
    }
  }

  // --- Challenges ---
  static Future<List<Challenge>> getChallenges() async {
    final response = await _get('/challenges', headers: await AuthService.headers);
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((json) => Challenge.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load challenges');
    }
  }

  static Future<Challenge> getChallengeById(String id) async {
    final response = await _get('/challenges/$id');
    if (response.statusCode == 200) {
      return Challenge.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load challenge details');
    }
  }

  static Future<Challenge> createChallenge(Challenge challenge) async {
    final response = await _post(
      '/challenges',
      headers: await AuthService.headers,
      body: json.encode(challenge.toJson()),
    );
    if (response.statusCode == 201) {
      return Challenge.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create challenge: ${response.body}');
    }
  }

  static Future<Challenge> updateChallenge(String id, Challenge challenge) async {
    final response = await _patch(
      '/challenges/$id',
      headers: await AuthService.headers,
      body: json.encode(challenge.toJson()),
    );
    if (response.statusCode == 200) {
      return Challenge.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update challenge: ${response.body}');
    }
  }

  static Future<void> deleteChallenge(String id) async {
    final response = await _delete('/challenges/$id', headers: await AuthService.headers);
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete challenge');
    }
  }

  static Future<Map<String, dynamic>> submitChallengeAttempt(String challengeId, int score, int timeTakenMs) async {
    final response = await _post(
      '/challenges/$challengeId/submit',
      headers: await AuthService.headers,
      body: json.encode({
        'score': score,
        'time_taken_ms': timeTakenMs,
      }),
    );
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      String errorMessage = 'Failed to submit challenge attempt';
      try {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('error')) {
          errorMessage = data['error'];
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  static Future<List<ChallengeLeaderboardEntry>> getChallengeLeaderboard(String challengeId) async {
    final response = await _get('/challenges/$challengeId/leaderboard');
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((json) => ChallengeLeaderboardEntry.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load challenge leaderboard');
    }
  }

  // --- CBSE ---
  static Future<List<CbseCategory>> getCbseCategories() async {
    final response = await _get('/cbse/categories', headers: await AuthService.headers);
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((json) => CbseCategory.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load CBSE categories');
    }
  }

  static Future<List<CbseMaterial>> getCbseMaterials(String categoryId) async {
    final response = await _get('/cbse/categories/$categoryId/materials', headers: await AuthService.headers);
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((json) => CbseMaterial.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load CBSE materials');
    }
  }

  // --- Grammar ---
  static Future<List<GrammarUnit>> getGrammarUnits() async {
    final response = await _get('/grammar/units', headers: await AuthService.headers);
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((json) => GrammarUnit.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load Grammar units');
    }
  }

  static Future<List<GrammarLesson>> getGrammarLessons(String unitId) async {
    final response = await _get('/grammar/units/$unitId/lessons', headers: await AuthService.headers);
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((json) => GrammarLesson.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load Grammar lessons');
    }
  }

  static Future<List<dynamic>> getGrammarProgress() async {
    final response = await _get('/grammar/progress', headers: await AuthService.headers);
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load Grammar progress');
    }
  }

  static Future<void> markGrammarLessonCompleted(String lessonId) async {
    final response = await _post('/grammar/lessons/$lessonId/complete', headers: await AuthService.headers);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to mark lesson completed');
    }
  }

  static Future<void> createGrammarUnit(Map<String, dynamic> data) async {
    final response = await _post('/grammar/units', headers: await AuthService.headers, body: json.encode(data));
    if (response.statusCode != 201) {
      throw Exception('Failed to create Grammar unit');
    }
  }

  static Future<void> deleteGrammarUnit(String id) async {
    final response = await _delete('/grammar/units/$id', headers: await AuthService.headers);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete Grammar unit');
    }
  }

  static Future<void> createGrammarLesson(String unitId, Map<String, dynamic> data) async {
    final response = await _post('/grammar/units/$unitId/lessons', headers: await AuthService.headers, body: json.encode(data));
    if (response.statusCode != 201) {
      throw Exception('Failed to create Grammar lesson');
    }
  }

  static Future<void> deleteGrammarLesson(String lessonId) async {
    final response = await _delete('/grammar/lessons/$lessonId', headers: await AuthService.headers);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete Grammar lesson');
    }
  }


  static Future<void> createCbseCategory(Map<String, dynamic> data) async {
    final response = await _post('/cbse/categories', headers: await AuthService.headers, body: json.encode(data));
    if (response.statusCode != 201) {
      throw Exception('Failed to create CBSE category');
    }
  }

  static Future<void> deleteCbseCategory(String id) async {
    final response = await _delete('/cbse/categories/$id', headers: await AuthService.headers);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete CBSE category');
    }
  }

  static Future<void> createCbseMaterial(String categoryId, Map<String, dynamic> data) async {
    final response = await _post('/cbse/categories/$categoryId/materials', headers: await AuthService.headers, body: json.encode(data));
    if (response.statusCode != 201) {
      throw Exception('Failed to create CBSE material');
    }
  }

  static Future<void> deleteCbseMaterial(String materialId) async {
    final response = await _delete('/cbse/materials/$materialId', headers: await AuthService.headers);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete CBSE material');
    }
  }

  static Future<AdminStats> getAdminStats() async {
    final response = await _get('/admin/stats', headers: await AuthService.headers);
    if (response.statusCode == 200) {
      return AdminStats.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load admin stats');
    }
  }

  static Future<List<AdminUser>> getAdminUsers() async {
    final response = await _get('/admin/users', headers: await AuthService.headers);
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((json) => AdminUser.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load admin users');
    }
  }

  static Future<Map<String, dynamic>> getAdminUserProgress(String userId) async {
    final response = await _get('/admin/users/$userId/progress', headers: await AuthService.headers);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user progress: ${response.statusCode} - ${response.body}');
    }
  }
}
