import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class XpProvider extends ChangeNotifier {
  static const _xpKey = 'user_xp';
  static const _lastVocabDateKey = 'last_vocab_xp_date';
  static const _quizCountKey = 'quiz_count';

  int _totalXp = 0;
  int _quizCount = 0;

  int get totalXp => _totalXp;
  int get quizCount => _quizCount;

  // XP thresholds for each level
  static const List<int> _thresholds = [0, 200, 500, 1000, 2000, 9999999];
  static const List<String> _levelTitles = [
    'Beginner',
    'Learner',
    'Intermediate',
    'Advanced',
    'Expert',
  ];

  int get level {
    for (int i = _thresholds.length - 2; i >= 0; i--) {
      if (_totalXp >= _thresholds[i]) return i;
    }
    return 0;
  }

  String get levelTitle => _levelTitles[level.clamp(0, _levelTitles.length - 1)];

  int get xpForCurrentLevel => _thresholds[level.clamp(0, _thresholds.length - 2)];
  int get xpForNextLevel => _thresholds[(level + 1).clamp(0, _thresholds.length - 1)];

  double get progressToNextLevel {
    final current = xpForCurrentLevel;
    final next = xpForNextLevel;
    if (next == current) return 1.0;
    return ((_totalXp - current) / (next - current)).clamp(0.0, 1.0);
  }

  XpProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _totalXp = prefs.getInt(_xpKey) ?? 0;
    _quizCount = prefs.getInt(_quizCountKey) ?? 0;
    notifyListeners();
  }

  Future<void> awardXp(int amount, String reason) async {
    _totalXp += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_xpKey, _totalXp);
    notifyListeners();
  }

  Future<void> incrementQuizCount() async {
    _quizCount += 1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_quizCountKey, _quizCount);
    notifyListeners();
  }

  /// Award XP for visiting vocabulary — once per day
  Future<bool> awardVocabXpIfEligible() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastDate = prefs.getString(_lastVocabDateKey) ?? '';
    if (lastDate == today) return false;
    await prefs.setString(_lastVocabDateKey, today);
    await awardXp(5, 'Vocabulary visit');
    return true;
  }

  /// Award daily login XP — once per day
  static const _lastLoginKey = 'last_login_xp_date';
  Future<bool> awardDailyLoginXpIfEligible() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastDate = prefs.getString(_lastLoginKey) ?? '';
    if (lastDate == today) return false;
    await prefs.setString(_lastLoginKey, today);
    await awardXp(10, 'Daily login');
    return true;
  }

  /// Save a quiz attempt to history
  Future<void> saveQuizResult({
    required String quizId,
    required String quizTitle,
    required int score,
    required int total,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('quiz_history') ?? '[]';
    final List<dynamic> history = json.decode(historyJson);
    history.insert(0, {
      'quizId': quizId,
      'quizTitle': quizTitle,
      'score': score,
      'total': total,
      'date': DateTime.now().toIso8601String(),
    });
    // Keep max 50 entries
    final trimmed = history.take(50).toList();
    await prefs.setString('quiz_history', json.encode(trimmed));
    // Award XP for quiz
    await awardXp(50, 'Quiz completed');
    await incrementQuizCount();
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getQuizHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('quiz_history') ?? '[]';
    final List<dynamic> raw = json.decode(historyJson);
    return raw.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
