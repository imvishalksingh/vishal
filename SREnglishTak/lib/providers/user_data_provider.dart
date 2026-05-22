import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/user_progress.dart';
import '../models/bookmark.dart';
import '../models/user_achievement.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class UserDataProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Book> _books = [];
  List<Book> get books => _books;

  List<UserProgress> _progress = [];
  List<UserProgress> get progress => _progress;

  List<Bookmark> _bookmarks = [];
  List<Bookmark> get bookmarks => _bookmarks;

  UserAchievementBundle? _achievements;
  UserAchievementBundle? get achievements => _achievements;

  String? _error;
  String? get error => _error;

  Future<void> loadAllData() async {
    // Only load if logged in (except books, which are public, but we load them together here)
    if (!AuthService.isLoggedIn) {
      _books = await ApiService.getBooks();
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        ApiService.getBooks(),
        ApiService.getProgress(),
        ApiService.getBookmarks(),
        ApiService.getUserAchievements(),
      ]);

      _books = results[0] as List<Book>;
      _progress = results[1] as List<UserProgress>;
      _bookmarks = results[2] as List<Bookmark>;
      _achievements = results[3] as UserAchievementBundle;

    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reloadBookmarks() async {
    try {
      _bookmarks = await ApiService.getBookmarks();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> reloadProgress() async {
    try {
      _progress = await ApiService.getProgress();
      notifyListeners();
    } catch (_) {}
  }

  void clear() {
    _books = [];
    _progress = [];
    _bookmarks = [];
    _achievements = null;
    _error = null;
  }
}
