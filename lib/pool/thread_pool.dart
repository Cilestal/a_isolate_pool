//Copyright (C) 2020 adeveloper.tech
//
//Permission is hereby granted, free of charge, to any person obtaining
//a copy of this software and associated documentation files (the
//"Software"), to deal in the Software without restriction, including
//without limitation the rights to use, copy, modify, merge, publish,
//    distribute, sublicense, and/or sell copies of the Software, and to
//permit persons to whom the Software is furnished to do so, subject to
//the following conditions:
//
//The above copyright notice and this permission notice shall be
//included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import 'dart:io';
import 'dart:math';

import '../exception/isolate_pool_exception_factory.dart';
import '../exception/dio_exception_builder.dart';
import 'runnable.dart';
import 'thread_service.dart';
import 'types.dart';

class ThreadPool {
  static final ThreadPool io = ThreadPool.build(
      max(3, (Platform.numberOfProcessors * 0.6).floor()), "io_thread_pool");

  final String _tag;
  final int _threadCount;
  final Map<int, ThreadService> _threadMap = <int, ThreadService>{};
  int _lastRunIndex = -1;

  static final IsolatePoolExceptionFactory _exceptionFactory = IsolatePoolExceptionFactory();

  static set logger(AThreadLogger logger) {
    ThreadService.logger = logger;
  }

  static AThreadLogger get logger {
    return ThreadService.logger;
  }

  static void addExceptionBuilder(IsolatePoolExceptionBuilder builder) {
    _exceptionFactory.addBuilder(builder);
  }

  static void removeExceptionBuilder(IsolatePoolExceptionBuilder builder) {
    _exceptionFactory.removeBuilder(builder);
  }

  ThreadPool.build(int threadCount, [String tag])
      : _threadCount = threadCount ?? 1,
        _tag = tag ?? _randomTag() {
    _exceptionFactory.addBuilder(DioExceptionBuilder());
  }

  Future<O> run<A, B, C, D, O>({
    A arg1,
    B arg2,
    C arg3,
    D arg4,
    Fun0<O> fun0,
    Fun1<A, O> fun1,
    Fun2<A, B, O> fun2,
    Fun3<A, B, C, O> fun3,
    Fun4<A, B, C, D, O> fun4,
    String debugLabel,
  }) async {
    return delay(null,
        arg1: arg1,
        arg2: arg2,
        arg3: arg3,
        arg4: arg4,
        fun0: fun0,
        fun1: fun1,
        fun2: fun2,
        fun3: fun3,
        fun4: fun4);
  }

  Future<O> delay<A, B, C, D, O>(Duration duration,
      {A arg1,
      B arg2,
      C arg3,
      D arg4,
      Fun0<O> fun0,
      Fun1<A, O> fun1,
      Fun2<A, B, O> fun2,
      Fun3<A, B, C, O> fun3,
      Fun4<A, B, C, D, O> fun4,
      String debugLabel}) async {
    if (_threadCount > 0) {
      return (await _getNextThread()).delay(
          duration,
          Runnable(
            arg1: arg1,
            arg2: arg2,
            arg3: arg3,
            arg4: arg4,
            fun0: fun0,
            fun1: fun1,
            fun2: fun2,
            fun3: fun3,
            fun4: fun4,
          ));
    } else {
      logger(LOG_LEVEL.ERROR, "IsolatePool", "run thread pool is empty");
    }
    return null;
  }

  void stop() {
    if (_threadMap != null) {
      _threadMap.values.forEach((ThreadService thread) {
        thread.stop();
      });
      _threadMap.clear();
    }
  }

  Future<ThreadService> _getNextThread() async {
    if (_lastRunIndex < 0) {
      _lastRunIndex = 0;
    } else {
      _lastRunIndex = (++_lastRunIndex) % _threadCount;
    }

    ThreadService thread = _threadMap[_lastRunIndex];
    if (null == thread || !thread.isRunning) {
      final tag = "${_tag}_$_lastRunIndex";
      thread = ThreadService.build(tag);
      await thread.start();
      _threadMap[_lastRunIndex] = thread;
    }
    return thread;
  }

  static String _randomTag() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
