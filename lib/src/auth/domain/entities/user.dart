class User {
  final int idUsuario;
  final String uuid;
  final String? nombre;
  final String? apellido;
  final String? nombreMostrar;
  final String email;
  final String? telefono;
  final String? pais;
  final String zonaHoraria;
  final String idioma;
  final String estadoCuenta;
  final String? fotoUrl;
  final bool onboardingCompletado;
  final bool emailVerificado;
  final DateTime? ultimoAcceso;
  final DateTime? createdAt;

  const User({
    required this.idUsuario,
    required this.uuid,
    this.nombre,
    this.apellido,
    this.nombreMostrar,
    required this.email,
    this.telefono,
    this.pais,
    required this.zonaHoraria,
    required this.idioma,
    required this.estadoCuenta,
    this.fotoUrl,
    required this.onboardingCompletado,
    this.emailVerificado = false,
    this.ultimoAcceso,
    this.createdAt,
  });

  String get displayName => nombreMostrar ?? nombre ?? email.split('@').first;
}
