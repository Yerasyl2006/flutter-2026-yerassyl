import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:practice9/main.dart';
import 'package:practice9/cart_badge.dart';
import 'package:practice9/models/book.dart';
import 'package:practice9/models/cart.dart';

class WatchProbe extends StatelessWidget {
  const WatchProbe({super.key, required this.onBuild});
  final VoidCallback onBuild;
  @override
  Widget build(BuildContext context) {
    final n = context.watch<Cart>().count;
    onBuild();
    return Text('$n');
  }
}

void main() {
  testWidgets('measure watch versus real select badge', (tester) async {
    final cart = Cart()..add(books[0]);
    var watchBuilds = 0;
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: cart,
        child: MaterialApp(
          home: Scaffold(body: WatchProbe(onBuild: () => watchBuilds++)),
        ),
      ),
    );
    watchBuilds = 0;
    for (var i = 0; i < 3; i++) {
      cart.increment(books[0]);
      await tester.pump();
    }
    expect(watchBuilds, 3);
    final savedPrint = debugPrint;
    var badgeBuilds = 0;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message == 'badge build') badgeBuilds++;
    };
    try {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: cart,
          child: const MaterialApp(home: Scaffold(body: CartBadge())),
        ),
      );
      badgeBuilds = 0;
      for (var i = 0; i < 3; i++) {
        cart.increment(books[0]);
        await tester.pump();
      }
      expect(badgeBuilds, 0);
      cart.remove(books[0]);
      await tester.pump();
      expect(badgeBuilds, 1);
    } finally {
      debugPrint = savedPrint;
    }
    debugPrint('MEASURED: watch=3, select=0, select after removal=1');
    await tester.pumpWidget(const SizedBox());
    cart.dispose();
  });
  testWidgets('capture required screens', (tester) async {
    tester.view.physicalSize = const Size(1100, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      final textFont = FontLoader('Roboto')..addFont(
        File(
          'C:/Windows/Fonts/segoeui.ttf',
        ).readAsBytes().then((b) => ByteData.view(b.buffer)),
      );
      final icons = FontLoader('MaterialIcons')..addFont(
        File(
          'C:/dev/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
        ).readAsBytes().then((b) => ByteData.view(b.buffer)),
      );
      await textFont.load();
      await icons.load();
    });
    final key = GlobalKey();
    final cart =
        Cart()
          ..add(books[0])
          ..add(books[1]);
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => cart,
        child: RepaintBoundary(key: key, child: const Shell()),
      ),
    );
    await tester.pumpAndSettle();
    Future<void> capture(String filename) async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await tester.runAsync(
        () => boundary.toImage(pixelRatio: 1.5),
      );
      final bytes = await tester.runAsync(
        () => image!.toByteData(format: ui.ImageByteFormat.png),
      );
      await tester.runAsync(() async {
        await File(filename).writeAsBytes(bytes!.buffer.asUint8List());
      });
      image!.dispose();
    }

    await capture('screenshot_books.png');
    await tester.tap(find.byTooltip('Open cart'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Increase quantity').first);
    await tester.pumpAndSettle();
    await capture('screenshot_cart.png');
  });
}
