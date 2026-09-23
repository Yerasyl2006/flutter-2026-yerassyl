import 'package:flutter/material.dart';

import 'data.dart';
import 'facts_card.dart';
import 'profile_header.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.deepPurple);
    return MaterialApp(
      theme: ThemeData(
        colorScheme: scheme,
        appBarTheme: AppBarTheme(backgroundColor: scheme.primaryContainer),
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('My profile')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ProfileHeader(name: myName, university: myUniversity),
              const SizedBox(height: 8),
              FactsCard(facts: facts),
            ],
          ),
        ),
      ),
    );
  }
}
