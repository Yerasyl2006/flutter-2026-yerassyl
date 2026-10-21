import 'package:flutter/material.dart';

import 'screens/home_shell.dart';
import 'state/app_state.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder:
          (context, _) => MaterialApp(
            title: 'Language Meetups',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorSchemeSeed: Colors.indigo,
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorSchemeSeed: Colors.indigo,
              brightness: Brightness.dark,
              useMaterial3: true,
            ),
            themeMode: appState.themeMode,
            home: const HomeShell(),
          ),
    );
  }
}
