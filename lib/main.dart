import 'package:flutter/material.dart';
import 'books_screen.dart';
import 'cart_screen.dart';

void main() => runApp(const Shell());

class Book {
  const Book(this.title, this.author, this.price);
  final String title;
  final String author;
  final int price;
}

const books = [
  Book('Widgets All the Way Down', 'A. Nurmagambetova', 4200),
  Book('Null Safety for Humans', 'B. Seitkali', 3100),
  Book('Constraints Go Down, Sizes Go Up', 'C. Tashimova', 5600),
  Book('The Navigator Is a Stack', 'D. Alibekov', 2900),
  Book('Forms That Validate Themselves', 'E. Omarova', 3800),
  Book('Put It High, Subscribe Low', 'F. Kairatuly', 4700),
];

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  final List<Book> _cart = [];
  void _add(Book b) => setState(() => _cart.add(b));
  void _remove(Book b) => setState(() => _cart.remove(b));
  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(colorSchemeSeed: Colors.orange),
    routes: {
      '/':
          (_) => BooksScreen(
            cart: _cart,
            total: _cart.fold(0, (s, b) => s + b.price),
            onAdd: _add,
          ),
      '/cart': (_) => CartScreen(items: _cart, onRemove: _remove),
    },
  );
}
