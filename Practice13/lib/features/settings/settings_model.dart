import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel extends ChangeNotifier {
  SettingsModel(this._prefs, {required bool dark, required String? city})
    : _dark = dark,
      _city = city;

  final SharedPreferencesAsync _prefs;
  bool _dark;
  String? _city;

  bool get dark => _dark;
  String? get city => _city;

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
