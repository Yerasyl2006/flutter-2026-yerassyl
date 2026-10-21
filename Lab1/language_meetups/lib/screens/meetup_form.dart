import 'package:flutter/material.dart';

import '../models/language.dart';
import '../models/meetup.dart';
import '../state/app_state.dart';
import '../utils/format.dart';
import '../utils/validators.dart';

class MeetupForm extends StatefulWidget {
  const MeetupForm({super.key, this.meetup});
  final Meetup? meetup; // null = создание

  @override
  State<MeetupForm> createState() => _MeetupFormState();
}

class _MeetupFormState extends State<MeetupForm> {
  final _key = GlobalKey<FormState>();
  late final Meetup _base = widget.meetup ?? Meetup.empty();
  late final _title = TextEditingController(text: _base.title);
  late final _place = TextEditingController(text: _base.place);
  late final _capacity = TextEditingController(text: '${_base.capacity}');
  late final _topic = TextEditingController(text: _base.topic ?? '');
  late Language _language = _base.language;
  late bool _online = _base.isOnline;
  late DateTime _startsAt = _base.startsAt;

  @override
  void dispose() {
    for (final c in [_title, _place, _capacity, _topic]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _startsAt,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startsAt),
    );
    if (t == null) return;
    setState(
      () => _startsAt = DateTime(d.year, d.month, d.day, t.hour, t.minute),
    );
  }

  void _save() {
    if (!_key.currentState!.validate()) return;
    if (widget.meetup == null && _startsAt.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Date must be in the future')),
      );
      return;
    }
    final topic = _topic.text.trim();
    final m = _base.copyWith(
      title: _title.text.trim(),
      language: _language,
      startsAt: _startsAt,
      capacity: int.parse(_capacity.text.trim()),
      isOnline: _online,
      place: _place.text.trim(),
      topic: topic.isEmpty ? null : topic,
    );
    appState.upsert(m);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.meetup != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit meetup' : 'New meetup')),
      body: Form(
        key: _key,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: validateTitle,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Language>(
              value: _language,
              decoration: const InputDecoration(labelText: 'Language'),
              items: [
                for (final l in Language.values)
                  DropdownMenuItem(value: l, child: Text(l.label)),
              ],
              onChanged: (l) => setState(() => _language = l ?? _language),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Starts: ${formatDate(_startsAt)}'),
              trailing: const Icon(Icons.calendar_month),
              onTap: _pickDate,
            ),
            TextFormField(
              controller: _capacity,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Capacity'),
              validator:
                  (v) => validateCapacity(
                    v,
                    min: _base.count < 2 ? 2 : _base.count,
                  ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Online'),
              value: _online,
              onChanged: (v) => setState(() => _online = v),
            ),
            TextFormField(
              controller: _place,
              decoration: InputDecoration(
                labelText: _online ? 'Link' : 'Place',
              ),
              validator: (v) => validatePlace(v, online: _online),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _topic,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Topic (optional)'),
              validator: validateTopic,
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
