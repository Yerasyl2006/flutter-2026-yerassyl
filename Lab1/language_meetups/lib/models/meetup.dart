import 'countdown.dart';
import 'language.dart';

class Meetup {
  const Meetup({
    required this.id,
    required this.title,
    required this.language,
    required this.startsAt,
    required this.capacity,
    required this.participants,
    required this.isOnline,
    required this.place,
    this.topic,
    this.isFavourite = false,
  });

  Meetup.empty()
    : this(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: '',
        language: Language.english,
        startsAt: DateTime.now().add(const Duration(days: 1)),
        capacity: 10,
        participants: const [],
        isOnline: false,
        place: '',
      );

  final String id;
  final String title;
  final Language language;
  final DateTime startsAt;
  final int capacity;
  final List<String> participants;
  final bool isOnline;
  final String place;
  final String? topic;
  final bool isFavourite;

  Meetup copyWith({
    String? title,
    Language? language,
    DateTime? startsAt,
    int? capacity,
    List<String>? participants,
    bool? isOnline,
    String? place,
    String? topic,
    bool? isFavourite,
  }) => Meetup(
    id: id,
    title: title ?? this.title,
    language: language ?? this.language,
    startsAt: startsAt ?? this.startsAt,
    capacity: capacity ?? this.capacity,
    participants:
        participants == null
            ? this.participants
            : List.unmodifiable(participants),
    isOnline: isOnline ?? this.isOnline,
    place: place ?? this.place,
    topic: topic ?? this.topic,
    isFavourite: isFavourite ?? this.isFavourite,
  );

  int get count => participants.length;
  int get free => capacity - count;
  bool get isFull => count >= capacity;
  bool get isAlmostFull => free > 0 && free <= 5;
  bool get isPast => startsAt.isBefore(DateTime.now());
  bool contains(String name) => participants.contains(name);

  ({int taken, int free}) get places => (taken: count, free: free);

  Countdown get countdown {
    final diff = startsAt.difference(DateTime.now());
    if (!diff.isNegative) return Upcoming(diff);
    final since = -diff;
    return since < const Duration(hours: 2) ? Started(since) : const Ended();
  }
}
