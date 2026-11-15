import 'package:flutter/material.dart';

import '../../../core/api/api_exception.dart';

class UsersErrorView extends StatelessWidget {
  const UsersErrorView({required this.error, required this.onRetry, super.key});

  final ApiException error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final (text, canRetry) = switch (error) {
      NoConnectionException() => ('No connection', true),
      NotFoundException() || UnauthorizedException() =>
        ('This request could not be completed.', false),
      ServerException(:final status) => ('Server error ($status).', true),
      BadResponseException() => ('The server returned unreadable data.', false),
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, textAlign: TextAlign.center),
            if (canRetry) ...[
              const SizedBox(height: 12),
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}
