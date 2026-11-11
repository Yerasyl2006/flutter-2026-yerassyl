import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:users_api/core/api/api_client.dart';
import 'package:users_api/core/api/api_exception.dart';
import 'package:users_api/features/users/user.dart';
import 'package:users_api/features/users/user_repository.dart';
import 'package:users_api/features/users/users_model.dart';
import 'package:users_api/main.dart';

const _user = User(
  id: 1,
  name: 'Leanne Graham',
  username: 'Bret',
  email: 'leanne@example.com',
  phone: '+1 (555) 1234',
  website: null,
  address: Address(
    street: 'Kulas Light',
    suite: 'Apt. 556',
    city: 'Gwenborough',
    zipcode: '92998-3874',
    geo: Geo(lat: -37.3159, lng: 81.1496),
  ),
  company: (name: 'Romaguera-Crona', catchPhrase: 'Example'),
  companyBs: 'Example services',
);

void main() {
  test('round trip preserves nested fields and nullable website', () {
    final json = _user.toJson();
    final restored = User.fromJson(json);
    expect(restored, _user);
    expect(restored.toJson(), json);
    expect(restored.phoneDigits, '+15551234');
    expect(User.fromJson(json..remove('website')).website, isNull);
    expect(() => User.fromJson(json..['id'] = '1'), throwsA(isA<TypeError>()));
  });

  test('HTTP errors take precedence over parsing the JSON body', () async {
    final repo = UserRepository(
      ApiClient(
        MockClient((request) async {
          expect(request.headers['accept'], 'application/json');
          return switch (request.url.path) {
            '/users/999' => http.Response('{}', 404),
            '/users/1' => http.Response('invalid', 401),
            '/users/2' => http.Response('invalid', 503),
            '/users/3' => http.Response('invalid', 200),
            '/users/4' => http.Response('{"id":"4"}', 200),
            _ => http.Response('{}', 200),
          };
        }),
      ),
    );
    addTearDown(repo.close);

    await expectLater(repo.getById(999), throwsA(isA<NotFoundException>()));
    await expectLater(repo.getById(1), throwsA(isA<UnauthorizedException>()));
    await expectLater(
      repo.getById(2),
      throwsA(
        isA<ServerException>().having((error) => error.status, 'status', 503),
      ),
    );
    await expectLater(repo.getById(3), throwsA(isA<BadResponseException>()));
    await expectLater(repo.getById(4), throwsA(isA<BadResponseException>()));
    await expectLater(repo.getAll(), throwsA(isA<BadResponseException>()));
  });

  testWidgets('a socket error and a ten-second stall reach Offline', (
    tester,
  ) async {
    var calls = 0;
    final stall = Completer<http.Response>();
    final model = UsersModel(
      UserRepository(
        ApiClient(
          MockClient((_) async {
            calls++;
            if (calls == 1) throw const SocketException('No route');
            if (calls == 2) return stall.future;
            return http.Response(jsonEncode([_user.toJson()]), 200);
          }),
        ),
      ),
    );
    await tester.pumpWidget(_app(model));
    await model.load();
    await tester.pump();
    expect(find.text('No network connection.'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 9999));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();
    expect(find.text('No network connection.'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Leanne Graham'), findsOneWidget);
    stall.complete(http.Response('[]', 200));
    await tester.pumpAndSettle();
    expect(find.text('Leanne Graham'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    model.dispose();
  });

  testWidgets('form sends one POST and keeps the created user after refresh', (
    tester,
  ) async {
    var posts = 0;
    final response = Completer<http.Response>();
    final model = UsersModel(
      UserRepository(
        ApiClient(
          MockClient((request) async {
            if (request.method == 'GET') {
              return http.Response(jsonEncode([_user.toJson()]), 200);
            }
            posts++;
            expect(request.method, 'POST');
            expect(request.url.path, '/users');
            expect(request.headers['content-type'], 'application/json');
            final draft = jsonDecode(request.body) as Map<String, dynamic>;
            expect(draft['name'], 'Practice User');
            return response.future;
          }),
        ),
      ),
    );
    await model.load();
    await tester.pumpWidget(_app(model));

    await tester.tap(find.text('New user'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Enter a name.'), findsOneWidget);
    expect(posts, 0);

    final inputs = find.byType(TextFormField);
    await tester.enterText(inputs.at(0), 'Practice User');
    await tester.enterText(inputs.at(1), 'practice11');
    await tester.enterText(inputs.at(2), 'practice@example.com');
    await tester.tap(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(posts, 1);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );

    response.complete(
      http.Response(
        jsonEncode({..._user.toJson(), 'id': 11, 'name': 'Practice User'}),
        201,
      ),
    );
    await tester.pumpAndSettle();
    expect(model.items.first.id, 11);
    expect(find.text('Practice User'), findsOneWidget);
    await model.load();
    expect(model.items.map((user) => user.id), [11, 1]);
    await tester.pumpWidget(const SizedBox());
    model.dispose();
  });
}

Widget _app(UsersModel model) =>
    ChangeNotifierProvider.value(value: model, child: const App());
