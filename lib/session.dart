import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/storage/secure_store.dart';
import 'features/auth/auth_model.dart';
import 'features/auth/login_screen.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_model.dart';
import 'features/users/users_screen.dart';

class Session extends StatelessWidget {
  const Session();

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
