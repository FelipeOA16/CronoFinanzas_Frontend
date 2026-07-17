import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/src/finances/captura_rapida/data/models/captura_rapida_model.dart';
import 'package:frontend/src/finances/captura_rapida/data/models/captura_rapida_resumen_model.dart';

void main() {
  const createdAt = '2026-07-03T10:30:00Z';

  Map<String, dynamic> captureJson({dynamic monto = '5.00'}) => {
    'id': '11',
    'usuario_id': 7,
    'tipo': 'gasto',
    'monto': monto,
    'moneda': 'PEN',
    'cuenta_id': '3',
    'cuenta_destino_id': null,
    'descripcion': null,
    'nota_rapida': 'Cafe',
    'estado': 'pendiente',
    'transaccion_id': null,
    'created_at': createdAt,
    'updated_at': createdAt,
  };

  test('parsea monto Decimal serializado como String', () {
    final model = CapturaRapidaModel.fromJson(captureJson());

    expect(model.monto, 5);
    expect(model.id, 11);
    expect(model.cuentaId, 3);
  });

  test('mantiene soporte para valores num nativos', () {
    final model = CapturaRapidaModel.fromJson(captureJson(monto: 8.75));

    expect(model.monto, 8.75);
  });

  test('parsea resumen y ultima captura con decimales String', () {
    final summary = CapturaRapidaResumenModel.fromJson({
      'pendientes': '2',
      'total_pendiente': '12.50',
      'ultima_captura': captureJson(monto: '5.00'),
    });

    expect(summary.pendientes, 2);
    expect(summary.totalPendiente, 12.5);
    expect(summary.ultimaCaptura?.monto, 5);
  });
}
