import 'package:flutter/foundation.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'user_repository.dart';

class UsersModel extends ChangeNotifier {
  UsersModel(this._repo);

  final UserRepository _repo;
  final List<User> _createdUsers = [];
  List<User> _serverUsers = const [];
  ApiException? _error;
  bool _loading = false;
  bool _saving = false;
  bool _disposed = false;
  bool _fromCache = false;

  List<User> get items =>
      List.unmodifiable([..._createdUsers, ..._serverUsers]);
  ApiException? get error => _error;
  bool get loading => _loading;
  bool get saving => _saving;
  bool get fromCache => _fromCache;

  Future<void> load() async {
    if (_loading || _disposed) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _repo.getAll();
      _serverUsers = result.items;
      _fromCache = result.fromCache;
    } on ApiException catch (error) {
      _error = error;
    } on Exception {
      _error = const BadResponseException(
        'Could not read or save the users cache.',
      );
    } on TypeError {
      _error = const BadResponseException(
        'The users cache has an invalid format.',
      );
    } finally {
      _loading = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<bool> create(User draft) async {
    if (_saving || _disposed) return false;
    _saving = true;
    notifyListeners();
    try {
      final user = await _repo.create(draft);
      _createdUsers.insert(0, user);
      return true;
    } finally {
      _saving = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _repo.close();
    super.dispose();
  }
}
