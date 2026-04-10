import 'package:flutter/foundation.dart';

/// Переключение вкладок нижней навигации из витрины и др.
class MainNavProvider extends ChangeNotifier {
  int _index = 0;
  /// После перехода на «Профиль» открыть подвкладку портфолио (1).
  bool _openPortfolioOnProfile = false;

  int get index => _index;
  bool get shouldOpenPortfolioTab => _openPortfolioOnProfile;

  void setTab(int i) {
    if (i < 0 || i > 3) return;
    if (i != 3) {
      _openPortfolioOnProfile = false;
    }
    if (_index != i) {
      _index = i;
      notifyListeners();
    }
  }

  /// Витрина / поиск: профиль → вкладка «Портфолио».
  void goToProfilePortfolioTab() {
    _openPortfolioOnProfile = true;
    if (_index != 3) {
      _index = 3;
      notifyListeners();
    } else {
      notifyListeners();
    }
  }

  void clearPortfolioTabRequest() {
    if (_openPortfolioOnProfile) {
      _openPortfolioOnProfile = false;
      notifyListeners();
    }
  }
}
