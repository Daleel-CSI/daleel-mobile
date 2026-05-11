import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final String? token;

  User({this.displayName, this.email, this.photoUrl, this.token});

  bool get isLoggedIn => email != null;
}

class UserProvider extends ChangeNotifier {
  User _user = User();
  User get user => _user;

  void updateUser(User newUser) {
    _user = newUser;
    notifyListeners();
  }

  void clearUser() {
    _user = User();
    notifyListeners();
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}