import 'package:dio/dio.dart';

import 'isolate_pool_exception.dart';
import 'isolate_pool_exception_factory.dart';

class DioExceptionBuilder implements IsolatePoolExceptionBuilder {
  @override
  IsolatePoolException build(anyException, stack) {
    if (anyException is DioError) {
      if (anyException.error is IsolatePoolException) {
        return anyException.error as IsolatePoolException;
      }
    }
    return null;
  }
}
