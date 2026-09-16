import 'models.dart';

class Library {
  final List<LibraryItem> items = [];

  void add(LibraryItem item) => items.add(item);

  Book? findByTitle(String title) {
    for (final item in items) {
      if (item is Book && item.title == title) return item;
    }
    return null;
  }

  String countryOf(String title) =>
      findByTitle(title)?.author.country ?? 'unknown';

  late final DateTime openedAt;

  void open() {
    openedAt = DateTime.now();
  }

  String? _cachedReport;

  String report() {
    final cached = _cachedReport;
    if (cached != null) return cached;
    final result = 'Library with ${items.length} items';
    _cachedReport = result;
    return result;
  }
    
  List<String> get allTitles => items.map((item) => item.title).toList();

  
  List<Book> get booksAfter2010 =>
      items.whereType<Book>().where((b) => b.year > 2010).toList();

  
  double get averagePages {
    final books = items.whereType<Book>().toList();
    if (books.isEmpty) return 0;
    final total = books.fold<int>(0, (sum, b) => sum + b.pages);
    return total / books.length;
  }

  
    Map<String, int> get bookCountByAuthor =>
      items.whereType<Book>().fold<Map<String, int>>({}, (map, b) {
        map[b.author.name] = (map[b.author.name] ?? 0) + 1;
        return map;
      });

  
  Set<String> get distinctAuthors =>
      items.whereType<Book>().map((b) => b.author.name).toSet();

  
  Set<Genre> get genresPresent =>
      items.whereType<Book>().map((b) => b.genre).toSet();
        List<String> buildReportLines() => [
    'CATALOGUE',
    for (final b in items.whereType<Book>()) '${b.title} (${b.year})',
    ...distinctAuthors,
    if (items.whereType<Book>().any((b) => b.pages == 0)) '(incomplete data)',
  ];
}
