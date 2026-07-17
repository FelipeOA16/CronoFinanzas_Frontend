import '../../../../core/errors/result.dart';
import '../entities/auth_tokens.dart';
import '../entities/sesion_activa.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Result<User>> register({
    required String email,
    required String password,
    String? nombre,
    String? apellido,
    String? nombreMostrar,
  });

  Future<Result<AuthTokens>> login({
    required String email,
    required String password,
  });

  Future<Result<User>> getMe();

  Future<Result<AuthTokens>> refreshToken(String refreshToken);

  Future<Result<void>> logout(String refreshToken);

  Future<Result<void>> forgotPassword(String email);

  Future<Result<void>> resetPassword(String token, String newPassword);

  Future<Result<void>> verifyEmail(String token);

  Future<Result<void>> resendVerification();

  Future<Result<List<SesionActiva>>> listSessions(int idUsuario);

  Future<Result<void>> revokeSession(int idUsuario, String sessionUuid);

  Future<Result<void>> revokeAllSessions(int idUsuario);
}
