import 'package:flutter/material.dart';

import 'info_row.dart';

class FactsCard extends StatelessWidget {
  const FactsCard({super.key, required this.facts});

  final List<({String label, String value})> facts;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            for (final fact in facts)
              InfoRow(label: fact.label, value: fact.value),
          ],
        ),
      ),
    );
  }
}
