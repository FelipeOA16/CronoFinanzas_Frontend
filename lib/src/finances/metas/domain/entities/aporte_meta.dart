class AporteMeta {
  final int id;
  final int metaId;
  final int usuarioId;
  final int transaccionId;
  final int cuentaId;
  final double monto;
  final String moneda;
  final DateTime fechaAporte;
  final String? notas;
  final DateTime? createdAt;

  const AporteMeta({
    required this.id,
    required this.metaId,
    required this.usuarioId,
    required this.transaccionId,
    required this.cuentaId,
    required this.monto,
    required this.moneda,
    required this.fechaAporte,
    this.notas,
    this.createdAt,
  });
}
