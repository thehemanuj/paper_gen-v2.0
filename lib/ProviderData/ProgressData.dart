import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../assets/NotificationService.dart';

class ProgressData extends ChangeNotifier {
  ProgressData() {
    print('--- [ProgressData] Initializing ProgressData provider ---');
    _initializeHive();
  }

  late Box box;
  bool _isInitialized = false;

  Future<void> _initializeHive() async {
    try {
      if (Hive.isBoxOpen('progress-data')) {
        box = Hive.box('progress-data');
      } else {
        box = await Hive.openBox('progress-data');
      }
      _isInitialized = true;
      print('--- [ProgressData] Hive box ready. ---');
      fetchBoxData();
    } catch (e) {
      print('--- [ProgressData] Error initializing Hive: $e ---');
    }
  }


  void fetchBoxData() {
    if (box.isNotEmpty) {
      if (box.containsKey('userLoggedIn')) {
        _userLoggedIn = box.get('userLoggedIn');
      }
      if (box.containsKey('darkMode')) {
        _darkMode = box.get('darkMode');
      }
      if (box.containsKey('notificationsEnabled')) {
        _notificationsEnabled = box.get('notificationsEnabled');
        if (_notificationsEnabled) {
          NotificationService().scheduleDailyNotification();
        }
      }
    }
    notifyListeners();
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
  setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    await putData('notificationsEnabled', _notificationsEnabled);
    if (_notificationsEnabled) {
      await NotificationService().scheduleDailyNotification();
    } else {
      await NotificationService().cancelNotifications();
    }
    notifyListeners();
  }
}
