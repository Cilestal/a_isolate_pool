import 'a_exception.dart';
import 'error_format.dart';

class AExceptionFactory {
  List<AExceptionBuilder> builderList = <AExceptionBuilder>[];
  final AExceptionBuilder defaultBuilder = DefaultAExceptionBuilder();

  void addBuilder(AExceptionBuilder builder) {
    builderList.add(builder);
  }

  void removeBuilder(AExceptionBuilder builder) {
    builderList.remove(builder);
  }

  /// 将anyException转化为可传递的AException
  /// 如果您从AException派生了异常类，请确保你的异常实现类中不要包含Lambda表达式函数或其它block函数
  AException build(Exception anyException, dynamic stack) {
    for (final AExceptionBuilder builder in builderList) {
      final aException = builder.build(anyException, stack);
      if (null != aException) {
        return aException;
      }
    }

    if (anyException is AException) {
      return anyException;
    }
    return defaultBuilder.build(anyException, stack);
  }
}

abstract class AExceptionBuilder {
  AException build(Exception anyException, dynamic stack);
}

class DefaultAExceptionBuilder implements AExceptionBuilder {
  @override
  AException build(err, stack) {
    if (null == err) {}
    final errorStack = StackFormat(stack).toJson();
    return AException(errorStack, exceptionType: err.runtimeType);
  }
}
