import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'user_data_provider.dart';

class AuthProvider extends ChangeNotifier {
  final UserDataProvider userDataProvider;

  AuthProvider(this.userDataProvider) {
    _init();
  }

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool get isLoggedIn => AuthService.isLoggedIn;
  bool get isAdmin => AuthService.isAdmin;
  Map<String, dynamic>? get user => AuthService.user;
  bool get hasCompletedOnboarding => AuthService.hasCompletedOnboarding;

  Future<void> _init() async {
    await AuthService.init();
    _isInitialized = true;
    notifyListeners();
    if (isLoggedIn) {
      userDataProvider.loadAllData();
    }
  }

  Future<String?> signInWithGoogle() async {
    final error = await AuthService.signInWithGoogle();
    if (error == null) {
      notifyListeners();
      userDataProvider.loadAllData();
    }
    return error;
  }

  Future<void> logout() async {
    await AuthService.logout();
    userDataProvider.clear();
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? className,
    String? learningGoal,
  }) async {
    final success = await AuthService.updateProfile(
      fullName: fullName,
      avatarUrl: avatarUrl,
      className: className,
      learningGoal: learningGoal,
    );
    if (success) notifyListeners(); // Important: Redraws UI with new name!
    return success;
  }
}
