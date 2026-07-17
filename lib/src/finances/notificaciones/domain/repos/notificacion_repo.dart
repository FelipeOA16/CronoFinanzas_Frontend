import '../../../../../core/errors/result.dart';
import '../entities/notificacion.dart';

abstract class NotificacionRepository {
  Future<Result<List<Notificacion>>> getAlertas();
}
