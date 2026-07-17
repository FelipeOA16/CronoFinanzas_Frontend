import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/design_system/components/components.dart';
import '../../../cuentas/domain/entities/cuenta.dart';
import '../../../cuentas/presentation/app/riverpod/cuenta_controller.dart';
import '../../../cuentas/presentation/app/riverpod/cuenta_state.dart';
import '../../domain/entities/meta_financiera.dart';
import '../app/riverpod/meta_financiera_controller.dart';

class RegistrarAporteMetaScreen extends ConsumerStatefulWidget {
  final MetaFinanciera item;
  const RegistrarAporteMetaScreen({super.key, required this.item});

  @override
  ConsumerState<RegistrarAporteMetaScreen> createState() =>
      _RegistrarAporteMetaScreenState();
}

class _RegistrarAporteMetaScreenState
    extends ConsumerState<RegistrarAporteMetaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montoCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  late DateTime _fecha;
  int? _cuentaId;
  bool _loading = false;

  double get _faltante => widget.item.montoObjetivo - widget.item.montoActual;

  @override
  void initState() {
    super.initState();
    _fecha = DateTime.now();
    _cuentaId = widget.item.cuentaId;
    _montoCtrl.text = _faltante.clamp(0, _faltante).toStringAsFixed(2);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(cuentaControllerProvider);
      if (state is CuentaInitial) {
        ref.read(cuentaControllerProvider.notifier).loadCuentas();
      }
    });
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _fecha = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final body = <String, dynamic>{
      'cuenta_id': _cuentaId,
      'monto': double.parse(_montoCtrl.text.trim()),
      'fecha_aporte': _date(_fecha),
      if (_notasCtrl.text.trim().isNotEmpty) 'notas': _notasCtrl.text.trim(),
    };
    final ok = await ref
        .read(metaFinancieraControllerProvider.notifier)
        .registrarAporte(widget.item.id, body);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final cuentas = _cuentas(ref.watch(cuentaControllerProvider));
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar aporte')),
      body: CFResponsiveFormLayout(
        maxWidth: 560,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.item.nombre,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Faltante: ${widget.item.moneda} ${_faltante.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                isExpanded: true,
                value: _cuentaId,
                decoration: const InputDecoration(
                  labelText: 'Cuenta',
                  border: OutlineInputBorder(),
                ),
                items: cuentas
                    .map(
                      (c) =>
                          DropdownMenuItem(value: c.id, child: Text(c.nombre)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _cuentaId = v),
                validator: (v) => v == null ? 'Selecciona una cuenta' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _montoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Monto invalido';
                  if (n > _faltante) return 'No puede superar el faltante';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(_fmt(_fecha)),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notasCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notas',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              CFButton(
                label: 'Registrar aporte',
                onPressed: _loading ? null : _submit,
                icon: Icons.add_card_outlined,
                loading: _loading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Cuenta> _cuentas(CuentaState state) {
    if (state is CuentaLoaded) return state.cuentas;
    if (state is CuentaOperationSuccess) return state.cuentas;
    if (state is CuentaError) return state.previousCuentas;
    return const [];
  }
}

String _date(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
String _fmt(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
