import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/user.dart';

/// Auth repository interface
abstract class AuthRepository {
  Future<Either<Failure, User>> register(String phone);
  Future<Either<Failure, User>> login(String phone);
  Future<Either<Failure, User>> verifyPhone(String phone, String code);
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, bool>> isLoggedIn();
  Future<Either<Failure, String>> getAccessToken();
}
