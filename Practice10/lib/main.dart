import 'package:flutter/material.dart';
import 'api/fake_api.dart';
import 'countdown_screen.dart';
import 'students_future_screen.dart';
import 'students_screen.dart';

void main() => runApp(const StudentsApp());

class StudentsApp extends StatelessWidget {
  const StudentsApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(home: HomeScreen());
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _manualApi = FakeApi();
  final _futureApi = FakeApi();

  Future<void> _open(BuildContext context, Widget screen) async {
    await Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Practice 10')),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () => _open(context, StudentsScreen(api: _manualApi)),
            child: const Text('By hand'),
          ),
          ElevatedButton(
            onPressed:
                () => _open(context, StudentsFutureScreen(api: _futureApi)),
            child: const Text('FutureBuilder'),
          ),
          ElevatedButton(
            onPressed: () => _open(context, const CountdownScreen()),
            child: const Text('Countdown'),
          ),
        ],
      ),
    ),
  );
}
