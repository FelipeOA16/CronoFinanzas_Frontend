import '../../../../../core/errors/result.dart';
import '../entities/deuda_prestamo.dart';
import '../entities/deuda_prestamo_resumen.dart';
import '../entities/pago_deuda_prestamo.dart';

abstract class DeudaPrestamoRepository {
  Future<Result<List<DeudaPrestamo>>> getDeudasPrestamos({
    String? tipo,
    String? estado,
    String? prioridad,
    DateTime? vencenHasta,
    String? search,
  });

  Future<Result<DeudaPrestamo>> getDeudaPrestamo(int id);
  Future<Result<DeudaPrestamo>> createDeudaPrestamo(Map<String, dynamic> body);
  Future<Result<DeudaPrestamo>> updateDeudaPrestamo(
    int id,
    Map<String, dynamic> body,
  );
  Future<Result<void>> deleteDeudaPrestamo(int id);
  Future<Result<DeudaPrestamoResumen>> getResumen();
  Future<Result<List<PagoDeudaPrestamo>>> getPagos(int id);
  Future<Result<PagoDeudaPrestamo>> registrarPago(
    int id,
    Map<String, dynamic> body,
  );
  Future<Result<void>> eliminarPago(int id, int pagoId);
}
