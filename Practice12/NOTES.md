# Practice 12 — Survive a Restart

Package review: latest releases shown by pub.dev on 11 November 2026; the versions used by the app may be older to support its SDK.

- [shared_preferences](https://pub.dev/packages/shared_preferences): verified flutter.dev; October 2026; Android, iOS, Linux, macOS, web and Windows; 160 points; open issues are tracked in Flutter's active monorepo; depends on Flutter, platform implementations and their interface; BSD-3-Clause.
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage): verified steenbakker.dev; September 2026; Android, iOS, Linux, macOS, web and Windows; 160 points; 11 open GitHub issues and ongoing releases/commits; depends on Flutter and secure storage platform implementations/interfaces; BSD-3-Clause.
- [path_provider](https://pub.dev/packages/path_provider): verified flutter.dev; July 2026; Android, iOS, Linux, macOS and Windows; 160 points; open issues are tracked in Flutter's active monorepo; depends on Flutter, platform implementations and their interface; BSD-3-Clause.
- [image_picker](https://pub.dev/packages/image_picker): verified flutter.dev; October 2026; Android, iOS, Linux, macOS, web and Windows; 160 points; open issues are tracked in Flutter's active monorepo; depends on Flutter and picker platform implementations/interfaces; Apache-2.0 and BSD-3-Clause.
- [permission_handler](https://pub.dev/packages/permission_handler): verified baseflow.com; September 2026; Android, iOS, web and Windows; 160 points; 130 open GitHub issues, with ongoing releases/commits; depends on Flutter, permission platform implementations and their interface; MIT.
- [url_launcher](https://pub.dev/packages/url_launcher): verified flutter.dev; October 2026; Android, iOS, Linux, macOS, web and Windows; 160 points; open issues are tracked in Flutter's active monorepo; depends on Flutter, launcher platform implementations and their interface; BSD-3-Clause.

Each pub.dev page links to its example and issue tracker. The Flutter packages share the [Flutter packages repository](https://github.com/flutter/packages); compare the open issues with the history of the relevant package directory.

## Versions and storage

- The app resolves `http 1.6.0`. The six constraints added by Pub were `shared_preferences ^2.5.3`, `flutter_secure_storage ^10.3.4`, `path_provider ^2.1.5`, `image_picker ^1.2.1`, `permission_handler ^13.0.2` and `url_launcher ^6.3.2`. Android SDK 36 cannot build the Android implementation of permission_handler 13, which requires SDK 37, so the final constraint is `permission_handler ^12.0.1` (resolved 12.0.3).
- `flutter pub outdated` showed `shared_preferences` 2.5.3 as the newest resolvable release for this project; the latest 2.5.6 requires Dart 3.11, while this machine runs Dart 3.7.
- The pin experiment in a copy of the Practice 11 dependencies selected exactly `http 1.2.0` and downgraded `web` to 0.4.2. The same pin in Practice 12 fails dependency resolution: `http 1.2.0` needs `web <0.5.0`, while `permission_handler_html` needs `web >=0.5.1`. The working Practice 12 constraint remains `http: ^1.6.0`.

- `http: ^1.2.0` means `>=1.2.0 <2.0.0`: it admits 1.2.0, 1.2.1, and 1.6.0, and rejects 1.1.9 and 2.0.0. A literal `1.2.0` admits only 1.2.0. Keep `^1.6.0` in this app because its API client uses AbortableRequest.
- Commit `pubspec.lock` for an app so teammates and CI use the same exact direct and transitive versions.
- Legacy preferences can put strings in plaintext Android SharedPreferences XML or iOS UserDefaults plist; Async uses Preferences DataStore by default on Android. None is a secret store: a privileged device user, a readable backup, or someone with authorized debug/device access may extract it. A cable alone doesn't bypass the sandbox.
- iOS Keychain entries can survive uninstall and may be seen after reinstall with the same app identity and access group. Android Keystore keys tied to user authentication can become invalid when the secure lock screen is removed; that can make previously encrypted data inaccessible. The login in this practice is a local demonstration, not server authentication.
- The users cache and avatar are in app Documents. Clearing the system cache removes temporary files, so Temporary would not meet this requirement.

## Camera and links

- On recent Android versions, deny Camera twice; the next tap normally opens the app's own dialog, which links to the OS app settings.
- On iOS, deny Camera once: iOS will not show the camera permission prompt again; enable Camera in Settings. Photos may be **limited** (only user-selected photos); this is distinct from restricted access.
- A website URI needs the `https` scheme. A bare domain is a relative URI and is not handed to the browser. A missing phone or email handler is handled in the UI.



Chrome demo: the browser stores cached users and the avatar in site data for its origin, while Android and iOS use Documents. Use Android or iOS for the OS camera permission demonstration.
