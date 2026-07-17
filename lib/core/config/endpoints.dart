class Endpoints {
  static const String apiPrefix = '/api/v1';

  // Auth
  static const String register = '$apiPrefix/auth/register';
  static const String login = '$apiPrefix/auth/login';
  static const String me = '$apiPrefix/auth/me';
  static const String refresh = '$apiPrefix/auth/refresh';
  static const String logout = '$apiPrefix/auth/logout';
  static const String forgotPassword = '$apiPrefix/auth/forgot-password';
  static const String resetPassword = '$apiPrefix/auth/reset-password';
  static const String verifyEmail = '$apiPrefix/auth/verify-email';
  static const String resendVerification =
      '$apiPrefix/auth/resend-verification';

  // Users
  static String userPerfil(int idUsuario) =>
      '$apiPrefix/users/$idUsuario/perfil';
  static String userPassword(int idUsuario) =>
      '$apiPrefix/users/$idUsuario/password';
  static String userDelete(int idUsuario) => '$apiPrefix/users/$idUsuario';
  static String userSessions(int idUsuario) =>
      '$apiPrefix/users/$idUsuario/sessions';
  static String userSession(int idUsuario, String uuid) =>
      '$apiPrefix/users/$idUsuario/sessions/$uuid';

  // Cuentas
  static const String cuentas = '$apiPrefix/cuentas';
  static const String cuentasResumen = '$apiPrefix/cuentas/resumen';
  static String cuenta(int id) => '$apiPrefix/cuentas/$id';

  // Transacciones
  static const String transacciones = '$apiPrefix/transacciones';
  static String transaccion(int id) => '$apiPrefix/transacciones/$id';

  // Capturas rapidas
  static const String capturasRapidas = '$apiPrefix/capturas-rapidas/';
  static const String capturasRapidasResumen =
      '$apiPrefix/capturas-rapidas/resumen';
  static String capturaRapida(int id) => '$apiPrefix/capturas-rapidas/$id';
  static String capturaRapidaCompletar(int id) =>
      '$apiPrefix/capturas-rapidas/$id/completar';

  // Categorias
  static const String categorias = '$apiPrefix/categorias';
  static String categoria(int id) => '$apiPrefix/categorias/$id';

  // Presupuestos
  static const String presupuestos = '$apiPrefix/presupuestos';
  static String presupuesto(int id) => '$apiPrefix/presupuestos/$id';

  // Reportes
  static const String reportesResumen = '$apiPrefix/reportes/resumen';

  // Notificaciones
  static const String notificaciones = '$apiPrefix/notificaciones';

  // Deudas y prestamos
  static const String deudasPrestamos = '$apiPrefix/deudas-prestamos';
  static const String deudasPrestamosResumen =
      '$apiPrefix/deudas-prestamos/resumen';
  static String deudaPrestamo(int id) => '$apiPrefix/deudas-prestamos/$id';
  static String deudaPrestamoPagos(int id) =>
      '$apiPrefix/deudas-prestamos/$id/pagos';
  static String deudaPrestamoPago(int id, int pagoId) =>
      '$apiPrefix/deudas-prestamos/$id/pagos/$pagoId';

  // Metas financieras
  static const String metas = '$apiPrefix/metas';
  static const String metasResumen = '$apiPrefix/metas/resumen';
  static String meta(int id) => '$apiPrefix/metas/$id';
  static String metaAportes(int id) => '$apiPrefix/metas/$id/aportes';
  static String metaAporte(int id, int aporteId) =>
      '$apiPrefix/metas/$id/aportes/$aporteId';
}
