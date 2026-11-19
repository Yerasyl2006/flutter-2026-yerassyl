import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:users_api/features/users/user.dart';

import '../../fixtures/user_one_json.dart';

void main() {
  group('User.fromJson', () {
    test('reads user 1, including nested city and double latitude', () {
      final json = jsonDecode(userOneJson) as Map<String, dynamic>;
      final user = User.fromJson(json);
      expect(user.name, 'Leanne Graham');
      expect(user.address.city, 'Gwenborough');
      expect(user.address.geo.lat, isA<double>());
      expect(user.address.geo.lat, -37.3159);
    });

    test('rejects a string id', () {
      final json = jsonDecode(userOneJson) as Map<String, dynamic>;
      json['id'] = '1';
      expect(() => User.fromJson(json), throwsA(isA<TypeError>()));
    });
  });

  test('Geo.fromJson rejects a numeric lat', () {
    final json = {'lat': -37.3159, 'lng': '81.1496'};
    expect(() => Geo.fromJson(json), throwsA(isA<TypeError>()));
  });
}
