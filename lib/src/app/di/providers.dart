import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/config/endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/interceptors.dart';
import '../../../core/storage/secure_token_storage.dart';
import '../../../core/storage/token_storage.dart';

// Storage
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return SecureTokenStorage(ref.watch(secureStorageProvider));
});

// Signal emitted when the auth interceptor fails to refresh a token.
// Listeners can react by calling loadSession() to redirect to login.
final unauthSignalProvider = StateProvider<int>((ref) => 0);

// Signal emitted after a successful token refresh.
// Native integrations can resync their in-memory session snapshot.
final tokenRefreshSignalProvider = StateProvider<int>((ref) => 0);

// Network
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

final dioProvider = Provider<Dio>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);

  // Add auth interceptor — fires unauthSignalProvider when refresh fails
  dioClient.addInterceptor(
    AuthInterceptor(
      tokenStorage,
      dioClient.dio,
      onUnauthenticated: () => ref.read(unauthSignalProvider.notifier).state++,
      onTokenRefreshed: (_) =>
          ref.read(tokenRefreshSignalProvider.notifier).state++,
    ),
  );

  return dioClient.dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});

/// Patrimonio total del usuario (suma de saldos de cuentas activas).
/// Se usa en HomeScreen para mostrar el balance general sin duplicar datasources.
final patrimonioProvider = FutureProvider.autoDispose<double>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final dio = ref.watch(dioProvider);
  final data = await apiClient.handleRequest(
    () => dio.get(Endpoints.cuentasResumen),
  );
  final map = data as Map<String, dynamic>;
  final v = map['total_patrimonio'];
  if (v is double) return v;
  if (v is int) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
});
