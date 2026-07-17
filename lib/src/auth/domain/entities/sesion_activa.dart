class SesionActiva {
  final String uuid;
  final String? dispositivo;
  final String? sistemaOperativo;
  final String? navegador;
  final String? ip;
  final DateTime ultimaActividad;
  final DateTime createdAt;

  const SesionActiva({
    required this.uuid,
    this.dispositivo,
    this.sistemaOperativo,
    this.navegador,
    this.ip,
    required this.ultimaActividad,
    required this.createdAt,
  });
}
