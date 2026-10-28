# Practice 9 — Put It High, Subscribe Low

Flutter bookshop with a shared provider cart, per-book quantities, search, a cart badge, totals, SnackBar feedback and a clear confirmation dialog.

## Run

```powershell
cd Practice9
flutter pub get
flutter run -d chrome
```

## Check

```powershell
flutter analyze
flutter test test/cart_test.dart
```

See NOTES.md for the Russian explanation and measured rebuild counts. The `lifted` commit preserves the original setState implementation. The final implementation uses provider. Screenshots are screenshot_books.png and screenshot_cart.png. The evidence screenshot test uses the Windows fonts and Flutter SDK paths from the development computer.
