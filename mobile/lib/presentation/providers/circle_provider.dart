import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Circle state
class CircleState {
  final bool isLoading;
  final String? error;
  
  CircleState({
    this.isLoading = false,
    this.error,
  });
  
  CircleState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return CircleState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Circle provider
class CircleProvider extends StateNotifier<CircleState> {
  CircleProvider() : super(CircleState());
  
  // TODO: Implement circle operations when use cases are ready
  
  void clearError() {
    state = state.copyWith(error: null);
  }
}
