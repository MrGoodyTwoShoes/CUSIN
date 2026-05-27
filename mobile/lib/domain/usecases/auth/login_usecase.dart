import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../usecase.dart';

/// Login usecase
class LoginUseCase implements UseCase<User, LoginParams> {
  final AuthRepository repository;
  
  LoginUseCase(this.repository);
  
  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    return await repository.login(params.phone);
  }
}

class LoginParams {
  final String phone;
  
  LoginParams({required this.phone});
}
