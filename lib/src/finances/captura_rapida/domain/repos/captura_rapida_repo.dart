import '../../../../../core/errors/result.dart';
import '../entities/captura_rapida.dart';
import '../entities/captura_rapida_resumen.dart';

abstract class CapturaRapidaRepository {
  Future<Result<List<CapturaRapida>>> getCapturas({
    String? estado,
    String? tipo,
  });
  Future<Result<CapturaRapida>> getCaptura(int id);
  Future<Result<CapturaRapida>> create(Map<String, dynamic> body);
  Future<Result<CapturaRapida>> update(int id, Map<String, dynamic> body);
  Future<Result<CapturaRapida>> completar(int id, Map<String, dynamic> body);
  Future<Result<void>> descartar(int id);
  Future<Result<CapturaRapidaResumen>> getResumen();
}
