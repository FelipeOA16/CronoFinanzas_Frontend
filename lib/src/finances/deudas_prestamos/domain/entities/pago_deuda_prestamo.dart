class PagoDeudaPrestamo {
  final int id;
  final int deudaPrestamoId;
  final int usuarioId;
  final int transaccionId;
  final int cuentaId;
  final double monto;
  final String moneda;
  final DateTime fechaPago;
  final String? notas;
  final DateTime? createdAt;

  const PagoDeudaPrestamo({
    required this.id,
    required this.deudaPrestamoId,
    required this.usuarioId,
    required this.transaccionId,
    required this.cuentaId,
    required this.monto,
    required this.moneda,
    required this.fechaPago,
    this.notas,
    this.createdAt,
  });
}
