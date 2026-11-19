import 'package:flutter/material.dart';

import '../user.dart';
import '../user_detail_screen.dart';

class UserTile extends StatelessWidget {
  const UserTile({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(user.name),
    subtitle: Text(
      user.address.city.isEmpty
          ? user.email
          : '${user.email}\n${user.address.city}',
    ),
    trailing: const Icon(Icons.chevron_right),
    isThreeLine: user.address.city.isNotEmpty,
    onTap: () async {
      await Navigator.of(context).push<void>(
        MaterialPageRoute(builder: (_) => UserDetailScreen(user: user)),
      );
    },
  );
}
