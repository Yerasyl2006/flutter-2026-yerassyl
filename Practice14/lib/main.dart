import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/api/api_client.dart';
import 'core/env.dart';
import 'core/storage/secure_store.dart';
import 'features/auth/auth_model.dart';
import 'features/settings/settings_model.dart';
import 'features/users/fake_user_repository.dart';
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
  final apiHostOverride =
      kDebugMode ? await prefs.getString(SettingsModel.apiHostKey) : null;

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: store),
        ChangeNotifierProvider(
          create:
              (_) => SettingsModel(
                prefs,
                dark: dark,
                city: city,
                apiHostOverride: apiHostOverride,
              ),
        ),
        ChangeNotifierProvider(create: (_) => AuthModel(store, token: token)),
      ],
      child: const App(signedIn: _SignedInUsers()),
    ),
  );
}

class _SignedInUsers extends StatelessWidget {
  const _SignedInUsers();

  @override
  Widget build(BuildContext context) {
    final host =
        kDebugMode && !Env.useFakes
            ? context.select((SettingsModel settings) => settings.apiHost)
            : Env.host;
    return MultiProvider(
      key: ValueKey(host),
      providers: [
        if (!Env.useFakes)
          Provider(
            create: (context) => ApiClient.live(context.read(), host: host),
            dispose: (_, client) => client.close(),
          ),
        ChangeNotifierProvider(
          create: (context) {
            final UserRepository repo =
                Env.useFakes
                    ? FakeUserRepository()
                    : HttpUserRepository(context.read<ApiClient>());
            final model = UsersModel(repo);
            unawaited(model.load());
            return model;
          },
        ),
      ],
      child: const UsersScreen(),
    );
  }
}
