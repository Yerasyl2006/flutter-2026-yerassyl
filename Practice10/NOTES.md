# Practice 10 The Data Arrives Later

## Level 1 Event loop

Predicted order: A, C, the first frame, then after two seconds B and 6 students.
Observed order: A, C, first frame, B, 6 students. fetchStudents #1 is also printed by the API.
This order was checked in an isolated Flutter widget test with controlled time.

await Future.delayed lets the event loop continue, so Flutter can draw while the request waits.
Replacing the delay with sleep blocks the event loop. In the isolated sleep experiment, a scheduled event still had not run after 2002 ms of sleep. With await restored, the event loop is free to handle other work.

The API waits two seconds and fails on every third fetch. save waits one second and fails on every second save. Unhandled failures were observed in an isolated zone:

```text
Unhandled Exception: Instance of 'NoConnectionException'
Unhandled Exception: Bad state: server rejected 6
```

The zone recorded the errors so the experiment did not crash the test runner. The final app handles these errors instead.

## Level 2 Four states

The manual screen checks error, loading, empty, then data. A null GPA is shown as —.
The empty state was checked with FakeApi(empty: true), then the normal API was restored.

Without mounted guards, closing a deliberately broken test widget before the delayed callback produced:

```text
setState() called after dispose(): _BrokenDemoState#c7d80(lifecycle state: defunct, not mounted)
```

The identifier after # changes on each run. With the guards restored, closing the actual StudentsScreen during loading produces no error.

## Level 3 FutureBuilder

The Future is assigned in initState and stored in a field. Ten Switch changes made only one fetchStudents call. Retry replaces the stored Future inside a synchronous setState block. The builder checks hasError first, then connectionState, then empty or populated data.

The error, Retry recovery and empty response were checked. The temporary broken implementation is not included in the final app.

## Level 4 Countdown

With cancel restored in version B, leaving at 7 stops the console after tick 7. In the isolated broken version without cancel, the console continues:

```text
tick 6
tick 5
tick 4
tick 3
tick 2
tick 1
tick 0
```

It also reports setState() called after dispose() because the listener still updates the removed widget.
Version A stops after tick 7 too: StreamBuilder cancels its own subscription. Both final versions were removed mid-count and checked for errors after another 12 seconds of controlled test time.

## Level 5 Save

The incorrect version starts save without awaiting it and immediately pops the screen. The user saw a success. The server may reject the request later, after the screen has already closed.

The final version awaits save, catches StateError, checks context.mounted, and pops only on success. On failure it stays on the screen and shows server rejected 6 in a SnackBar. While saving, the button is disabled and shows a spinner.

## How to demonstrate the final app

The home screen owns one API for By hand and another for FutureBuilder. These objects survive returning to the menu, so their counters do not reset every time a screen opens. No additional interface controls are needed.

1. Restart the app. Open By hand, wait two seconds, then go Back.
2. Open By hand again, wait, then go Back.
3. Open it a third time. The third request shows Could not load students and Retry. Retry makes request four and shows the list.
4. Tap Save: the first save succeeds and returns to the menu.
5. Open By hand again and tap Save: the second save shows server rejected 6 and keeps the screen open.
6. Open FutureBuilder. Toggle its Switch ten times: the console request count does not change. Go Back and reopen it as above to reach its third request and error; Retry recovers.
7. Open Countdown and choose A or B. Leave during the countdown. The subscription stops in both versions.

Restarting the whole app resets all counters. Hot reload may preserve them.

## Submission files

screenshot_error.png shows the actual By hand error reached through the third request.
screenshot_countdown.png shows version B at 7.
Temporary verification and intentionally broken experiment files are excluded from the submitted project.

Final checks: dart format . completed; flutter analyze reported No issues found! with unawaited_futures enabled. The temporary unawaited save probe was correctly flagged by unawaited_futures before it was removed. Six scenario checks and three extra experiment checks passed before removing their temporary source files.
