import 'dart:isolate';

import 'package:a_thread_pool/a_thread_pool.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('test io thread', () async {
    ThreadPool.logger = testLogger;
    expect(
        await ThreadPool.io.run(
          fun1: testIsolateRunParam1,
          arg1: "params for testIsolateRun",
        ),
        true);
    expect(
        await ThreadPool.io.run(
          fun4: testIsolateRunParam4,
          arg1: true,
          arg2: 200,
          arg3: 200.0,
          arg4: "stringParam",
        ),
        true);
    //expect(() => IsolatePool.io.addOne(null), throwsNoSuchMethodError);
  });
}

bool testIsolateRunParam1(String param1) {
  ThreadPool.logger(LOG_LEVEL.INFO, "testIsolateRun",
      "working on thread ${Isolate.current.toString()}");
  return true;
}

bool testIsolateRunParam4(
    bool param1, int param2, double param3, String param4) {
  ThreadPool.logger(LOG_LEVEL.INFO, "testIsolateRun",
      "working on thread ${Isolate.current.toString()}");
  return true;
}

Future<void> testLogger(LOG_LEVEL level, String tag, String message) async {
  print("testLogger $level $tag $message");
}
