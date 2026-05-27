import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/verify_phone_usecase.dart';

/// Auth state
class AuthState {
  final User? user;
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;
  
  AuthState({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
  });
  
  AuthState copyWith({
    User? user,
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
    );
  }
}

/// Auth provider
class AuthProvider extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final VerifyPhoneUseCase verifyPhoneUseCase;
  
  AuthProvider({
    required this.loginUseCase,
    required this.verifyPhoneUseCase,
  }) : super(AuthState());
  
  /// Login with phone number
  Future<void> login(String phone) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await loginUseCase(LoginParams(phone: phone));
    
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: _mapFailureToMessage(failure),
        );
      },
      (user) {
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
      },
    );
  }
  
  /// Verify phone with OTP
  Future<void> verifyPhone(String phone, String code) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await verifyPhoneUseCase(
      VerifyPhoneParams(phone: phone, code: code),
    );
    
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: _mapFailureToMessage(failure),
        );
      },
      (user) {
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
      },
    );
  }
  
  /// Logout
  void logout() {
    state = AuthState();
  }
  
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error. Please try again.';
      case NetworkFailure:
        return 'No internet connection. Please check your network.';
      case AuthFailure:
        return failure.message;
      case ValidationFailure:
        return failure.message;
      default:
        return 'An unexpected error occurred.';
    }
  }
}
