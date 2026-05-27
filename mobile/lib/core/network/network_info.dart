import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Network information provider
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl();
});

/// Abstract network info interface
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Future<bool> get isNotConnected;
  Stream<ConnectivityResult> get onConnectivityChanged;
}

/// Network info implementation using connectivity_plus
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;
  
  NetworkInfoImpl() : _connectivity = Connectivity();
  
  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
  
  @override
  Future<bool> get isNotConnected async {
    return !(await isConnected);
  }
  
  @override
  Stream<ConnectivityResult> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged;
  }
}
