class Transaccion {
  final int id;
  final int usuarioId;
  final int cuentaId;
  final int? cuentaDestinoId;
  final String tipo; // ingreso | gasto | transferencia
  final double monto;
  final String moneda;
  final DateTime fecha;
  final int? categoriaId;
  final String? descripcion;
  final String? pagadoA;
  final String? notas;
  final bool esRecurrente;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Eager-loaded (opcional)
  final String? categoriaNombre;
  final String? categoriaColor;
  final String? categoriaIcono;

  const Transaccion({
    required this.id,
    required this.usuarioId,
    required this.cuentaId,
    this.cuentaDestinoId,
    required this.tipo,
    required this.monto,
    required this.moneda,
    required this.fecha,
    this.categoriaId,
    this.descripcion,
    this.pagadoA,
    this.notas,
    required this.esRecurrente,
    this.createdAt,
    this.updatedAt,
    this.categoriaNombre,
    this.categoriaColor,
    this.categoriaIcono,
  });
}
