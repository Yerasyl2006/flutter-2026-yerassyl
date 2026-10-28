import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:practice9/main.dart';
import 'package:practice9/models/book.dart';
import 'package:practice9/models/cart.dart';

void main() {
  test(
    'cart protects items, rejects duplicates, calculates quantities and notifies',
    () {
      final cart = Cart();
      addTearDown(cart.dispose);
      var notifications = 0;
      cart.addListener(() => notifications++);
      expect(cart.add(books[0]), isTrue);
      expect(cart.add(books[1]), isTrue);
      expect(cart.add(books[0]), isFalse);
      expect(notifications, 2);
      expect(() => cart.items.add(books[2]), throwsUnsupportedError);
      cart.remove(books[0]);
      expect(cart.count, 1);
      expect(cart.total, 3100);
      cart.increment(books[1]);
      expect(cart.count, 1);
      expect(cart.qtyOf(books[1]), 2);
      expect(cart.total, 6200);
      cart.clear();
      expect(cart.items, isEmpty);
      expect(cart.total, 0);
      expect(notifications, 5);
    },
  );
  testWidgets('add, quantity, removal, search and clear confirmation', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(create: (_) => Cart(), child: const Shell()),
    );
    await tester.tap(find.text('Add').at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add').at(0));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: find.byType(ListTile), matching: find.text('Added')),
      findsNWidgets(2),
    );
    await tester.tap(find.byTooltip('Open cart'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Increase quantity').first);
    await tester.pumpAndSettle();
    expect(find.text('11500 ₸'), findsOneWidget);
    await tester.tap(find.text('Clear cart'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Remove book'), findsNWidgets(2));
    await tester.tap(find.byTooltip('Remove book').first);
    await tester.pumpAndSettle();
    expect(find.text('3100 ₸'), findsOneWidget);
    await tester.tap(find.text('Clear cart'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();
    expect(find.text('Your cart is empty'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Null Safety');
    await tester.pumpAndSettle();
    expect(find.text(books[1].title), findsOneWidget);
    expect(find.text(books[0].title), findsNothing);
  });
}
