import 'dart:async';
import 'package:flutter/material.dart';
import 'api/countdown.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  bool _manual = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Countdown')),
    body: Column(
      children: [
        const SizedBox(height: 24),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('A · StreamBuilder')),
            ButtonSegment(value: true, label: Text('B · Subscription')),
          ],
          selected: {_manual},
          onSelectionChanged: (value) => setState(() => _manual = value.single),
        ),
        Expanded(
          child: _manual ? const ManualCountdown() : const BuilderCountdown(),
        ),
      ],
    ),
  );
}

class BuilderCountdown extends StatefulWidget {
  const BuilderCountdown({super.key});

  @override
  State<BuilderCountdown> createState() => _BuilderCountdownState();
}

class _BuilderCountdownState extends State<BuilderCountdown> {
  late final Stream<int> _stream = countdown(10);

  @override
  Widget build(BuildContext context) => StreamBuilder<int>(
    stream: _stream,
    builder:
        (context, snapshot) => Center(
          child: Text(
            '${snapshot.data ?? 10}',
            style: Theme.of(context).textTheme.displayLarge,
          ),
        ),
  );
}

class ManualCountdown extends StatefulWidget {
  const ManualCountdown({super.key});

  @override
  State<ManualCountdown> createState() => _ManualCountdownState();
}

class _ManualCountdownState extends State<ManualCountdown> {
  int _left = 10;
  late StreamSubscription<int> _sub;

  @override
  void initState() {
    super.initState();
    _sub = countdown(10).listen((i) => setState(() => _left = i));
  }

  @override
  void dispose() {
    unawaited(_sub.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
    child: Text('$_left', style: Theme.of(context).textTheme.displayLarge),
  );
}
