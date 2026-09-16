import 'models.dart';

sealed class ShelfState {
  const ShelfState();
}

class Empty extends ShelfState {
  const Empty();
}

class Ready extends ShelfState {
  final List<Book> books;
  const Ready(this.books);
}

class Broken extends ShelfState {
  final String message;
  const Broken(this.message);
}

String describe(ShelfState state) => switch (state) {
  Empty() => 'Shelf is empty',
  Ready(books: final b) => 'Shelf ready with ${b.length} book(s)',
  Broken(message: final m) => 'Shelf broken: $m',
};

({int count, double avgPages}) statsOf(List<Book> books) {
  if (books.isEmpty) return (count: 0, avgPages: 0.0);
  final total = books.fold<int>(0, (sum, b) => sum + b.pages);
  return (count: books.length, avgPages: total / books.length);
}
