class CapturaRapida {
  final int id;
  final int usuarioId;
  final String tipo;
  final double monto;
  final String moneda;
  final int? cuentaId;
  final int? cuentaDestinoId;
  final String? descripcion;
  final String? notaRapida;
  final String estado;
  final int? transaccionId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CapturaRapida({
    required this.id,
    required this.usuarioId,
    required this.tipo,
    required this.monto,
    required this.moneda,
    this.cuentaId,
    this.cuentaDestinoId,
    this.descripcion,
    this.notaRapida,
    required this.estado,
    this.transaccionId,
    required this.createdAt,
    this.updatedAt,
  });

  bool get estaPendiente => estado == 'pendiente';
}
