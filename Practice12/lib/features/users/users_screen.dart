import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_model.dart';
import '../settings/settings_screen.dart';
import 'new_user_screen.dart';
import 'user.dart';
import 'user_detail_screen.dart';
import 'users_model.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<UsersModel>();
    final city = context.watch<SettingsModel>().city;
    final filtered = [
      for (final user in model.items)
        if (city == null || user.address.city == city) user,
    ];
    final Widget body;
    if (model.loading && model.items.isEmpty && !model.fromCache) {
      body = const LoadingView();
    } else {
      body = switch (model.error) {
        null => Column(
          children: [
            if (model.fromCache)
              MaterialBanner(
                leading: const Icon(Icons.cloud_off),
                content: const Text('Saved data · no connection'),
                actions: [
                  TextButton(
                    onPressed: model.loading ? null : model.load,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            if (model.loading) const LinearProgressIndicator(),
            Expanded(child: UserList(items: filtered, onRefresh: model.load)),
          ],
        ),
        NoConnectionException() => Offline(onRetry: model.load),
        NotFoundException() || UnauthorizedException() => const _Message(
          text: 'This request could not be completed.',
        ),
        ServerException(:final status) => ServerError(
          status,
          onRetry: model.load,
        ),
        BadResponseException() => const GenericError(),
      };
    }
    return Scaffold(
      appBar: AppBar(
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
                      for (final user in model.items)
                        if (user.address.city.isNotEmpty) user.address.city,
                    }.toList()
                    ..sort();
              await Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(cities: cities),
                ),
              );
            },
          ),
        ],
      ),
      body: body,
      floatingActionButton:
          model.loading || model.error != null
              ? null
              : FloatingActionButton.extended(
                onPressed: () async {
                  await Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder:
                          (_) => ChangeNotifierProvider.value(
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
      itemBuilder: (context, index) {
        if (items.isEmpty) {
          return const ListTile(title: Text('No users match this city.'));
        }
        final user = items[index];
        return ListTile(
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
      },
    ),
  );
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(semanticsLabel: 'Loading users'),
  );
}

class Offline extends StatelessWidget {
  const Offline({required this.onRetry, super.key});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) =>
      _Message(text: 'No network connection.', onRetry: onRetry);
}

class ServerError extends StatelessWidget {
  const ServerError(this.status, {required this.onRetry, super.key});

  final int status;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) =>
      _Message(text: 'Server error ($status).', onRetry: onRetry);
}

class GenericError extends StatelessWidget {
  const GenericError({super.key});

  @override
  Widget build(BuildContext context) =>
      const _Message(text: 'The server returned unreadable data.');
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.onRetry});

  final String text;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    ),
  );
}
