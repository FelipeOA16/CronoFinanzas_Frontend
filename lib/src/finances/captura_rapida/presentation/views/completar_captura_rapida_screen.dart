import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/design_system/components/components.dart';
import '../../../../../../core/design_system/spacing/cf_spacing.dart';
import '../../../cuentas/domain/entities/cuenta.dart';
import '../../../cuentas/presentation/app/riverpod/cuenta_controller.dart';
import '../../../cuentas/presentation/app/riverpod/cuenta_state.dart';
import '../../../transacciones/domain/entities/categoria.dart';
import '../../../transacciones/presentation/app/riverpod/transaccion_controller.dart';
import '../../../transacciones/presentation/app/riverpod/transaccion_state.dart';
import '../../domain/entities/captura_rapida.dart';
import '../app/riverpod/captura_rapida_controller.dart';

class CompletarCapturaRapidaScreen extends ConsumerStatefulWidget {
  final CapturaRapida captura;

  const CompletarCapturaRapidaScreen({super.key, required this.captura});

  @override
  ConsumerState<CompletarCapturaRapidaScreen> createState() =>
      _CompletarCapturaRapidaScreenState();
}

class _CompletarCapturaRapidaScreenState
    extends ConsumerState<CompletarCapturaRapidaScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descripcion;
  late final TextEditingController _pagadoA;
  late final TextEditingController _notas;
  late int? _cuentaId;
  late int? _destinoId;
  int? _categoriaId;
  DateTime _fecha = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _cuentaId = widget.captura.cuentaId;
    _destinoId = widget.captura.cuentaDestinoId;
    _descripcion = TextEditingController(
      text: widget.captura.descripcion ?? widget.captura.notaRapida ?? '',
    );
    _pagadoA = TextEditingController();
    _notas = TextEditingController(text: widget.captura.notaRapida ?? '');
    Future.microtask(() async {
      if (ref.read(cuentaControllerProvider) is CuentaInitial) {
        await ref.read(cuentaControllerProvider.notifier).loadCuentas();
      }
      if (ref.read(transaccionControllerProvider) is TransaccionInitial) {
        await ref.read(transaccionControllerProvider.notifier).load(limit: 200);
      }
    });
  }

  @override
  void dispose() {
    _descripcion.dispose();
    _pagadoA.dispose();
    _notas.dispose();
    super.dispose();
  }

  List<Cuenta> _accounts(CuentaState state) => switch (state) {
    CuentaLoaded(:final cuentas) => cuentas,
    CuentaOperationSuccess(:final cuentas) => cuentas,
    CuentaError(:final previousCuentas) => previousCuentas,
    _ => const [],
  };

  List<Categoria> _categories(TransaccionState state) => switch (state) {
    TransaccionLoaded(:final categorias) => categorias,
    TransaccionOperationSuccess(:final categorias) => categorias,
    TransaccionError(:final previousCategorias) => previousCategorias,
    _ => const [],
  };

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (selected != null) setState(() => _fecha = selected);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final ok = await ref
        .read(capturaRapidaControllerProvider.notifier)
        .completar(widget.captura.id, {
          'cuenta_id': _cuentaId,
          'cuenta_destino_id': widget.captura.tipo == 'transferencia'
              ? _destinoId
              : null,
          'categoria_id': widget.captura.tipo == 'transferencia'
              ? null
              : _categoriaId,
          'descripcion': _descripcion.text.trim().isEmpty
              ? null
              : _descripcion.text.trim(),
          'fecha':
              '${_fecha.year.toString().padLeft(4, '0')}-'
              '${_fecha.month.toString().padLeft(2, '0')}-'
              '${_fecha.day.toString().padLeft(2, '0')}',
          'pagado_a': _pagadoA.text.trim().isEmpty
              ? null
              : _pagadoA.text.trim(),
          'notas': _notas.text.trim().isEmpty ? null : _notas.text.trim(),
        });
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Movimiento creado correctamente.')),
      );
      return;
    }
    final state = ref.read(capturaRapidaControllerProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          state.errorMessage ??
              'No se pudo completar el movimiento. Intenta nuevamente.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accounts = _accounts(ref.watch(cuentaControllerProvider));
    final categories = _categories(ref.watch(transaccionControllerProvider))
        .where(
          (category) =>
              category.tipo == widget.captura.tipo || category.tipo == 'ambos',
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Completar captura')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            CFSpacing.md,
            CFSpacing.md,
            CFSpacing.md,
            MediaQuery.viewInsetsOf(context).bottom + CFSpacing.xxl,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Form(
                key: _formKey,
                child: CFFormSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CFFormHeader(
                        title:
                            '${widget.captura.tipo.toUpperCase()} - S/ ${widget.captura.monto.toStringAsFixed(2)}',
                        subtitle:
                            'Completa los datos para crear el movimiento real.',
                      ),
                      const SizedBox(height: CFSpacing.lg),
                      DropdownButtonFormField<int>(
                        value: _cuentaId,
                        decoration: InputDecoration(
                          labelText: widget.captura.tipo == 'transferencia'
                              ? 'Cuenta origen'
                              : 'Cuenta',
                        ),
                        items: accounts
                            .map(
                              (account) => DropdownMenuItem(
                                value: account.id,
                                child: Text(account.nombre),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(() => _cuentaId = value),
                        validator: (value) =>
                            value == null ? 'Selecciona una cuenta.' : null,
                      ),
                      if (widget.captura.tipo == 'transferencia') ...[
                        const SizedBox(height: CFSpacing.sm),
                        DropdownButtonFormField<int>(
                          value: _destinoId,
                          decoration: const InputDecoration(
                            labelText: 'Cuenta destino',
                          ),
                          items: accounts
                              .where((account) => account.id != _cuentaId)
                              .map(
                                (account) => DropdownMenuItem(
                                  value: account.id,
                                  child: Text(account.nombre),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _destinoId = value),
                          validator: (value) =>
                              value == null ? 'Selecciona el destino.' : null,
                        ),
                      ] else ...[
                        const SizedBox(height: CFSpacing.sm),
                        DropdownButtonFormField<int?>(
                          value: _categoriaId,
                          decoration: const InputDecoration(
                            labelText: 'Categoria (opcional)',
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Sin categoria'),
                            ),
                            ...categories.map(
                              (category) => DropdownMenuItem(
                                value: category.id,
                                child: Text(category.nombre),
                              ),
                            ),
                          ],
                          onChanged: (value) =>
                              setState(() => _categoriaId = value),
                        ),
                      ],
                      const SizedBox(height: CFSpacing.sm),
                      TextFormField(
                        controller: _descripcion,
                        decoration: const InputDecoration(
                          labelText: 'Descripcion',
                        ),
                      ),
                      const SizedBox(height: CFSpacing.sm),
                      TextFormField(
                        controller: _pagadoA,
                        decoration: InputDecoration(
                          labelText: widget.captura.tipo == 'ingreso'
                              ? 'Recibido de (opcional)'
                              : 'Pagado a (opcional)',
                        ),
                      ),
                      const SizedBox(height: CFSpacing.sm),
                      InkWell(
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Fecha'),
                          child: Text(
                            '${_fecha.day.toString().padLeft(2, '0')}/'
                            '${_fecha.month.toString().padLeft(2, '0')}/'
                            '${_fecha.year}',
                          ),
                        ),
                      ),
                      const SizedBox(height: CFSpacing.sm),
                      TextFormField(
                        controller: _notas,
                        maxLines: 3,
                        maxLength: 300,
                        decoration: const InputDecoration(labelText: 'Notas'),
                      ),
                      const SizedBox(height: CFSpacing.md),
                      CFFormActions(
                        primaryLabel: 'Crear movimiento',
                        loading: _saving,
                        onPrimary: _saving ? null : _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
