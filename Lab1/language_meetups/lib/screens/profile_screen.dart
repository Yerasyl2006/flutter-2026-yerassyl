import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../utils/validators.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _key = GlobalKey<FormState>();
  late final _name = TextEditingController(text: appState.profile.name);
  late final _group = TextEditingController(text: appState.profile.group);

  @override
  void dispose() {
    _name.dispose();
    _group.dispose();
    super.dispose();
  }

  void _save() {
    if (!_key.currentState!.validate()) return;
    appState.setProfile(
      appState.profile.copyWith(
        name: _name.text.trim(),
        group: _group.text.trim(),
      ),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile saved')));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Form(
          key: _key,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: validateName,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _group,
                decoration: const InputDecoration(
                  labelText: 'Group',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Theme'),
        ListenableBuilder(
          listenable: appState,
          builder:
              (context, child) => SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                  ButtonSegment(value: ThemeMode.system, label: Text('System')),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                ],
                selected: {appState.themeMode},
                onSelectionChanged: (s) => appState.setTheme(s.first),
              ),
        ),
      ],
    );
  }
}
