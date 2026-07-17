import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/design_system/components/components.dart';
import '../../../../../../core/design_system/brand/brand_icons.dart';
import '../../../../../../core/design_system/spacing/cf_spacing.dart';
import '../../../cuentas/domain/entities/cuenta.dart';
import '../../../cuentas/presentation/app/riverpod/cuenta_controller.dart';
import '../../../cuentas/presentation/app/riverpod/cuenta_state.dart';
import '../app/riverpod/captura_rapida_controller.dart';

class CapturaRapidaSubmission {
  final Future<bool> completion;

  const CapturaRapidaSubmission(this.completion);
}

class CapturaRapidaSheet extends ConsumerStatefulWidget {
  final String? initialTipo;
  final String? initialMonto;
  final String? initialNota;

  const CapturaRapidaSheet({
    super.key,
    this.initialTipo,
    this.initialMonto,
    this.initialNota,
  });

  static Future<CapturaRapidaSubmission?> show(
    BuildContext context, {
    String? initialTipo,
    String? initialMonto,
    String? initialNota,
  }) {
    return showModalBottomSheet<CapturaRapidaSubmission>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => CapturaRapidaSheet(
        initialTipo: initialTipo,
        initialMonto: initialMonto,
        initialNota: initialNota,
      ),
    );
  }

  @override
  ConsumerState<CapturaRapidaSheet> createState() => _CapturaRapidaSheetState();
}

class _CapturaRapidaSheetState extends ConsumerState<CapturaRapidaSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _monto;
  late final TextEditingController _nota;
  String _tipo = 'gasto';
  int? _cuentaId;
  int? _destinoId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _tipo =
        const {'gasto', 'ingreso', 'transferencia'}.contains(widget.initialTipo)
        ? widget.initialTipo!
        : 'gasto';
    _monto = TextEditingController(text: widget.initialMonto ?? '');
    _nota = TextEditingController(text: widget.initialNota ?? '');
    Future.microtask(() {
      if (ref.read(cuentaControllerProvider) is CuentaInitial) {
        ref.read(cuentaControllerProvider.notifier).loadCuentas();
      }
    });
  }

  @override
  void dispose() {
    _monto.dispose();
    _nota.dispose();
    super.dispose();
  }

  List<Cuenta> _cuentas(CuentaState state) => switch (state) {
    CuentaLoaded(:final cuentas) => cuentas,
    CuentaOperationSuccess(:final cuentas) => cuentas,
    CuentaError(:final previousCuentas) => previousCuentas,
    _ => const [],
  };

  Future<void> _submit() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final completion = ref
        .read(capturaRapidaControllerProvider.notifier)
        .createOptimistic({
          'tipo': _tipo,
          'monto': double.parse(_monto.text.replaceAll(',', '.')),
          'moneda': 'PEN',
          'cuenta_id': _cuentaId,
          'cuenta_destino_id': _tipo == 'transferencia' ? _destinoId : null,
          'nota_rapida': _nota.text.trim().isEmpty ? null : _nota.text.trim(),
        });
    bool? earlyResult;
    completion.then((value) => earlyResult = value);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    if (earlyResult == false) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar. Intenta nuevamente.'),
        ),
      );
      return;
    }
    Navigator.of(context).pop(CapturaRapidaSubmission(completion));
  }

  @override
  Widget build(BuildContext context) {
    final accounts = _cuentas(ref.watch(cuentaControllerProvider));
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        CFSpacing.md,
        CFSpacing.md,
        CFSpacing.md,
        bottom + CFSpacing.md,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CFFormHeader(
                title: 'Captura rapida',
                subtitle:
                    'Anota lo esencial ahora. Completa los detalles despues.',
              ),
              const SizedBox(height: CFSpacing.md),
              CFFormSegmented<String>(
                segments: const [
                  ButtonSegment(value: 'gasto', label: Text('Gasto')),
                  ButtonSegment(value: 'ingreso', label: Text('Ingreso')),
                  ButtonSegment(
                    value: 'transferencia',
                    label: Text('Transferencia'),
                  ),
                ],
                selected: {_tipo},
                onSelectionChanged: (value) {
                  setState(() => _tipo = value.first);
                },
              ),
              const SizedBox(height: CFSpacing.md),
              TextFormField(
                controller: _monto,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  prefixText: 'S/ ',
                ),
                validator: (value) {
                  final parsed = double.tryParse(
                    (value ?? '').replaceAll(',', '.'),
                  );
                  return parsed == null || parsed <= 0
                      ? 'Ingresa un monto mayor a cero.'
                      : null;
                },
              ),
              const SizedBox(height: CFSpacing.sm),
              DropdownButtonFormField<int?>(
                value: _cuentaId,
                decoration: InputDecoration(
                  labelText: _tipo == 'transferencia'
                      ? 'Cuenta origen (opcional)'
                      : 'Cuenta (opcional)',
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Luego')),
                  ...accounts.map(
                    (account) => DropdownMenuItem(
                      value: account.id,
                      child: Text(account.nombre),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _cuentaId = value),
              ),
              if (_tipo == 'transferencia') ...[
                const SizedBox(height: CFSpacing.sm),
                DropdownButtonFormField<int?>(
                  value: _destinoId,
                  decoration: const InputDecoration(
                    labelText: 'Cuenta destino (opcional)',
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Luego')),
                    ...accounts.map(
                      (account) => DropdownMenuItem(
                        value: account.id,
                        child: Text(account.nombre),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _destinoId = value),
                ),
              ],
              const SizedBox(height: CFSpacing.sm),
              TextFormField(
                controller: _nota,
                maxLines: 2,
                maxLength: 180,
                decoration: const InputDecoration(
                  labelText: 'Nota rapida (opcional)',
                  hintText: 'Ej. Almuerzo cerca de la oficina',
                ),
              ),
              const SizedBox(height: CFSpacing.sm),
              if (_saving) ...[
                Text(
                  'Guardando captura...',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: CFSpacing.xs),
              ],
              SizedBox(
                height: 52,
                child: CFButton(
                  label: 'Guardar captura',
                  icon: BrandIcons.quickCapture,
                  loading: _saving,
                  onPressed: _saving ? null : _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
