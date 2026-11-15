import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/auth/auth_model.dart';
import 'features/auth/login_screen.dart';

class Session extends StatelessWidget {
  const Session({required this.signedIn, super.key});

  final Widget signedIn;

  @override
  Widget build(BuildContext context) =>
      context.select((AuthModel auth) => auth.signedIn)
          ? signedIn
          : const LoginScreen();
}
