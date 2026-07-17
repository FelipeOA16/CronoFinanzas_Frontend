class DeudaPrestamoResumenItem {
  final int id;
  final String tipo;
  final String nombre;
  final String contraparte;
  final double saldoPendiente;
  final double? montoProximo;
  final DateTime? fechaProxima;
  final String prioridad;

  const DeudaPrestamoResumenItem({
    required this.id,
    required this.tipo,
    required this.nombre,
    required this.contraparte,
    required this.saldoPendiente,
    this.montoProximo,
    this.fechaProxima,
    required this.prioridad,
  });
}

class DeudaPrestamoResumen {
  final double totalDebo;
  final double totalMeDeben;
  final double balanceNeto;
  final int cantidadActivas;
  final int cantidadCriticas;
  final List<DeudaPrestamoResumenItem> proximas;

  const DeudaPrestamoResumen({
    required this.totalDebo,
    required this.totalMeDeben,
    required this.balanceNeto,
    required this.cantidadActivas,
    required this.cantidadCriticas,
    required this.proximas,
  });
}
