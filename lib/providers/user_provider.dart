import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final String? token;
  final String? phone;
  final String? cookie; // إضافة الكوكي

  User({
    this.displayName,
    this.email,
    this.photoUrl,
    this.token,
    this.phone,
    this.cookie,
  });

  bool get isLoggedIn => token != null && token!.isNotEmpty;
}

class UserProvider extends ChangeNotifier {
  User _user = User();
  bool _isLoading = true;

  User get user => _user;
  bool get isLoading => _isLoading;
  String? get token => _user.token;
  String? get cookie => _user.cookie;

  UserProvider() {
    _loadUserFromPrefs();
  }

  Future<void> _loadUserFromPrefs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final cookie = prefs.getString('auth_cookie');
      final displayName = prefs.getString('display_name');
      final email = prefs.getString('email');
      final photoUrl = prefs.getString('photo_url');
      final phone = prefs.getString('phone');

      debugPrint('🔐 UserProvider: Loaded token = ${token != null ? '${token.substring(0, 20)}...' : 'null'}');
      debugPrint('🍪 UserProvider: Loaded cookie = ${cookie != null ? cookie.substring(0, 20) : 'null'}');

      if (token != null && token.isNotEmpty) {
        _user = User(
          displayName: displayName,
          email: email,
          photoUrl: photoUrl,
          token: token,
          phone: phone,
          cookie: cookie,
        );
      }
    } catch (e) {
      debugPrint('❌ Error loading user from prefs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateUser(User newUser) {
    _user = newUser;
    _saveUserToPrefs(newUser);
    notifyListeners();
    debugPrint('✅ User updated: token = ${newUser.token != null ? '${newUser.token!.substring(0, 20)}...' : 'null'}');
    debugPrint('🍪 User updated: cookie = ${newUser.cookie != null ? newUser.cookie!.substring(0, 20) : 'null'}');
  }

  void updateUserInfo({
    String? displayName,
    String? email,
    String? photoUrl,
    String? phone,
    String? token,
    String? cookie,
  }) {
    _user = User(
      displayName: displayName ?? _user.displayName,
      email: email ?? _user.email,
      photoUrl: photoUrl ?? _user.photoUrl,
      token: token ?? _user.token,
      phone: phone ?? _user.phone,
      cookie: cookie ?? _user.cookie,
    );
    _saveUserToPrefs(_user);
    notifyListeners();
  }

  Future<void> _saveUserToPrefs(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (user.token != null) {
        await prefs.setString('auth_token', user.token!);
      }
      if (user.cookie != null) {
        await prefs.setString('auth_cookie', user.cookie!);
      }
      if (user.displayName != null) {
        await prefs.setString('display_name', user.displayName!);
      }
      if (user.email != null) {
        await prefs.setString('email', user.email!);
      }
      if (user.photoUrl != null) {
        await prefs.setString('photo_url', user.photoUrl!);
      }
      if (user.phone != null) {
        await prefs.setString('phone', user.phone!);
      }
      debugPrint('💾 User saved to prefs');
    } catch (e) {
      debugPrint('❌ Error saving user to prefs: $e');
    }
  }

  Future<void> clearUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _user = User();
      notifyListeners();
      debugPrint('🗑️ User cleared');
    } catch (e) {
      debugPrint('❌ Error clearing user: $e');
    }
  }
}