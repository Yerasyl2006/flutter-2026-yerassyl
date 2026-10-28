import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/book.dart';
import 'models/cart.dart';
import 'cart_badge.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});
  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  String _query = '';
  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');
    final filtered =
        books
            .where(
              (b) => '${b.title} ${b.author}'.toLowerCase().contains(
                _query.toLowerCase(),
              ),
            )
            .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
        actions: const [CartBadge()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(76),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search books or authors',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
        ),
      ),
      body:
          filtered.isEmpty
              ? const Center(child: Text('No books found'))
              : ListView(
                children: filtered.map((b) => BookRow(book: b)).toList(),
              ),
    );
  }
}

class BookRow extends StatelessWidget {
  const BookRow({super.key, required this.book});
  final Book book;
  @override
  Widget build(BuildContext context) {
    debugPrint('row ${book.title}');
    final added = context.select<Cart, bool>((c) => c.items.contains(book));
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      leading: const Icon(Icons.menu_book),
      title: Text(book.title),
      subtitle: Text('${book.author}\n${book.price} ₸'),
      isThreeLine: true,
      trailing:
          added
              ? const Text('Added')
              : OutlinedButton(
                onPressed: () {
                  final ok = context.read<Cart>().add(book);
                  if (ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Added'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
                child: const Text('Add'),
              ),
    );
  }
}
