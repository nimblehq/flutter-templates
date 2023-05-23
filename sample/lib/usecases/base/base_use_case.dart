part 'use_case_result.dart';

abstract class BaseUseCase<T extends Result> {
  const BaseUseCase();
}

abstract class UseCase<T, P> extends BaseUseCase<Result<T>> {
  const UseCase() : super();

  Future<Result<T>> call(P params);
}

abstract class NoParamsUseCase<T> extends BaseUseCase<Result<T>> {
  const NoParamsUseCase() : super();

  Future<Result<T>> call();
}
