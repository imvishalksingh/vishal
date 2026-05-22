import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'https://book-backned.vercel.app/api/auth';
  static const Duration _timeout = Duration(seconds: 20);
  static final http.Client _client = http.Client();

  // In-memory state
  static String? _token;
  static String? _refreshToken;
  static int? _expiresAt; // unix timestamp seconds
  static Map<String, dynamic>? _user;

  static String? get token => _token;
  static Map<String, dynamic>? get user => _user;
  static bool get isLoggedIn => _token != null;
  static bool get isAdmin => _user?['role'] == 'admin';
  static bool get hasCompletedOnboarding {
    if (_user == null) return false;
    final className = _user!['class'] as String?;
    return className != null && className.trim().isNotEmpty;
  }

  // ─── Google Sign-In ───────────────────────────────────────────────────────
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Using the Client ID from the downloaded JSON
    serverClientId: '716458712446-3jbvti05brf659p686a5udjdsrpon24c.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  // ─── Init  ────────────────────────────────────────────────────────────────
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    _refreshToken = prefs.getString('refresh_token');
    _expiresAt = prefs.getInt('expires_at');
    final userJson = prefs.getString('user_data');
    if (userJson != null) {
      _user = json.decode(userJson);
    }

    // Auto-refresh if expired or expiring in < 5 minutes
    if (_token != null) {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final expiry = _expiresAt ?? 0;
      if (expiry - now < 300) {
        await _tryRefreshToken();
      }
    }
  }

  // ─── Google Sign-In ───────────────────────────────────────────────────────
  /// Returns null on success, or an error message string on failure.
  static Future<String?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return 'Sign-in cancelled';

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) return 'Failed to get Google credentials';

      final response = await _client.post(
        Uri.parse('$baseUrl/google'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id_token': idToken}),
      ).timeout(_timeout);

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        await _saveAuth(data['session'], data['user']);
        return null; // success
      }
      return data['error'] ?? 'Google sign-in failed';
    } on http.ClientException {
      return 'Network error. Please check your internet connection.';
    } catch (e) {
      return 'Google sign-in failed: ${e.toString()}';
    }
  }

  // ─── Token Refresh ────────────────────────────────────────────────────────
  static Future<bool> _tryRefreshToken() async {
    if (_refreshToken == null) return false;
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh_token': _refreshToken}),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _saveAuth(data['session'], data['user']);
        return true;
      }
      // Refresh token is invalid — clear everything
      await _clearAuth();
      return false;
    } catch (_) {
      return false;
    }
  }

  // ─── Interceptor: ensure token is valid before every request ─────────────
  static Future<Map<String, String>> get headers async {
    if (_token != null) {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final expiry = _expiresAt ?? 0;
      if (expiry - now < 60) {
        await _tryRefreshToken();
      }
    }
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  // Sync version for places that can't await
  static Map<String, String> get headersSync => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ─── Update Profile ───────────────────────────────────────────────────────
  static Future<bool> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? className,
    String? learningGoal,
  }) async {
    try {
      final h = await headers;
      final response = await _client.patch(
        Uri.parse('https://book-backned.vercel.app/api/user/profile'),
        headers: h,
        body: json.encode({
          if (fullName != null) 'full_name': fullName,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
          if (className != null) 'class': className,
          if (learningGoal != null) 'learning_goal': learningGoal,
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _user = {...?_user, ...data};
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', json.encode(_user));
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────
  static Future<void> logout() async {
    // Sign out from Google if signed in
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
    } catch (_) {}

    // Notify server
    try {
      if (_token != null) {
        await _client.post(
          Uri.parse('$baseUrl/logout'),
          headers: {'Authorization': 'Bearer $_token', 'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 5));
      }
    } catch (_) {}

    await _clearAuth();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  static Future<void> _saveAuth(
    Map<String, dynamic> session,
    Map<String, dynamic> user,
  ) async {
    _token = session['access_token'];
    _refreshToken = session['refresh_token'];
    _expiresAt = session['expires_at'] is int
        ? session['expires_at']
        : int.tryParse(session['expires_at'].toString());
    _user = user;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', _token!);
    if (_refreshToken != null) await prefs.setString('refresh_token', _refreshToken!);
    if (_expiresAt != null) await prefs.setInt('expires_at', _expiresAt!);
    await prefs.setString('user_data', json.encode(user));
  }

  static Future<void> _clearAuth() async {
    _token = null;
    _refreshToken = null;
    _expiresAt = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('refresh_token');
    await prefs.remove('expires_at');
    await prefs.remove('user_data');
  }
}
