# Practice 13 — Where Things Go

A Flutter users app refactored from Practice 12. Screens observe models, models use repository contracts, and the HTTP repository delegates requests to the API client. The existing sign-in flow, theme, city filter, user creation, profile and offline cache are carried forward.

## Run

```sh
flutter pub get
flutter run -d chrome
```

Sign in with an email and a password of at least eight characters. The sign-in flow uses the local demo authentication from Practice 12.

For a demo without HTTP requests, uncomment the fake import in `lib/main.dart` and switch the `repo` assignment to `FakeUserRepository()`. Sign in to see two users. The city filter remains in Settings.

## Read the project

- `lib/main.dart` wires `ApiClient`, `HttpUserRepository`, `UsersModel`, and the other providers.
- `lib/features/users/` contains the users feature. Its widgets live in `widgets/`.
- `test/features/users/` covers parsing, model states, the HTTP boundary, the offline screen and inherited behavior.
- `NOTES.md` records the numeric latitude failure and its stack trace.
- `git log --oneline` shows the Practice 12 baseline and the individual moves and changes that followed.

`grep -rn ' = HttpUserRepository(' lib/` finds the production instantiation in `main.dart`. Searching for the bare identifier plus parenthesis also finds its constructor declaration.

## Quality checks

The following are the final output lines from the local checks. The Flutter commands used `--no-pub` after dependency resolution, and the tests used the expanded reporter.

```text
$ flutter analyze --no-pub
No issues found! (ran in 3.6s)

$ dart format .
Formatted 39 files (0 changed) in 1.06 seconds.

$ flutter test --no-pub --reporter expanded
00:03 +14: All tests passed!

$ bash tool/check_layers.sh
```

The layer script exited with code 0 and produced no output.
