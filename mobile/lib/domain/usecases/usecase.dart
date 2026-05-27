import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';

/// Base usecase interface
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// No params class for usecases that don't require parameters
class NoParams {
  const NoParams();
}
