import 'package:flutter/material.dart';
import 'main.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, required this.items, required this.onRemove});
  final List<Book> items;
  final void Function(Book) onRemove;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Cart')),
    body: Column(
      children: [
        Expanded(
          child: ListView(
            children:
                items
                    .map(
                      (b) => ListTile(
                        title: Text(b.title),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => onRemove(b),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
        Text('Total: ${items.fold<int>(0, (s, b) => s + b.price)} ₸'),
      ],
    ),
  );
}
