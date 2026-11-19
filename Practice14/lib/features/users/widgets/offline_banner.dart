import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({required this.onRetry, super.key});

  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) => MaterialBanner(
    leading: const Icon(Icons.cloud_off),
    content: const Text('Saved data · no connection'),
    actions: [TextButton(onPressed: onRetry, child: const Text('Retry'))],
  );
}
