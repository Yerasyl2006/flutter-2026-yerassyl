# Practice 14 — Ship It

Users is a Flutter directory with a local demo sign-in, an offline cache, and a release build that reports its environment in Settings → About.

## Run

Use Flutter 3.35.7 and JDK 17 for Android. Run these from the project directory. To sign in, enter an email and a demo password of at least eight characters.

```sh
flutter pub get
flutter run
flutter run --dart-define=USE_FAKES=true
flutter run --dart-define-from-file=env/local.json
flutter build apk --release --dart-define-from-file=env/prod.json
```

The fakes build serves two users without HTTP. For the staging offline screen, run `flutter run --dart-define-from-file=env/staging.json`. That environment uses `example.invalid`, which cannot resolve. Debug builds offer **Settings → Developer: API host**, with a **Reset** action to restore the build's host. The API accepts an HTTPS host with an optional port.

## Build

Configure the private upload keystore before building release. In PowerShell, generate your own key outside the repository if you do not already have it.

```powershell
keytool -genkeypair -keystore "$env:USERPROFILE/upload-keystore.jks" -storetype PKCS12 -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Create `android/key.properties` locally with these four properties. With a PKCS12 keystore, use the same password in both fields. On Windows, use forward slashes in the absolute path.

```properties
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=upload
storeFile=C:/absolute/path/upload-keystore.jks
```

```sh
dart run flutter_launcher_icons
dart run flutter_native_splash:create
flutter build apk --debug
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/symbols --dart-define-from-file=env/prod.json
flutter build apk --release --target-platform android-arm64 --obfuscate --split-debug-info=build/symbols-direct --dart-define-from-file=env/prod.json
flutter build appbundle --release --dart-define-from-file=env/prod.json
```

The split command produces three APKs with ABI-specific version codes. Archive them with `build/symbols/` in `releases/1.0.1+2/split-apks/`. For direct installation on an ARM64 phone, take the single-target command's `app-release.apk`, name it `app-arm64-v8a-release.apk` and archive it alongside its own `symbols/` directory from `build/symbols-direct/`. On this installer, About reports `1.0.1 (2)`. Use the AAB for Google Play distribution.

## Pre-release checklist

- [x] Set Android application ID and namespace · `kz.yerassyl.users`
- [x] Set the version and increment the build number · `pubspec.yaml`
- [x] Ignore the upload key and local signing properties · `git check-ignore`
- [ ] Back up the upload key and its password off this laptop
- [x] Wire local, staging, production and fakes · `lib/core/env.dart`
- [x] Keep the runtime host override debug-only · `kDebugMode`
- [x] Show the installed version, mode, environment, host and licenses · `Settings → About`
- [x] Set app label, adaptive icon and Android 12 splash · `pubspec.yaml` and native resources
- [x] Declare release internet permission · `android/app/src/main/AndroidManifest.xml`
- [x] Pass analysis, formatting, tests and the architecture check · `16 tests`, `tool/check_layers.sh`
- [x] Verify the signed APK certificate and compare debug and release sizes · `keytool`, `NOTES.md`
- [x] Archive the obfuscated ARM64 APK and matching symbols and build the AAB · `releases/1.0.1+2/`
- [ ] Install from the file on a real phone and test mobile data, airplane mode, camera denial, rotation and About · `screenshot_about_release.png`
- [ ] Publish GitHub Release `v1.0.1` with the ARM64 APK and verify a classmate can install it · `screenshot_release_page.png`

```sh
flutter analyze
dart format --output=none --set-exit-if-changed .
flutter test
bash tool/check_layers.sh
```
