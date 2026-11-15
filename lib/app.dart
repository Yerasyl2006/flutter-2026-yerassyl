import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/settings/settings_model.dart';
import 'session.dart';

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
    home: const Session(),
  );
}
