import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../usecase.dart';

/// Verify phone usecase
class VerifyPhoneUseCase implements UseCase<User, VerifyPhoneParams> {
  final AuthRepository repository;
  
  VerifyPhoneUseCase(this.repository);
  
  @override
  Future<Either<Failure, User>> call(VerifyPhoneParams params) async {
    return await repository.verifyPhone(params.phone, params.code);
  }
}

class VerifyPhoneParams {
  final String phone;
  final String code;
  
  VerifyPhoneParams({
    required this.phone,
    required this.code,
  });
}
