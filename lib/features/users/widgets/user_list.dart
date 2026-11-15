import 'package:flutter/material.dart';

import '../user.dart';
import 'user_tile.dart';
import 'users_empty_state.dart';

class UserList extends StatelessWidget {
  const UserList({required this.items, required this.onRefresh, super.key});

  final List<User> items;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: onRefresh,
    child: ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: items.isEmpty ? 1 : items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, index) => items.isEmpty
          ? const UsersEmptyState()
          : UserTile(user: items[index]),
    ),
  );
}
