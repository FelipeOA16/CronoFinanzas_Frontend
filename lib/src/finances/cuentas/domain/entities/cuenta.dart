class Cuenta {
  final int id;
  final int usuarioId;
  final String nombre;
  final String tipo;
  final String moneda;
  final double saldoInicial;
  final double saldoActual;
  final String? color;
  final String? icono;
  final String? institucion;
  final bool esActiva;
  final bool incluirEnTotal;
  final String? notas;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Cuenta({
    required this.id,
    required this.usuarioId,
    required this.nombre,
    required this.tipo,
    required this.moneda,
    required this.saldoInicial,
    required this.saldoActual,
    this.color,
    this.icono,
    this.institucion,
    required this.esActiva,
    required this.incluirEnTotal,
    this.notas,
    this.createdAt,
    this.updatedAt,
  });
}
