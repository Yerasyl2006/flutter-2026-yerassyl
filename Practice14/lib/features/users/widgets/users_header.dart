import 'package:flutter/material.dart';

import '../../profile/profile_screen.dart';
import '../../settings/settings_screen.dart';
import '../user.dart';

class UsersHeader extends StatelessWidget implements PreferredSizeWidget {
  const UsersHeader({required this.items, super.key});

  final List<User> items;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    title: const Text('Users'),
    actions: [
      IconButton(
        tooltip: 'Profile',
        icon: const Icon(Icons.account_circle_outlined),
        onPressed: () async {
          await Navigator.of(context).push<void>(
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        },
      ),
      IconButton(
        tooltip: 'Settings',
        icon: const Icon(Icons.settings_outlined),
        onPressed: () async {
          final cities =
              {
                  for (final user in items)
                    if (user.address.city.isNotEmpty) user.address.city,
                }.toList()
                ..sort();
          await Navigator.of(context).push<void>(
            MaterialPageRoute(builder: (_) => SettingsScreen(cities: cities)),
          );
        },
      ),
    ],
  );
}
