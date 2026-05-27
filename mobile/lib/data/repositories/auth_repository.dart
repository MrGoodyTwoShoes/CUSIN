import 'package:dartz/dartz.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_ds.dart';
import '../datasources/remote/auth_remote_ds.dart';
import '../models/user_model.dart';

/// Auth repository implementation
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
  
  @override
  Future<Either<Failure, User>> register(String phone) async {
    try {
      final userModel = await remoteDataSource.register(phone);
      
      // Store tokens (if returned)
      // await localDataSource.storeAccessToken(userModel.accessToken);
      // await localDataSource.storeUserId(userModel.id);
      
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, User>> login(String phone) async {
    try {
      final userModel = await remoteDataSource.login(phone);
      
      // Store tokens
      // await localDataSource.storeAccessToken(userModel.accessToken);
      // await localDataSource.storeUserId(userModel.id);
      
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, User>> verifyPhone(String phone, String code) async {
    try {
      final userModel = await remoteDataSource.verifyPhone(phone, code);
      
      // Store tokens
      // await localDataSource.storeAccessToken(userModel.accessToken);
      // await localDataSource.storeUserId(userModel.id);
      
      return Right(userModel.toEntity());
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, e.errors));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // Check if user is logged in
      final isLoggedIn = await localDataSource.isLoggedIn();
      if (!isLoggedIn) {
        return const Left(AuthFailure('User not logged in'));
      }
      
      final userModel = await remoteDataSource.getCurrentUser();
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearAuthData();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final loggedIn = await localDataSource.isLoggedIn();
      return Right(loggedIn);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, String>> getAccessToken() async {
    try {
      final token = await localDataSource.getAccessToken();
      if (token == null) {
        return const Left(AuthFailure('No access token found'));
      }
      return Right(token);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
