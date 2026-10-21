import '../models/language.dart';
import '../models/meetup.dart';

DateTime _at(int dayOffset, int hour) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day + dayOffset, hour);
}

List<String> _names(int n) =>
    List.unmodifiable(List.generate(n, (i) => 'Student ${i + 1}'));

List<Meetup> buildSeed() => [
  Meetup(
    id: '1',
    title: 'English Speaking Club',
    language: Language.english,
    startsAt: _at(1, 18),
    capacity: 15,
    participants: _names(8),
    isOnline: false,
    place: 'Room 204',
    topic: 'Free talk about travel and hobbies',
  ),
  Meetup(
    id: '2',
    title: 'Korean for Beginners',
    language: Language.korean,
    startsAt: _at(2, 17),
    capacity: 10,
    participants: _names(10), // FULL
    isOnline: false,
    place: 'Library, hall B',
    topic: 'Hangul basics and greetings',
  ),
  Meetup(
    id: '3',
    title: 'Japanese Anime Night',
    language: Language.japanese,
    startsAt: _at(3, 19),
    capacity: 20,
    participants: _names(12),
    isOnline: true,
    place: 'https://meet.example.com/anime',
    topic: 'Watching an episode and discussing phrases',
  ),
  Meetup(
    id: '4',
    title: 'German Grammar Workshop',
    language: Language.german,
    startsAt: _at(5, 16),
    capacity: 12,
    participants: _names(7),
    isOnline: false,
    place: 'Room 101',
  ), // без topic
  Meetup(
    id: '5',
    title: 'Spanish Conversation',
    language: Language.spanish,
    startsAt: _at(6, 18),
    capacity: 8,
    participants: _names(3),
    isOnline: true,
    place: 'https://meet.example.com/spanish',
    topic: 'Everyday dialogues',
  ),
  Meetup(
    id: '6',
    title: 'Chinese Tea & Talk',
    language: Language.chinese,
    startsAt: _at(7, 17),
    capacity: 6,
    participants: _names(5), // 1 место
    isOnline: false,
    place: 'Cafe Orbit',
    topic: 'Tea ceremony vocabulary',
  ),
  Meetup(
    id: '7',
    title:
        'Speaking club: ordering food, taxis, tickets and daily chats', // 60 символов
    language: Language.english,
    startsAt: _at(8, 15),
    capacity: 25,
    participants: _names(4),
    isOnline: false,
    place: 'Room 305',
  ), // без topic
  Meetup(
    id: '8',
    title: 'IELTS Speaking Practice',
    language: Language.english,
    startsAt: _at(10, 14),
    capacity: 10,
    participants: _names(1),
    isOnline: true,
    place: 'https://meet.example.com/ielts',
    topic: 'Part 2 cue cards',
  ),
  Meetup(
    id: '9',
    title: 'Hangul Writing Lab',
    language: Language.korean,
    startsAt: _at(12, 16),
    capacity: 14,
    participants: _names(0), // пустой список
    isOnline: false,
    place: 'Room 210',
  ), // без topic
  Meetup(
    id: '10',
    title: 'Movie Night in Spanish',
    language: Language.spanish,
    startsAt: _at(-1, 19),
    capacity: 18,
    participants: _names(16), // прошла
    isOnline: false,
    place: 'Cinema hall',
    topic: 'Short film with subtitles',
  ),
  Meetup(
    id: '11',
    title: 'Business German',
    language: Language.german,
    startsAt: _at(-4, 17),
    capacity: 10,
    participants: _names(6), // прошла
    isOnline: true,
    place: 'https://meet.example.com/bizde',
  ),
  Meetup(
    id: '12',
    title: 'Kanji Challenge',
    language: Language.japanese,
    startsAt: _at(-9, 18),
    capacity: 12,
    participants: _names(9), // прошла
    isOnline: false,
    place: 'Room 108',
    topic: 'Learning 20 new kanji',
  ),
];
