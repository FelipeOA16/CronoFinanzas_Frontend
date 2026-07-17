import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/storage/token_storage.dart';
import '../../../domain/usecases/get_me.dart';
import '../../../domain/usecases/login.dart';
import '../../../domain/usecases/logout.dart';
import '../../../domain/usecases/register.dart';
import 'auth_state.dart';

class AuthController extends StateNotifier<AuthState> {
  final Login _login;
  final Register _register;
  final GetMe _getMe;
  final Logout _logout;
  final TokenStorage _tokenStorage;

  AuthController({
    required Login login,
    required Register register,
    required GetMe getMe,
    required Logout logout,
    required TokenStorage tokenStorage,
  }) : _login = login,
       _register = register,
       _getMe = getMe,
       _logout = logout,
       _tokenStorage = tokenStorage,
       super(const AuthIdle());

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      final loginResult = await _login(email: email, password: password);
      if (loginResult.isFail) {
        state = AuthError(loginResult.failure.message);
        return;
      }
      final tokens = loginResult.data;
      await _tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      final userResult = await _getMe();
      if (userResult.isFail) {
        await _tokenStorage.clear();
        state = AuthError(userResult.failure.message);
        return;
      }
      state = AuthAuthenticated(userResult.data);
    } catch (e) {
      state = AuthError('Error inesperado: $e');
    }
  }

  Future<void> registerUser({
    required String email,
    required String password,
    String? nombre,
    String? apellido,
    String? nombreMostrar,
  }) async {
    state = const AuthLoading();
    try {
      final result = await _register(
        email: email,
        password: password,
        nombre: nombre,
        apellido: apellido,
        nombreMostrar: nombreMostrar,
      );
      if (result.isFail) {
        state = AuthError(result.failure.message);
        return;
      }
      // Auto-login after register
      await loginUser(email: email, password: password);
    } catch (e) {
      state = AuthError('Error inesperado: $e');
    }
  }

  Future<void> loadSession() async {
    final accessToken = await _tokenStorage.getAccessToken();
    if (accessToken == null) {
      state = const AuthIdle();
      return;
    }
    state = const AuthLoading();
    final userResult = await _getMe();
    if (userResult.isFail) {
      await _tokenStorage.clear();
      state = const AuthIdle();
      return;
    }
    state = AuthAuthenticated(userResult.data);
  }

  Future<void> logoutUser() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken != null) {
      await _logout(refreshToken);
    }
    await _tokenStorage.clear();
    state = const AuthIdle();
  }

  void updateUser(covariant dynamic user) {
    if (state is AuthAuthenticated) {
      state = AuthAuthenticated(user);
    }
  }
}
