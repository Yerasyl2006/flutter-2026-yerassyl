import 'package:flutter/material.dart';

class UsersEmptyState extends StatelessWidget {
  const UsersEmptyState({super.key});

  @override
  Widget build(BuildContext context) =>
      const ListTile(title: Text('No users match this city.'));
}
