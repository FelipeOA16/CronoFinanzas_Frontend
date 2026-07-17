import '../../../../../core/errors/result.dart';
import '../entities/cuenta.dart';

abstract class CuentaRepository {
  Future<Result<List<Cuenta>>> getCuentas();
  Future<Result<Cuenta>> createCuenta({
    required String nombre,
    required String tipo,
    required String moneda,
    required double saldoInicial,
    String? color,
    String? icono,
    String? institucion,
    bool esActiva,
    bool incluirEnTotal,
    String? notas,
  });
  Future<Result<Cuenta>> updateCuenta({
    required int id,
    String? nombre,
    String? tipo,
    String? moneda,
    String? color,
    String? icono,
    String? institucion,
    bool? esActiva,
    bool? incluirEnTotal,
    String? notas,
  });
  Future<Result<void>> deleteCuenta(int id);
}
