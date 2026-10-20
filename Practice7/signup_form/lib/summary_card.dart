import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.name,
    required this.email,
    required this.group,
    required this.birth,
  });

  final String name;
  final String email;
  final String group;
  final String birth;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      ListTile(title: Text(name), subtitle: const Text('Name')),
      ListTile(title: Text(email), subtitle: const Text('Email')),
      ListTile(title: Text(group), subtitle: const Text('Group')),
      ListTile(title: Text(birth), subtitle: const Text('Date of birth')),
    ];

    return Card(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 600) {
            return GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              childAspectRatio: 4,
              physics: const NeverScrollableScrollPhysics(),
              children: tiles,
            );
          }
          return Column(children: tiles);
        },
      ),
    );
  }
}
