import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/storage/secure_store.dart';

class CopyTokenButton extends StatelessWidget {
  const CopyTokenButton({super.key});

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () async {
      try {
        final token = await context.read<SecureStore>().readToken();
        if (token == null || !context.mounted) return;
        await Clipboard.setData(ClipboardData(text: token));
        if (context.mounted) _show(context, 'Demo token copied.');
      } catch (_) {
        if (context.mounted) _show(context, 'Could not copy the demo token.');
      }
    },
    child: const Text('Copy token to clipboard'),
  );

  void _show(BuildContext context, String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}
