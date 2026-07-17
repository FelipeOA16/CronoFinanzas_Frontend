class DeudaPrestamo {
  final int id;
  final int usuarioId;
  final String tipo; // debo | me_deben
  final String nombre;
  final String contraparte;
  final String? descripcion;
  final double montoOriginal;
  final double saldoPendiente;
  final String moneda;
  final DateTime fechaInicio;
  final DateTime? fechaProxima;
  final double? montoProximo;
  final String prioridad; // baja | media | alta | critica
  final String estado; // activa | pagada | cancelada
  final int? cuentaId;
  final int? categoriaId;
  final String? color;
  final String? icono;
  final String? notas;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double totalPagado;

  const DeudaPrestamo({
    required this.id,
    required this.usuarioId,
    required this.tipo,
    required this.nombre,
    required this.contraparte,
    this.descripcion,
    required this.montoOriginal,
    required this.saldoPendiente,
    required this.moneda,
    required this.fechaInicio,
    this.fechaProxima,
    this.montoProximo,
    required this.prioridad,
    required this.estado,
    this.cuentaId,
    this.categoriaId,
    this.color,
    this.icono,
    this.notas,
    this.createdAt,
    this.updatedAt,
    this.totalPagado = 0,
  });

  bool get esDebo => tipo == 'debo';
  bool get estaActiva => estado == 'activa';
  double get progreso => montoOriginal <= 0
      ? 0
      : (1 - (saldoPendiente / montoOriginal)).clamp(0, 1).toDouble();
}
