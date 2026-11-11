import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'new_user_screen.dart';
import 'user.dart';
import 'user_detail_screen.dart';
import 'users_model.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<UsersModel>();
    final Widget body;
    if (model.loading) {
      body = const LoadingView();
    } else {
      body = switch (model.error) {
        null => UserList(items: model.items, onRefresh: model.load),
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
      appBar: AppBar(title: const Text('Users')),
      body: body,
      floatingActionButton:
          model.loading || model.error != null
              ? null
              : FloatingActionButton.extended(
                onPressed: () async {
                  await Navigator.of(context).push<void>(
                    MaterialPageRoute(builder: (_) => const NewUserScreen()),
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
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
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
