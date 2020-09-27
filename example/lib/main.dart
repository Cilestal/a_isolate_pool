import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:isolate_pool/exception/isolate_pool_exception.dart';
import 'package:isolate_pool/exception/isolate_pool_exception_factory.dart';
import 'package:isolate_pool/pool/thread_pool.dart';
import 'package:isolate_pool/pool/types.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThreadPool Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Thread Pool Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    ThreadPool.logger = (level, tag, message) {
      print("level:$level $tag $message");
    };

    _runDemo();

    super.initState();
  }

  void _runDemo() async {
    //Run testIsolateRun in the isolated thread pool
    ThreadPool.io.run(fun1: testThreadRun, arg1: "params for testThreadRun");
    ThreadPool.addExceptionBuilder(MyExceptionBuilder());
    //Run testIsolateRun in the isolated thread pool with custom params
    final response = await ThreadPool.io
        .run(fun2: testStaticThreadRun, arg1: "Test", arg2: 123)
        .catchError((error) {
      //catch exception from isolate thread
    });
    print(response);

    //catch IsolatePoolException from isolate thread
    await ThreadPool.io
        .run(fun1: testExceptionStaticThreadRun, arg1: "exception test")
        .catchError((err) {
      print("exception from thread:${err.runtimeType}, $err");
    });

    //catch any exception from isolate thread
    await ThreadPool.io
        .delay(Duration(seconds: 3),
            fun1: testLambdaExceptionStaticThreadRun, arg1: "exception test")
        .catchError((err) {
      print("exception from thread:${err.runtimeType}, $err");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              child: Text("Click Run Isolate Thread Pool Demo"),
              onPressed: () {
                _runDemo();
              },
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  //define a static function
  static _AnyResponse testStaticThreadRun(String param1, int param2) {
    ThreadPool.logger(LOG_LEVEL.INFO, "testIsolateRun",
        "working on thread ${Isolate.current}, param:$param1, $param2");
    return _AnyResponse(
        false,
        100,
        300.0,
        "stringResponse",
        {"kev1Response": 0, "key2Response": "any type"},
        ["Response:fasfa", 2000]);
  }

  static _AnyResponse testExceptionStaticThreadRun(Object any) {
    ThreadPool.logger(LOG_LEVEL.INFO, "testExceptionStaticThreadRun",
        "working on thread ${Isolate.current}, param:$any");
    throw MyException("my excption from isolate, param:$any");
  }

  static _AnyResponse testLambdaExceptionStaticThreadRun(Object any) {
    ThreadPool.logger(LOG_LEVEL.INFO, "testLambdaExceptionStaticThreadRun",
        "working on thread ${Isolate.current}, param:$any");
    throw MyLambdaException("my lambda excption from isolate, param:$any");
  }
}

//define a top-level function
bool testThreadRun(Object any) {
  ThreadPool.logger(LOG_LEVEL.INFO, "testIsolateRun",
      "working on thread ${Isolate.current.toString()}, param:$any");
  return true;
}

class _AnyResponse {
  final bool boolParam;
  final int intParam;
  final double doubleParam;
  final String stringParam;
  final Map<String, dynamic> mapParam;
  final List<dynamic> listParam;

  _AnyResponse(this.boolParam, this.intParam, this.doubleParam,
      this.stringParam, this.mapParam, this.listParam);

  @override
  String toString() {
    return "response from thread, bool:$boolParam, int:$intParam, double:$doubleParam, string:$stringParam, map:$mapParam, list:$listParam";
  }
}

class MyException extends IsolatePoolException {
  MyException(String error) : super(error);
}

class MyLambdaException {
  MyLambdaException(String error);
}

class MyExceptionBuilder extends DefaultIsolatePoolExceptionBuilder {
  @override
  IsolatePoolException build(anyException, stack) {
    return super.build(anyException, stack);
  }
}
