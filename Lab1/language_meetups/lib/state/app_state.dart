import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../models/meetup.dart';
import '../models/profile.dart';

class AppState extends ChangeNotifier {
  List<Meetup> _meetups = buildSeed();
  Profile _profile = const Profile.empty();
  ThemeMode _themeMode = ThemeMode.system;

  List<Meetup> get meetups => List.unmodifiable(_meetups);
  Profile get profile => _profile;
  ThemeMode get themeMode => _themeMode;

  Meetup? byId(String id) {
    for (final m in _meetups) {
      if (m.id == id) return m;
    }
    return null;
  }

  void _replace(String id, Meetup Function(Meetup) f) {
    _meetups = [for (final m in _meetups) m.id == id ? f(m) : m];
    notifyListeners();
  }

  void toggleFavourite(String id) =>
      _replace(id, (m) => m.copyWith(isFavourite: !m.isFavourite));

  void join(String id) => _replace(
    id,
    (m) => m.copyWith(participants: [...m.participants, _profile.name]),
  );

  void leave(String id) => _replace(
    id,
    (m) => m.copyWith(
      participants: m.participants.where((n) => n != _profile.name).toList(),
    ),
  );

  void upsert(Meetup meetup) {
    final exists = _meetups.any((m) => m.id == meetup.id);
    _meetups =
        exists
            ? [for (final m in _meetups) m.id == meetup.id ? meetup : m]
            : [meetup, ..._meetups];
    notifyListeners();
  }

  void delete(String id) {
    _meetups = _meetups.where((m) => m.id != id).toList();
    notifyListeners();
  }

  void setProfile(Profile p) {
    _profile = p;
    notifyListeners();
  }

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

final appState = AppState();
