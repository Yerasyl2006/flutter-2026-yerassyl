import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/api/api_client.dart';
import 'core/storage/secure_store.dart';
import 'features/auth/auth_model.dart';
import 'features/settings/settings_model.dart';
// import 'features/users/fake_user_repository.dart';
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
  final api = ApiClient.live(store);
  final UserRepository repo = HttpUserRepository(api);
  // final UserRepository repo = FakeUserRepository();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: store),
        Provider(
          create: (_) => api,
          dispose: (_, client) => client.close(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsModel(prefs, dark: dark, city: city),
        ),
        ChangeNotifierProvider(create: (_) => AuthModel(store, token: token)),
      ],
      child: App(
        signedIn: ChangeNotifierProvider(
          create: (_) {
            final model = UsersModel(repo);
            unawaited(model.load());
            return model;
          },
          child: const UsersScreen(),
        ),
      ),
    ),
  );
}
