import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.idUsuario,
    required super.uuid,
    super.nombre,
    super.apellido,
    super.nombreMostrar,
    required super.email,
    super.telefono,
    super.pais,
    required super.zonaHoraria,
    required super.idioma,
    required super.estadoCuenta,
    super.fotoUrl,
    required super.onboardingCompletado,
    super.emailVerificado = false,
    super.ultimoAcceso,
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idUsuario: json['id'] as int,
      uuid: json['uuid'] as String,
      nombre: json['nombre'] as String?,
      apellido: json['apellido'] as String?,
      nombreMostrar: json['nombre_mostrar'] as String?,
      email: json['email'] as String,
      telefono: json['telefono'] as String?,
      pais: json['pais'] as String?,
      zonaHoraria: json['zona_horaria'] as String? ?? 'America/Lima',
      idioma: json['idioma'] as String? ?? 'es-PE',
      estadoCuenta: json['estado_cuenta'] as String? ?? 'activo',
      fotoUrl: json['foto_url'] as String?,
      onboardingCompletado: json['onboarding_completado'] as bool? ?? false,
      emailVerificado: json['email_verificado'] as bool? ?? false,
      ultimoAcceso: json['ultimo_acceso_at'] != null
          ? DateTime.tryParse(json['ultimo_acceso_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id_usuario': idUsuario,
    'uuid': uuid,
    'nombre': nombre,
    'apellido': apellido,
    'nombre_mostrar': nombreMostrar,
    'email': email,
    'telefono': telefono,
    'pais': pais,
    'zona_horaria': zonaHoraria,
    'idioma': idioma,
    'estado_cuenta': estadoCuenta,
    'foto_url': fotoUrl,
    'onboarding_completado': onboardingCompletado,
    'ultimo_acceso': ultimoAcceso?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
  };
}
