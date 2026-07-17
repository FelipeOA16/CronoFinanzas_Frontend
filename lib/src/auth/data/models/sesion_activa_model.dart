import '../../domain/entities/sesion_activa.dart';

class SesionActivaModel extends SesionActiva {
  const SesionActivaModel({
    required super.uuid,
    super.dispositivo,
    super.sistemaOperativo,
    super.navegador,
    super.ip,
    required super.ultimaActividad,
    required super.createdAt,
  });

  factory SesionActivaModel.fromJson(Map<String, dynamic> json) {
    return SesionActivaModel(
      uuid: json['uuid'] as String,
      dispositivo: json['dispositivo'] as String?,
      sistemaOperativo: json['sistema_operativo'] as String?,
      navegador: json['navegador'] as String?,
      ip: json['ip'] as String?,
      ultimaActividad: DateTime.parse(json['ultima_actividad_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
