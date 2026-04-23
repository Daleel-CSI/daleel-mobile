import 'package:flutter/foundation.dart';

class User {
  final String? displayName;
  final String? email;
  final String? photoUrl;

  User({this.displayName, this.email, this.photoUrl});

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
}