import 'package:flutter/material.dart';

import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    final address = user.address;
    final website = user.website;
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        children: [
          _field('ID', '${user.id}'),
          _field('Username', user.username),
          _field('Email', user.email),
          _field('Phone', user.phone, onTap: user.phone.isEmpty ? null : () {}),
          _field(
            'Website',
            website ?? '',
            onTap: website == null ? null : () {},
          ),
          _field('Street', address.street),
          _field('Suite', address.suite),
          _field('City', address.city),
          _field('ZIP code', address.zipcode),
          if (address.city.isNotEmpty)
            _field('Coordinates', '${address.geo.lat}, ${address.geo.lng}'),
          _field('Company', user.company.name),
          _field('Catchphrase', user.company.catchPhrase),
          _field('Business', user.companyBs),
        ],
      ),
    );
  }

  Widget _field(String label, String value, {VoidCallback? onTap}) => ListTile(
    title: Text(label),
    subtitle: Text(value.isEmpty ? '—' : value),
    onTap: onTap,
  );
}
