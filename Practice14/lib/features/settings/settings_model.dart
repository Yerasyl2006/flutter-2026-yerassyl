import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/env.dart';

class SettingsModel extends ChangeNotifier {
  SettingsModel(
    this._prefs, {
    required bool dark,
    required String? city,
    String? apiHostOverride,
  }) : _dark = dark,
       _city = city,
       _apiHostOverride = kDebugMode ? apiHostOverride : null;

  static const apiHostKey = 'debugApiHost';

  final SharedPreferencesAsync _prefs;
  bool _dark;
  String? _city;
  String? _apiHostOverride;

  bool get dark => _dark;
  String? get city => _city;
  String get apiHost => _apiHostOverride ?? Env.host;

  Future<void> setApiHost(String? value) async {
    if (!kDebugMode) return;
    if (value == null) {
      await _prefs.remove(apiHostKey);
    } else {
      await _prefs.setString(apiHostKey, value);
    }
    _apiHostOverride = value;
    notifyListeners();
  }

  Future<void> setDark(bool value) async {
    _dark = value;
    notifyListeners();
    await _prefs.setBool('darkMode', value);
  }

  Future<void> setCity(String? value) async {
    _city = value;
    notifyListeners();
    if (value == null) {
      await _prefs.remove('cityFilter');
    } else {
      await _prefs.setString('cityFilter', value);
    }
  }
}
