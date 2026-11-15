import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../settings/settings_model.dart';
import 'new_user_screen.dart';
import 'users_model.dart';
import 'widgets/offline_banner.dart';
import 'widgets/user_list.dart';
import 'widgets/users_error_view.dart';
import 'widgets/users_header.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<UsersModel>();
    final city = context.watch<SettingsModel?>()?.city;
    final items = model.items;
    final error = model.error;
    final body = switch (error) {
      _ when model.loading && items.isEmpty && !model.fromCache =>
        const Center(
          child: CircularProgressIndicator(semanticsLabel: 'Loading users'),
        ),
      final error? => UsersErrorView(error: error, onRetry: model.load),
      null => Column(
        children: [
          if (model.fromCache)
            OfflineBanner(onRetry: model.loading ? null : model.load),
          if (model.loading) const LinearProgressIndicator(),
          Expanded(
            child: UserList(
              items: [
                for (final user in items)
                  if (city == null || user.address.city == city) user,
              ],
              onRefresh: model.load,
            ),
          ),
        ],
      ),
    };
    return Scaffold(
      appBar: UsersHeader(items: items),
      body: body,
      floatingActionButton: model.loading || error != null
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: model,
                      child: const NewUserScreen(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('New user'),
            ),
    );
  }
}
