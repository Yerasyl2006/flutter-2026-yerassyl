import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api/api_exception.dart';
import 'features/users/user.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_model.dart';
import 'features/users/users_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = UserRepository.live(
    host: const String.fromEnvironment(
      'API_HOST',
      defaultValue: 'jsonplaceholder.typicode.com',
    ),
  );
  if (kDebugMode && const bool.fromEnvironment('API_SMOKE_TEST')) {
    await _smokeTest(repository);
  }
  runApp(
    ChangeNotifierProvider(
      create: (_) {
        final model = UsersModel(repository);
        unawaited(model.load());
        return model;
      },
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Users',
    theme: ThemeData(colorSchemeSeed: Colors.indigo),
    home: const UsersScreen(),
  );
}

Future<void> _smokeTest(UserRepository repository) async {
  const raw = r'''
{
  "id": 1,
  "name": "Leanne Graham",
  "username": "Bret",
  "email": "Sincere@april.biz",
  "address": {
    "street": "Kulas Light",
    "suite": "Apt. 556",
    "city": "Gwenborough",
    "zipcode": "92998-3874",
    "geo": {
      "lat": "-37.3159",
      "lng": "81.1496"
    }
  },
  "phone": "1-770-736-8031 x56442",
  "website": "hildegard.org",
  "company": {
    "name": "Romaguera-Crona",
    "catchPhrase": "Multi-layered client-server neural-net",
    "bs": "harness real-time e-markets"
  }
}
''';
  final user = User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  debugPrint('Parsed $user');
  debugPrint('Round trip: ${User.fromJson(user.toJson()) == user}');
  try {
    final users = await repository.getAll();
    debugPrint(
      'GET /users (${users.length}): ${users.map((u) => u.name).join(', ')}',
    );
    try {
      await repository.getById(999);
    } on NotFoundException {
      debugPrint('not found');
    }
    final created = await repository.create(user);
    debugPrint('POST /users id: ${created.id}');
  } on ApiException catch (error) {
    debugPrint('API smoke test: $error');
  }
}
