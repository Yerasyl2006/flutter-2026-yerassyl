import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/storage/secure_store.dart';
import 'features/auth/auth_model.dart';
import 'features/auth/login_screen.dart';
import 'features/settings/settings_model.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_model.dart';
import 'features/users/users_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = SharedPreferencesAsync();
  final dark = await prefs.getBool('darkMode') ?? false;
  final city = await prefs.getString('cityFilter');
  const store = SecureStore();
  final token = await store.readToken();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: store),
        ChangeNotifierProvider(
          create: (_) => SettingsModel(prefs, dark: dark, city: city),
        ),
        ChangeNotifierProvider(create: (_) => AuthModel(store, token: token)),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Users',
    theme: ThemeData(
      colorSchemeSeed: Colors.indigo,
      brightness: Brightness.light,
    ),
    darkTheme: ThemeData(
      colorSchemeSeed: Colors.indigo,
      brightness: Brightness.dark,
    ),
    themeMode:
        context.watch<SettingsModel>().dark ? ThemeMode.dark : ThemeMode.light,
    home: const _Session(),
  );
}

class _Session extends StatelessWidget {
  const _Session();

  @override
  Widget build(BuildContext context) {
    if (!context.select((AuthModel auth) => auth.signedIn)) {
      return const LoginScreen();
    }
    return ChangeNotifierProvider(
      create: (context) {
        final model = UsersModel(
          UserRepository.live(context.read<SecureStore>()),
        );
        unawaited(model.load());
        return model;
      },
      child: const UsersScreen(),
    );
  }
}
