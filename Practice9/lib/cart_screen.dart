import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/cart.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _expanded = true;
  Future<void> _clear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear cart?'),
            content: const Text('Remove all books from your cart?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Clear'),
              ),
            ],
          ),
    );
    if (!context.mounted) return;
    if (confirmed == true) context.read<Cart>().clear();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Cart'),
      actions: [
        TextButton(
          onPressed: () => _clear(context),
          child: const Text('Clear cart'),
        ),
      ],
    ),
    body: Column(
      children: [
        Expanded(
          child: Consumer<Cart>(
            builder: (context, cart, _) {
              if (cart.count == 0) {
                return const Center(child: Text('Your cart is empty'));
              }
              return ListView(
                children:
                    cart.items
                        .map(
                          (b) => ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 10,
                            ),
                            title: Text(b.title),
                            subtitle: Text(
                              '${b.price} ₸ ×${cart.qtyOf(b)} = ${b.price * cart.qtyOf(b)} ₸',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Increase quantity',
                                  onPressed: () => cart.increment(b),
                                  icon: const Icon(Icons.add),
                                ),
                                IconButton(
                                  tooltip: 'Remove book',
                                  onPressed: () => cart.remove(b),
                                  icon: const Icon(Icons.close),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
              );
            },
          ),
        ),
        const Divider(height: 1),
        Consumer<Cart>(
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long),
              SizedBox(width: 8),
              Text('Total'),
            ],
          ),
          builder:
              (context, cart, child) => ListTile(
                leading: child!,
                title: Text(_expanded ? '${cart.total} ₸' : 'Hidden'),
                trailing: IconButton(
                  tooltip: 'Toggle total',
                  onPressed: () => setState(() => _expanded = !_expanded),
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                ),
              ),
        ),
        const SizedBox(height: 16),
      ],
    ),
  );
}
