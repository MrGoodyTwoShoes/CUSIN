import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/local/local_datasource.dart';
import '../data/datasources/remote/remote_datasource.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/incident_repository.dart';
import '../domain/usecases/auth/login_usecase.dart';
import '../domain/usecases/auth/verify_phone_usecase.dart';
import '../domain/usecases/incidents/create_incident_usecase.dart';
import '../domain/usecases/incidents/get_incidents_usecase.dart';
import 'auth_provider.dart';
import 'circle_provider.dart';
import 'incident_provider.dart';

/// Local datasource provider
final localDataSourceProvider = Provider<LocalDataSourceImpl>((ref) {
  return LocalDataSourceImpl();
});

/// Remote datasource provider
final remoteDataSourceProvider = Provider<RemoteDataSourceImpl>((ref) {
  return RemoteDataSourceImpl(ref.read(dioClientProvider));
});

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.read(remoteDataSourceProvider),
    localDataSource: ref.read(localDataSourceProvider),
  );
});

/// Incident repository provider
final incidentRepositoryProvider = Provider<IncidentRepositoryImpl>((ref) {
  return IncidentRepositoryImpl(
    remoteDataSource: ref.read(remoteDataSourceProvider),
    localDataSource: ref.read(localDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

/// Login usecase provider
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

/// Verify phone usecase provider
final verifyPhoneUseCaseProvider = Provider<VerifyPhoneUseCase>((ref) {
  return VerifyPhoneUseCase(ref.read(authRepositoryProvider));
});

/// Get incidents usecase provider
final getIncidentsUseCaseProvider = Provider<GetIncidentsUseCase>((ref) {
  return GetIncidentsUseCase(ref.read(incidentRepositoryProvider));
});

/// Create incident usecase provider
final createIncidentUseCaseProvider = Provider<CreateIncidentUseCase>((ref) {
  return CreateIncidentUseCase(ref.read(incidentRepositoryProvider));
});

/// Auth provider
final authProvider = StateNotifierProvider<AuthProvider, AuthState>((ref) {
  return AuthProvider(
    loginUseCase: ref.read(loginUseCaseProvider),
    verifyPhoneUseCase: ref.read(verifyPhoneUseCaseProvider),
  );
});

/// Incident provider
final incidentProvider = StateNotifierProvider<IncidentProvider, IncidentState>((ref) {
  return IncidentProvider(
    getIncidentsUseCase: ref.read(getIncidentsUseCaseProvider),
    createIncidentUseCase: ref.read(createIncidentUseCaseProvider),
  );
});

/// Circle provider
final circleProvider = StateNotifierProvider<CircleProvider, CircleState>((ref) {
  return CircleProvider();
});
