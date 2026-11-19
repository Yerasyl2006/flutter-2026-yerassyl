import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../core/env.dart';
import '../auth/auth_model.dart';
import 'settings_model.dart';
import 'widgets/city_filter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({required this.cities, super.key});

  final List<String> cities;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _signingOut = false;

  Future<void> _save(Future<void> Function() write) async {
    try {
      await write();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save settings. Try again.')),
      );
    }
  }

  Future<void> _logout() async {
    setState(() => _signingOut = true);
    try {
      await context.read<AuthModel>().logout();
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (_) {
      if (!mounted) return;
      setState(() => _signingOut = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not sign out. Try again.')),
      );
    }
  }

  Future<void> _editApiHost(SettingsModel settings) async {
    String? input;
    final formKey = GlobalKey<FormState>();
    final host = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Developer: API host'),
            content: Form(
              key: formKey,
              child: TextFormField(
                initialValue: settings.apiHost,
                decoration: const InputDecoration(
                  labelText: 'HTTPS host',
                  hintText: 'example.com or example.com:8443',
                ),
                autocorrect: false,
                keyboardType: TextInputType.url,
                onSaved: (value) => input = value?.trim(),
                validator: (value) {
                  final authority = value?.trim() ?? '';
                  final uri = Uri.tryParse('https://$authority');
                  if (uri == null ||
                      uri.host.isEmpty ||
                      (uri.hasPort && (uri.port < 1 || uri.port > 65535)) ||
                      RegExp(r'[\s/?#@]').hasMatch(authority)) {
                    return 'Enter a host and optional port.';
                  }
                  return null;
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(''),
                child: const Text('Reset'),
              ),
              FilledButton(
                onPressed: () {
                  final form = formKey.currentState!;
                  if (form.validate()) {
                    form.save();
                    Navigator.of(context).pop(input);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
    if (!mounted || host == null) return;
    await _save(() => settings.setApiHost(host.isEmpty ? null : host));
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsModel>();
    final selectedCity = settings.city;
    final cities =
        {...widget.cities, if (selectedCity != null) selectedCity}.toList()
          ..sort();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            value: settings.dark,
            onChanged: (value) async => _save(() => settings.setDark(value)),
          ),
          CityFilter(
            cities: cities,
            selectedCity: selectedCity,
            onChanged: (city) async => _save(() => settings.setCity(city)),
          ),
          ListTile(
            title: const Text('About'),
            onTap:
                () => Navigator.of(context).push<void>(
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                ),
          ),
          if (kDebugMode)
            ListTile(
              title: const Text('Developer: API host'),
              subtitle: Text(settings.apiHost),
              enabled: !Env.useFakes,
              onTap: () => _editApiHost(settings),
            ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: _signingOut ? null : _logout,
          ),
        ],
      ),
    );
  }
}

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final _packageInfo = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    const mode =
        kReleaseMode
            ? 'release'
            : kProfileMode
            ? 'profile'
            : 'debug';
    final host =
        kDebugMode
            ? context.select((SettingsModel settings) => settings.apiHost)
            : Env.host;

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        children: [
          FutureBuilder<PackageInfo>(
            future: _packageInfo,
            builder: (context, snapshot) {
              final info = snapshot.data;
              return ListTile(
                title: Text(
                  info != null
                      ? 'Version ${info.version} (${info.buildNumber})'
                      : snapshot.hasError
                      ? 'Version unavailable'
                      : 'Reading version…',
                ),
              );
            },
          ),
          const ListTile(title: Text('Build mode'), subtitle: Text(mode)),
          const ListTile(title: Text('Environment'), subtitle: Text(Env.name)),
          const ListTile(
            title: Text('Build API host'),
            subtitle: Text(Env.host),
          ),
          if (host != Env.host)
            ListTile(title: const Text('Debug API host'), subtitle: Text(host)),
          ListTile(
            title: const Text('Open-source licenses'),
            onTap: () => showLicensePage(context: context),
          ),
        ],
      ),
    );
  }
}
