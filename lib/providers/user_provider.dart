import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _user = '';
  String get userRole => _user;

  setUserRole(role) {
    _user = role;
    notifyListeners();
  }
}

String _dashRole = 'home';
String get dashRole => _dashRole;
