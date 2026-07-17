import '../../../../../core/errors/result.dart';
import '../entities/aporte_meta.dart';
import '../entities/meta_financiera.dart';
import '../entities/meta_financiera_resumen.dart';

abstract class MetaFinancieraRepository {
  Future<Result<List<MetaFinanciera>>> getMetas({
    String? estado,
    String? prioridad,
    String? search,
  });

  Future<Result<MetaFinanciera>> getMeta(int id);
  Future<Result<MetaFinanciera>> createMeta(Map<String, dynamic> body);
  Future<Result<MetaFinanciera>> updateMeta(int id, Map<String, dynamic> body);
  Future<Result<void>> deleteMeta(int id);
  Future<Result<MetaFinancieraResumen>> getResumen();
  Future<Result<List<AporteMeta>>> getAportes(int id);
  Future<Result<AporteMeta>> registrarAporte(int id, Map<String, dynamic> body);
  Future<Result<void>> eliminarAporte(int id, int aporteId);
}
