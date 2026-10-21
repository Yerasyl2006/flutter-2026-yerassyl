import 'dart:async';

import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../utils/format.dart';
import 'meetup_form.dart';

class MeetupScreen extends StatefulWidget {
  const MeetupScreen({super.key, required this.id});
  final String id;

  @override
  State<MeetupScreen> createState() => _MeetupScreenState();
}

class _MeetupScreenState extends State<MeetupScreen> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _msg(String s) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (c) => AlertDialog(
            title: const Text('Delete meetup?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(c, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (ok == true && mounted) {
      appState.delete(widget.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, child) {
        final m = appState.byId(widget.id);
        if (m == null) return const Scaffold();
        final name = appState.profile.name;
        final joined = name.isNotEmpty && m.contains(name);

        return Scaffold(
          appBar: AppBar(
            title: Text(m.title, overflow: TextOverflow.ellipsis),
            actions: [
              IconButton(
                icon: Icon(
                  m.isFavourite ? Icons.favorite : Icons.favorite_border,
                ),
                onPressed: () => appState.toggleFavourite(m.id),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MeetupForm(meetup: m)),
                    ),
              ),
              IconButton(icon: const Icon(Icons.delete), onPressed: _delete),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(m.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                formatCountdown(m.countdown),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Divider(height: 24),
              Text('Language: ${m.language.label}'),
              Text('When: ${formatDate(m.startsAt)}'),
              Text('${m.isOnline ? 'Link' : 'Place'}: ${m.place}'),
              Text(
                'Places: ${m.count}/${m.capacity}'
                '${m.isFull ? ' (FULL)' : ''}',
              ),
              const SizedBox(height: 8),
              Text(m.topic ?? 'No description'),
              const SizedBox(height: 16),
              if (joined)
                OutlinedButton(
                  onPressed: m.isPast ? null : () => appState.leave(m.id),
                  child: const Text('Leave'),
                )
              else
                FilledButton(
                  onPressed:
                      (m.isFull || m.isPast)
                          ? null
                          : () {
                            if (name.isEmpty) {
                              _msg('Fill in your name in Profile first');
                            } else {
                              appState.join(m.id);
                            }
                          },
                  child: Text(
                    m.isPast
                        ? 'Meetup is over'
                        : m.isFull
                        ? 'Full'
                        : 'Join',
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                'Participants (${m.count})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (m.participants.isEmpty) const Text('Nobody yet'),
              for (final p in m.participants)
                ListTile(dense: true, title: Text(p)),
            ],
          ),
        );
      },
    );
  }
}
