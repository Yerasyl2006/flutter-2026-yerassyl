import 'dart:convert';

import '../../core/storage/local_data.dart';
import 'user.dart';

class UsersCache {
  const UsersCache();

  Future<void> save(List<User> users) =>
      writeUsersJson(jsonEncode([for (final user in users) user.toJson()]));

  Future<List<User>?> load() async {
    final json = await readUsersJson();
    if (json == null) return null;
    final data = jsonDecode(json) as List<dynamic>;
    return [
      for (final item in data) User.fromJson(item as Map<String, dynamic>),
    ];
  }
}
