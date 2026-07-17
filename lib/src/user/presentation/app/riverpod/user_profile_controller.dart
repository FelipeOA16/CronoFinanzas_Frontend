import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../app/di/providers.dart';
import '../../../../auth/presentation/widgets/login_form.dart'
    show authControllerProvider;
import '../../../data/datasources/user_remote_data_src.dart';
import '../../../data/repos/user_repo_impl.dart';
import '../../../domain/usecases/change_password.dart';
import '../../../domain/usecases/update_perfil.dart';
import 'user_profile_state.dart';

// ── Providers ────────────────────────────────────────────────────────────────

final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  return UserRemoteDataSource(
    ref.watch(apiClientProvider),
    ref.watch(dioProvider),
  );
});

final userRepositoryProvider = Provider((ref) {
  return UserRepositoryImpl(ref.watch(userRemoteDataSourceProvider));
});

final updatePerfilUseCaseProvider = Provider((ref) {
  return UpdatePerfil(ref.watch(userRepositoryProvider));
});

final changePasswordUseCaseProvider = Provider((ref) {
  return ChangePassword(ref.watch(userRepositoryProvider));
});

final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, UserProfileState>((ref) {
      return UserProfileController(
        updatePerfil: ref.watch(updatePerfilUseCaseProvider),
        changePassword: ref.watch(changePasswordUseCaseProvider),
        ref: ref,
      );
    });

// ── Controller ───────────────────────────────────────────────────────────────

class UserProfileController extends StateNotifier<UserProfileState> {
  final UpdatePerfil _updatePerfil;
  final ChangePassword _changePassword;
  final Ref _ref;

  UserProfileController({
    required UpdatePerfil updatePerfil,
    required ChangePassword changePassword,
    required Ref ref,
  }) : _updatePerfil = updatePerfil,
       _changePassword = changePassword,
       _ref = ref,
       super(const UserProfileIdle());

  Future<void> updatePerfil(
    int idUsuario, {
    String? nombre,
    String? apellido,
    String? nombreMostrar,
    String? telefono,
    String? pais,
    String? zonaHoraria,
    String? idioma,
    String? fotoUrl,
  }) async {
    state = const UserProfileLoading();
    final result = await _updatePerfil(
      idUsuario,
      nombre: nombre,
      apellido: apellido,
      nombreMostrar: nombreMostrar,
      telefono: telefono,
      pais: pais,
      zonaHoraria: zonaHoraria,
      idioma: idioma,
      fotoUrl: fotoUrl,
    );
    if (result.isFail) {
      state = UserProfileError(result.failure.message);
      return;
    }
    // Sync updated user to auth controller
    _ref.read(authControllerProvider.notifier).updateUser(result.data);
    state = UserProfileSuccess(result.data, message: 'Perfil actualizado');
  }

  Future<void> changePassword(int idUsuario, String newPassword) async {
    state = const UserProfileLoading();
    final result = await _changePassword(idUsuario, newPassword);
    if (result.isFail) {
      state = UserProfileError(result.failure.message);
      return;
    }
    state = const PasswordChanged();
  }

  void reset() => state = const UserProfileIdle();
}
