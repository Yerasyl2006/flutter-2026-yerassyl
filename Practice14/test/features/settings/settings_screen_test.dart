import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:users_api/core/env.dart';
import 'package:users_api/features/settings/settings_model.dart';
import 'package:users_api/features/settings/settings_screen.dart';

void main() {
  testWidgets('debug host can be saved and reset from Settings', (
    tester,
  ) async {
    final preferences = _TestPreferences();
    final settings = SettingsModel(preferences, dark: false, city: null);
    addTearDown(settings.dispose);
    await tester.pumpWidget(_app(settings));

    await tester.tap(find.text('Developer: API host'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).last, 'https://bad.test');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a host and optional port.'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).last,
      'staging.test:8443',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(preferences.host, 'staging.test:8443');
    expect(settings.apiHost, 'staging.test:8443');

    await tester.tap(find.text('Developer: API host'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    expect(preferences.host, isNull);
    expect(settings.apiHost, Env.host);
  });

  testWidgets('About reads the installed version and opens licenses', (
    tester,
  ) async {
    PackageInfo.setMockInitialValues(
      appName: 'Users',
      packageName: 'kz.yerassyl.users',
      version: '1.0.1',
      buildNumber: '2',
      buildSignature: '',
    );
    final settings = SettingsModel(_TestPreferences(), dark: false, city: null);
    addTearDown(settings.dispose);
    await tester.pumpWidget(_app(settings));
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();

    expect(find.text('Version 1.0.1 (2)'), findsOneWidget);
    expect(find.text('debug'), findsOneWidget);
    expect(find.text(Env.name), findsOneWidget);
    expect(find.text(Env.host), findsOneWidget);
    await tester.tap(find.text('Open-source licenses'));
    await tester.pumpAndSettle();
    expect(find.byType(LicensePage), findsOneWidget);
  });
}

Widget _app(SettingsModel settings) => ChangeNotifierProvider.value(
  value: settings,
  child: const MaterialApp(home: SettingsScreen(cities: [])),
);

class _TestPreferences implements SharedPreferencesAsync {
  final _values = <String, String>{};

  String? get host => _values[SettingsModel.apiHostKey];

  @override
  Future<void> setString(String key, String value) async {
    expect(key, SettingsModel.apiHostKey);
    _values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    expect(key, SettingsModel.apiHostKey);
    _values.remove(key);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
