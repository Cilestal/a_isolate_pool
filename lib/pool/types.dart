import 'dart:async';

typedef AVoidRunnable = Future<void> Function();
typedef AThreadLogger = void Function(
  LOG_LEVEL level,
  String tag,
  String message,
);

enum LOG_LEVEL {
  DEBUG,
  INFO,
  WARN,
  ERROR,
}
