# Practice 11 — A Real Server

Flutter-приложение для Android загружает пользователей JSONPlaceholder, показывает карточки и отправляет новый объект через форму. В [NOTES.md](NOTES.md) описаны ответы сервера, модель и обработка ошибок.

## Запуск

```sh
flutter pub get
flutter run
```

Дополнительная проверка до показа экрана выводит результат разбора пользователя № 1, имена из GET, исключение для ID 999 и назначенный сервером ID после POST.

```sh
flutter run --dart-define=API_SMOKE_TEST=true
```

## Проверки

```sh
dart format .
flutter analyze
flutter test
rg -n 'package:http' lib
```

Чтобы проверить экран ошибки на неверном имени хоста, запустите `flutter run --dart-define=API_HOST=jsonplaceholder.typicode.co`. Для возврата к рабочему хосту перезапустите приложение без этого параметра. В сетевой проверке с рабочим хостом достаточно восстановить соединение и нажать Retry.

## Файлы

- `lib/core/api/` — HTTP, таймаут и исключения.
- `lib/features/users/` — модели данных, репозиторий, состояние и экраны.
- `lib/main.dart` — сборка зависимостей и запуск приложения.
