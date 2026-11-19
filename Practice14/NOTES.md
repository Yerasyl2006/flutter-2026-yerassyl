# Practice 14 release notes

## Android tooling

The previous installation of Flutter 3.29 sets `flutter.minSdkVersion` to 21. Flutter 3.35.7 sets it to 24, which supports the inherited secure-storage package and lets Gradle use Flutter's value as required. Gradle 8.13 matches the Android Gradle Plugin used by that package.

## Version

In `1.0.0+1`, `1.0.0` is the version people read. Android receives it as `versionName`. The integer `1` is the build number Android receives as `versionCode`. Google Play uses it to order uploads. Increase it on every upload. This release is `1.0.1+2`. Gradle gets both values from Flutter, and `package_info_plus` reads the installed package values. Reinstall or rebuild the native app after changing the version.

Flutter 3.35.7 adds ABI-specific offsets to split APK version codes. ARM64 uses `2002`, ARMv7 uses `1002`, and x86-64 uses `4002`. The standalone ARM64 installer is built with `--target-platform android-arm64` so its installed package reports `1.0.1 (2)` in About. The split build has its own set of symbols.

## Signing

The Android upload key uses alias `upload`. `android/key.properties` contains the local keystore path and credentials. The keystore is stored outside the project. Off-device backup is pending. Save the keystore and credentials in private storage the owner can recover.

`keytool -printcert -jarfile` reported the following certificate on the ARM64 installer. `apksigner verify` validated its APK signature, and `jarsigner -verify` validated the AAB.

```text
Owner: CN=Yerassyl, OU=Mobile Development, O=Practice 14, C=KZ
SHA256: AE:F6:03:C5:15:7A:D9:EC:74:1E:14:60:90:2A:D3:B3:0F:15:D4:CF:94:CF:CB:0D:0E:A8:7E:BB:E7:51:26:42
Signature algorithm name: SHA256withRSA
```

Someone with the same APK signing key and application ID can sign a modified APK that Android accepts as an update, subject to version and platform checks. With Play App Signing, Google holds the app signing key and signs the APKs delivered through Play. A stolen upload key can be reset and cannot itself sign an update accepted by a Play-installed app when Google uses a separate signing key.

For an actual leak, rotate or reset the affected key and coordinate history rewriting with collaborators. In a dedicated mirror clone, the history rewrite and remote update take this form. Use all exact paths ever used for the secret.

```sh
git filter-repo --sensitive-data-removal --invert-paths --path android/key.properties --path upload-keystore.jks
git push --force --mirror <remote-url>
```

## Environments

`String.fromEnvironment` is evaluated from the Dart build configuration. Changing it needs a new build. The developer tile uses `SharedPreferencesAsync` for a runtime override. Debug watches that setting and reloads the users feature when the host changes. A release uses its compiled host, keeping the endpoint for production users fixed. User data is cached by API host so a staging failure cannot display the production list. The inherited cache remains accessible for the default host.

## Crash reports

An obfuscated report typically contains addresses and short names such as `a.b`. Keep the exact build's symbols for each architecture. Run the symbolizer with the ARM64 file and the stack trace from that build.

```sh
flutter symbolize -i stack_trace.txt -d releases/1.0.1+2/symbols/app.android-arm64.symbols
```

## Build sizes

| Artifact | Bytes | MiB |
| --- | ---: | ---: |
| Debug APK from `flutter build apk --debug` | 149,727,486 | 142.8 |
| ARM64 split release APK | 17,278,517 | 16.5 |
| ARM64 installer with build number 2 | 17,278,529 | 16.5 |
| Android App Bundle | 43,005,287 | 41.0 |

## Emulator verification

The standalone ARM64 installer ran on the Android 15 emulator with ARM translation. Its first launch loaded the users through the emulated mobile network with Wi‑Fi off. About displayed `1.0.1 (2)`, `release`, `prod` and `jsonplaceholder.typicode.com`. The developer host tile was absent. The About screen remained readable after rotation to landscape. A cold launch in airplane mode displayed the cached users and the offline banner. Denying camera permission left the Profile screen open. The local archive contains `screenshot_about_emulator.png`.

The debug build reported `1.0.1 (2)` and `local`. Changing the host to `example.invalid` produced the Offline view. The setting survived a full restart.

The `USE_FAKES=true` build displayed Leanne Graham and Ervin Howell in airplane mode.
