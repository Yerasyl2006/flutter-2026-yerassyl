import 'package:flutter_test/flutter_test.dart';
import 'package:users_api/core/api/api_exception.dart';
import 'package:users_api/features/users/users_model.dart';

import '../../fakes/fake_user_repository.dart';

void main() {
  group('UsersModel.load', () {
    test('loads the two users and clears loading', () async {
      final model = UsersModel(FakeUserRepository());
      addTearDown(model.dispose);
      await model.load();
      expect(
        (model.items.length, model.loading, model.error),
        (2, false, null),
      );
    });

    test('records NoConnectionException and clears loading', () async {
      final model = UsersModel(FakeUserRepository(fail: true));
      addTearDown(model.dispose);
      await model.load();
      expect(model.error, isA<NoConnectionException>());
      expect(model.loading, isFalse);
    });
  });
}
