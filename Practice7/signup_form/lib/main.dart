import 'package:flutter/material.dart';

import 'summary_card.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
    home: const SignUpScreen(),
  );
}

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _birthText = TextEditingController();

  final _emailFocus = FocusNode();

  String? _group;
  DateTime? _birth;
  bool _agreed = false;
  bool _done = false;
  int _pwLen = 0;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm, _birthText]) {
      c.dispose();
    }
    _emailFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Account created')));
      setState(() => _done = true);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    if (!mounted) return;
    setState(() {
      _birth = picked;
      _birthText.text =
          '${picked.day.toString().padLeft(2, '0')}.'
          '${picked.month.toString().padLeft(2, '0')}.${picked.year}';
    });
  }

  void _reset() => setState(() {
    for (final c in [_name, _email, _password, _confirm, _birthText]) {
      c.clear();
    }
    _group = null;
    _birth = null;
    _agreed = false;
    _pwLen = 0;
    _done = false;
  });

  void _unfocus() => FocusManager.instance.primaryFocus?.unfocus();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sign up')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _done ? _buildSummary() : _buildForm(),
    ),
  );

  Widget _buildSummary() => Column(
    children: [
      SummaryCard(
        name: _name.text,
        email: _email.text,
        group: _group ?? '',
        birth: _birthText.text,
      ),
      TextButton(onPressed: _reset, child: const Text('Start over')),
    ],
  );

  Widget _buildForm() => Form(
    key: _formKey,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    child: Column(
      children: [
        TextFormField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'Name'),
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _emailFocus.requestFocus(),
          onTapOutside: (_) => _unfocus(),
          validator:
              (v) => (v ?? '').trim().length < 2 ? 'Name is too short' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _email,
          focusNode: _emailFocus,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'name@kbtu.kz',
          ),
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          onTapOutside: (_) => _unfocus(),
          validator: (v) {
            final s = (v ?? '').trim();
            final at = s.indexOf('@');
            if (at == -1 || !s.substring(at).contains('.')) {
              return 'Email looks wrong';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _password,
          decoration: const InputDecoration(
            labelText: 'Password',
            helperText: 'At least 8 characters',
          ),
          obscureText: true,
          textInputAction: TextInputAction.next,
          onChanged: (v) => setState(() => _pwLen = v.length),
          onTapOutside: (_) => _unfocus(),
          validator:
              (v) => (v ?? '').length < 8 ? 'Password is too short' : null,
        ),
        Align(alignment: Alignment.centerLeft, child: Text('$_pwLen of 8')),
        const SizedBox(height: 12),
        TextFormField(
          controller: _confirm,
          decoration: const InputDecoration(labelText: 'Confirm password'),
          obscureText: true,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) {
            if (_agreed) _submit();
          },
          onTapOutside: (_) => _unfocus(),
          validator:
              (v) => v != _password.text ? 'Passwords do not match' : null,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _group,
          decoration: const InputDecoration(labelText: 'Group'),
          items: [
            for (final g in groups) DropdownMenuItem(value: g, child: Text(g)),
          ],
          onChanged: (g) => setState(() => _group = g),
          validator: (g) => g == null ? 'Choose a group' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _birthText,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Date of birth',
            suffixIcon: Icon(Icons.calendar_today),
          ),
          onTap: _pickDate,
          validator: (_) => _birth == null ? 'Pick a date' : null,
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          value: _agreed,
          onChanged: (v) => setState(() => _agreed = v ?? false),
          title: const Text('I agree to the rules'),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _agreed ? _submit : null,
          child: const Text('Sign up'),
        ),
      ],
    ),
  );
}
