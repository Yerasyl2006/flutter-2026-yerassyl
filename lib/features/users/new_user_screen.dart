import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'users_model.dart';

class NewUserScreen extends StatefulWidget {
  const NewUserScreen({super.key});

  @override
  State<NewUserScreen> createState() => _NewUserScreenState();
}

class _NewUserScreenState extends State<NewUserScreen> {
  static final _usernamePattern = RegExp(r'^[a-zA-Z0-9_.-]+$');
  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final model = context.read<UsersModel>();
    if (model.saving || _formKey.currentState?.validate() != true) return;
    final draft = User(
      id: 0,
      name: _name.text.trim(),
      username: _username.text.trim(),
      email: _email.text.trim(),
      phone: '',
      website: null,
      address: const Address(
        street: '',
        suite: '',
        city: '',
        zipcode: '',
        geo: Geo(lat: 0, lng: 0),
      ),
      company: (name: '', catchPhrase: ''),
      companyBs: '',
    );
    try {
      final saved = await model.create(draft);
      if (mounted && saved) Navigator.of(context).pop();
    } on ApiException catch (error) {
      if (!mounted) return;
      final message = switch (error) {
        NoConnectionException() => 'No network connection. Try again.',
        ServerException(:final status) => 'Server error ($status). Try again.',
        NotFoundException() => 'The users endpoint could not be found.',
        UnauthorizedException() => 'This request was not authorized.',
        BadResponseException() => 'The server returned unreadable data.',
      };
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.select((UsersModel model) => model.saving);
    return Scaffold(
      appBar: AppBar(title: const Text('New user')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator:
                  (value) =>
                      (value ?? '').trim().isEmpty ? 'Enter a name.' : null,
            ),
            TextFormField(
              controller: _username,
              decoration: const InputDecoration(labelText: 'Username'),
              textInputAction: TextInputAction.next,
              validator:
                  (value) =>
                      _usernamePattern.hasMatch((value ?? '').trim())
                          ? null
                          : 'Use letters, digits, dots, hyphens or underscores.',
            ),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator:
                  (value) =>
                      _emailPattern.hasMatch((value ?? '').trim())
                          ? null
                          : 'Enter a valid email address.',
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: saving ? null : _save,
              child: Text(saving ? 'Saving…' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
