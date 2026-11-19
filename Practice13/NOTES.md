# Practice 13 notes

## Constructor injection

A model that creates its own repository cannot accept the arrange line `final model = UsersModel(FakeUserRepository(fail: true));`. In the local Practice 12 starter, the constructor accepted only the concrete repository type; it now accepts any implementation of the interface.

## Extracted widgets

A const widget can reuse its instance, gives Flutter a separate element to rebuild, and appears by name in DevTools.
A widget can be pumped directly in a test with explicit inputs.

## Numeric latitude trace

I replayed an HTTP 200 response containing user 1 (Leanne Graham) with `address.geo.lat` changed from the JSON string `"-37.3159"` to the number `-37.3159`. In the trace probe I temporarily removed the existing `TypeError` handlers in the repository and model so the failure reached the test runner. The handlers were restored afterward. Frame locations refer to that run.

```text
type 'double' is not a subtype of type 'String' in type cast
#0      new Geo.fromJson (package:users_api/features/users/geo.dart:5:35)
#1      new Address.fromJson (package:users_api/features/users/address.dart:17:14)
#2      new User.fromJson (package:users_api/features/users/user.dart:28:24)
#3      HttpUserRepository._user (package:users_api/features/users/user_repository.dart:66:19)
#4      HttpUserRepository._fetch (package:users_api/features/users/user_repository.dart:44:9)
<asynchronous suspension>
#5      HttpUserRepository.getAll (package:users_api/features/users/user_repository.dart:26:21)
<asynchronous suspension>
#6      UsersModel.load (package:users_api/features/users/users_model.dart:32:22)
<asynchronous suspension>
#7      main.<anonymous closure> (test/features/users/user_repository_test.dart:22:7)
<asynchronous suspension>
#8      Declarer.test.<anonymous closure>.<anonymous closure> (package:test_api/src/backend/declarer.dart:229:9)
<asynchronous suspension>
#9      Declarer.test.<anonymous closure> (package:test_api/src/backend/declarer.dart:227:7)
<asynchronous suspension>
#10     Invoker._waitForOutstandingCallbacks.<anonymous closure> (package:test_api/src/backend/invoker.dart:258:9)
<asynchronous suspension>
```

1. **Message.** The cast received a Dart `double` where the JSON contract requires a `String`.
2. **First application frame.** `Geo.fromJson`, line 5, column 35, points to the `as String` cast.
3. **Call path.** `UsersModel.load` awaited `getAll`, which awaited `_fetch`. The repository then called `User.fromJson` → `Address.fromJson` → `Geo.fromJson`. The asynchronous suspension markers indicate the await boundaries.

Frame #0 is where the decoder enforces the JSON contract. The HTTP repository has the response and item path, so it translates that violation into `BadResponseException('/users[0]: lat is not a String')`; the screen shows its generic server-response message.

Practice 12 already used feature-first folders and included four tests. The history starts from that snapshot and records the remaining moves and additions.
