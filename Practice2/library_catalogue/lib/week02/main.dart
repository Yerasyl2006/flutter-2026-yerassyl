import 'data.dart';
import 'models.dart';
import 'catalogue.dart';
import 'shelf_state.dart';

void main() {
  final library = Library();
  library.open();

  for (final raw in rawBooks) {
    library.add(Book.fromJson(raw));
  }

  print('--- Titles ---');
  print(library.allTitles);

  print('--- Books after 2010 ---');
  print(library.booksAfter2010);

  print('--- Average pages ---');
  print(library.averagePages);

  print('--- Book count by author ---');
  print(library.bookCountByAuthor);

  print('--- Distinct authors ---');
  print(library.distinctAuthors);

  print('--- Genres present ---');
  print(library.genresPresent);

  print('--- Report ---');
  library.buildReportLines().forEach(print);

  final books = library.items.whereType<Book>().toList();
  final stats = statsOf(books);
  print('--- Stats record ---');
  print('count: ${stats.count}, avgPages: ${stats.avgPages}');

  print('--- Shelf states ---');
  print(describe(const Empty()));
  print(describe(Ready(books)));
  print(describe(const Broken('shelf collapsed')));
}
