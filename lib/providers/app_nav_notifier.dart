import 'package:flutter/material.dart';

class AppNavProvider extends ChangeNotifier {
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  bool bottomSheetVisibity = true;

  // TODO: Create enums for tabs instead of using integers
  setCurrentTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  setBottomSheetVisibity(bool visible) {
    bottomSheetVisibity = visible;
    notifyListeners();
  }
}
