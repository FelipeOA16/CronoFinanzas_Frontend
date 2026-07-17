import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/errors/result.dart';
import 'package:frontend/src/finances/captura_rapida/domain/entities/captura_rapida.dart';
import 'package:frontend/src/finances/captura_rapida/domain/entities/captura_rapida_resumen.dart';
import 'package:frontend/src/finances/captura_rapida/domain/repos/captura_rapida_repo.dart';
import 'package:frontend/src/finances/captura_rapida/presentation/app/riverpod/captura_rapida_controller.dart';
import 'package:frontend/src/finances/captura_rapida/presentation/app/riverpod/captura_rapida_state.dart';

void main() {
  test('crea optimistamente y no recarga la lista', () async {
    final repository = _FakeCapturaRapidaRepository();
    final container = ProviderContainer(
      overrides: [
        capturaRapidaRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(capturaRapidaControllerProvider.notifier);
    final operation = controller.createOptimistic({
      'tipo': 'gasto',
      'monto': 5.0,
      'moneda': 'PEN',
      'cuenta_id': null,
      'cuenta_destino_id': null,
      'nota_rapida': 'Cafe',
    });

    final optimistic = container.read(capturaRapidaControllerProvider);
    expect(optimistic.pendientes, hasLength(1));
    expect(optimistic.pendientes.single.id, isNegative);
    expect(
      optimistic.statusFor(optimistic.pendientes.single.id),
      CapturaItemStatus.saving,
    );

    repository.createCompleter.complete(
      Result.ok(
        CapturaRapida(
          id: 42,
          usuarioId: 7,
          tipo: 'gasto',
          monto: 5,
          moneda: 'PEN',
          notaRapida: 'Cafe',
          estado: 'pendiente',
          createdAt: DateTime(2026, 7, 3),
        ),
      ),
    );

    expect(await operation, isTrue);
    final confirmed = container.read(capturaRapidaControllerProvider);
    expect(confirmed.pendientes.single.id, 42);
    expect(repository.listCalls, 0);
  });
}

class _FakeCapturaRapidaRepository implements CapturaRapidaRepository {
  final createCompleter = Completer<Result<CapturaRapida>>();
  int listCalls = 0;

  @override
  Future<Result<CapturaRapida>> create(Map<String, dynamic> body) =>
      createCompleter.future;

  @override
  Future<Result<List<CapturaRapida>>> getCapturas({
    String? estado,
    String? tipo,
  }) async {
    listCalls++;
    return Result.ok(const []);
  }

  @override
  Future<Result<CapturaRapida>> completar(int id, Map<String, dynamic> body) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> descartar(int id) => throw UnimplementedError();

  @override
  Future<Result<CapturaRapida>> getCaptura(int id) =>
      throw UnimplementedError();

  @override
  Future<Result<CapturaRapidaResumen>> getResumen() async {
    return Result.ok(
      const CapturaRapidaResumen(pendientes: 0, totalPendiente: 0),
    );
  }

  @override
  Future<Result<CapturaRapida>> update(int id, Map<String, dynamic> body) =>
      throw UnimplementedError();
}
