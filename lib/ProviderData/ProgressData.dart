import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class ProgressData extends ChangeNotifier {
  ProgressData() {
    _loading = 1;
    notifyListeners();
    _initializeHive();
    _loading = 0;
    notifyListeners();
  }

  late Box box;
  bool _isInitialized = false;

  Future<void> _initializeHive() async {
    box = await Hive.openBox('progress-data');
    _isInitialized = true;
    fetchBoxData();
  }

  void fetchBoxData() {
    if (box.isNotEmpty && box.containsKey('userLoggedIn')) {
      _darkMode = box.get('userLoggedIn');
      notifyListeners();
    }
    if (box.isNotEmpty && box.containsKey('darkMode')) {
      _darkMode = box.get('darkMode');
      notifyListeners();
    }
  }

  Future<void> putData(String key, dynamic value) async {
    if (_isInitialized) {
      await box.put(key, value);
    }
  }

  int _loading = 0;
  int get loading => _loading;
  void setLoading(int value) {
    _loading = value;
    notifyListeners();
  }

  // Dark mode
  bool _darkMode = true;
  bool get darkMode => _darkMode;
  Future<void> setDarkMode() async {
    _darkMode = !_darkMode;
    await putData('darkMode', _darkMode);
    notifyListeners();
  }

  bool _userLoggedIn = false;
  bool get loggedIn => _userLoggedIn;
  setLoggedIn() async {
    _userLoggedIn = true;
    await putData('userLoggedIn', _userLoggedIn);
    notifyListeners();
  }

  bool _notificationsEnabled = false;
  bool get notificationsEnabled => _notificationsEnabled;
  setNotificationsEnabled(value) {
    _notificationsEnabled = value;
    notifyListeners();
  }
}
