import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/cart.dart';

class CartBadge extends StatelessWidget {
  const CartBadge({super.key});
  @override
  Widget build(BuildContext context) {
    final n = context.select<Cart, int>((c) => c.count);
    debugPrint('badge build');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _BadgeTotal(),
        IconButton(
          tooltip: 'Open cart',
          onPressed: () => Navigator.of(context).pushNamed('/cart'),
          icon: Badge(
            label: Text('$n'),
            child: const Icon(Icons.shopping_cart),
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}

class _BadgeTotal extends StatelessWidget {
  const _BadgeTotal();
  @override
  Widget build(BuildContext context) {
    final total = context.select<Cart, int>((c) => c.total);
    return Text('$total ₸');
  }
}
