import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/storage/secure_store.dart';
import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    final address = user.address;
    final website = user.website ?? '';
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        children: [
          _field('ID', '${user.id}'),
          _field('Username', user.username),
          _field(
            'Email',
            user.email,
            onTap:
                user.email.isEmpty
                    ? null
                    : () async {
                      await _open(
                        context,
                        Uri(scheme: 'mailto', path: user.email),
                      );
                    },
          ),
          _field(
            'Phone',
            user.phone,
            onTap:
                user.phoneDigits.isEmpty
                    ? null
                    : () async {
                      await _open(
                        context,
                        Uri(scheme: 'tel', path: user.phoneDigits),
                      );
                    },
          ),
          _field(
            'Website',
            website,
            onTap:
                website.isEmpty
                    ? null
                    : () async {
                      await _open(context, Uri.tryParse('https://$website'));
                    },
          ),
          _field('Street', address.street),
          _field('Suite', address.suite),
          _field('City', address.city),
          _field('ZIP code', address.zipcode),
          if (address.city.isNotEmpty)
            _field('Coordinates', '${address.geo.lat}, ${address.geo.lng}'),
          _field('Company', user.company.name),
          _field('Catchphrase', user.company.catchPhrase),
          _field('Business', user.companyBs),
          if (kDebugMode)
            TextButton(
              onPressed: () async {
                try {
                  final token = await context.read<SecureStore>().readToken();
                  if (token == null || !context.mounted) return;
                  await Clipboard.setData(ClipboardData(text: token));
                  if (context.mounted) _message(context, 'Demo token copied.');
                } catch (_) {
                  if (context.mounted) {
                    _message(context, 'Could not copy the demo token.');
                  }
                }
              },
              child: const Text('Copy token to clipboard'),
            ),
        ],
      ),
    );
  }

  Future<void> _open(BuildContext context, Uri? uri) async {
    var opened = false;
    try {
      if (uri != null && uri.hasScheme) {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } on PlatformException {
      // Treat a missing or unavailable handler like a false result.
    }
    if (!opened && context.mounted) _message(context, 'No app can open this.');
  }

  void _message(BuildContext context, String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Widget _field(String label, String value, {VoidCallback? onTap}) => ListTile(
    title: Text(label),
    subtitle: Text(value.isEmpty ? '—' : value),
    onTap: onTap,
  );
}
