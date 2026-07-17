import '../../../../core/errors/result.dart';
import '../../../auth/domain/entities/user.dart';
import '../repos/user_repo.dart';

class UpdatePerfil {
  final UserRepository _repo;
  UpdatePerfil(this._repo);

  Future<Result<User>> call(
    int idUsuario, {
    String? nombre,
    String? apellido,
    String? nombreMostrar,
    String? telefono,
    String? pais,
    String? zonaHoraria,
    String? idioma,
    String? fotoUrl,
  }) {
    return _repo.updatePerfil(
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
  }
}
