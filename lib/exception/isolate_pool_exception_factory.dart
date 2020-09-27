import 'isolate_pool_exception.dart';
import 'error_format.dart';

class IsolatePoolExceptionFactory {
  List<IsolatePoolExceptionBuilder> builderList = <IsolatePoolExceptionBuilder>[];
  final IsolatePoolExceptionBuilder defaultBuilder = DefaultIsolatePoolExceptionBuilder();

  void addBuilder(IsolatePoolExceptionBuilder builder) {
    builderList.add(builder);
  }

  void removeBuilder(IsolatePoolExceptionBuilder builder) {
    builderList.remove(builder);
  }

  IsolatePoolException build(Exception anyException, dynamic stack) {
    for (final IsolatePoolExceptionBuilder builder in builderList) {
      final aException = builder.build(anyException, stack);
      if (null != aException) {
        return aException;
      }
    }

    if (anyException is IsolatePoolException) {
      return anyException;
    }
    return defaultBuilder.build(anyException, stack);
  }
}

abstract class IsolatePoolExceptionBuilder {
  IsolatePoolException build(Exception anyException, dynamic stack);
}

class DefaultIsolatePoolExceptionBuilder implements IsolatePoolExceptionBuilder {
  @override
  IsolatePoolException build(err, stack) {
    if (null == err) {}
    final errorStack = StackFormat(stack).toJson();
    return IsolatePoolException(errorStack, exceptionType: err.runtimeType);
  }
}
