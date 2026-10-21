import 'package:flutter/material.dart';

import '../models/language.dart';
import '../state/app_state.dart';
import '../widgets/meetup_card.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key, this.onlyFavourites = false});
  final bool onlyFavourites;

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  String _query = '';
  Language? _language;
  bool _showPast = true;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final items =
            appState.meetups.where((m) {
                if (widget.onlyFavourites && !m.isFavourite) return false;
                if (_language != null && m.language != _language) return false;
                if (!_showPast && m.isPast) return false;
                return m.title.toLowerCase().contains(_query.toLowerCase());
              }).toList()
              ..sort((a, b) => a.startsAt.compareTo(b.startsAt));

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search by title',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  for (final l in Language.values)
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: FilterChip(
                        label: Text(l.label),
                        selected: _language == l,
                        onSelected:
                            (s) => setState(() => _language = s ? l : null),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: FilterChip(
                      label: const Text('Hide past'),
                      selected: !_showPast,
                      onSelected: (s) => setState(() => _showPast = !s),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child:
                  items.isEmpty
                      ? const Center(child: Text('Nothing found'))
                      : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (_, i) => MeetupCard(meetup: items[i]),
                      ),
            ),
          ],
        );
      },
    );
  }
}
