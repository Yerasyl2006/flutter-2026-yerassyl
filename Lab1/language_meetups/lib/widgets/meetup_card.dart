import 'package:flutter/material.dart';

import '../models/meetup.dart';
import '../screens/meetup_screen.dart';
import '../state/app_state.dart';
import '../utils/format.dart';

class MeetupCard extends StatelessWidget {
  const MeetupCard({super.key, required this.meetup});
  final Meetup meetup;

  @override
  Widget build(BuildContext context) {
    final m = meetup;
    final (:taken, :free) = m.places;
    return Opacity(
      opacity: m.isPast ? 0.55 : 1,
      child: Card(
        child: ListTile(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MeetupScreen(id: m.id)),
              ),
          leading: CircleAvatar(child: Text(m.language.code)),
          title: Text(m.title, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            '${formatDate(m.startsAt)} • ${m.isOnline ? 'Online' : 'Offline'}\n'
            '$taken/${m.capacity} joined'
            '${m.isFull
                ? ' • FULL'
                : m.isAlmostFull
                ? ' • $free left'
                : ''}',
          ),
          isThreeLine: true,
          trailing: IconButton(
            icon: Icon(m.isFavourite ? Icons.favorite : Icons.favorite_border),
            color: m.isFavourite ? Colors.red : null,
            onPressed: () => appState.toggleFavourite(m.id),
          ),
        ),
      ),
    );
  }
}
