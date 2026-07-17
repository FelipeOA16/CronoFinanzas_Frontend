import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design_system/components/components.dart';
import '../../../../app/di/providers.dart';
import '../../../cuentas/domain/entities/cuenta.dart';
import '../../../cuentas/presentation/app/riverpod/cuenta_controller.dart';
import '../../../cuentas/presentation/app/riverpod/cuenta_state.dart';
import '../../domain/entities/deuda_prestamo.dart';
import '../app/riverpod/deuda_prestamo_controller.dart';

class RegistrarPagoDeudaScreen extends ConsumerStatefulWidget {
  final DeudaPrestamo item;
  const RegistrarPagoDeudaScreen({super.key, required this.item});

  @override
  ConsumerState<RegistrarPagoDeudaScreen> createState() =>
      _RegistrarPagoDeudaScreenState();
}

class _RegistrarPagoDeudaScreenState
    extends ConsumerState<RegistrarPagoDeudaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montoCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  late DateTime _fecha;
  int? _cuentaId;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fecha = DateTime.now();
    _cuentaId = widget.item.cuentaId;
    _montoCtrl.text = (widget.item.montoProximo ?? widget.item.saldoPendiente)
        .clamp(0, widget.item.saldoPendiente)
        .toStringAsFixed(2);
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
      'fecha_pago': _date(_fecha),
      if (_notasCtrl.text.trim().isNotEmpty) 'notas': _notasCtrl.text.trim(),
    };
    final ok = await ref
        .read(deudaPrestamoControllerProvider.notifier)
        .registrarPago(widget.item.id, body);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      await _refreshFinancialState();
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  Future<void> _refreshFinancialState() async {
    await ref.read(cuentaControllerProvider.notifier).loadCuentas();
    if (!mounted) return;
    ref.invalidate(patrimonioProvider);
    ref.invalidate(deudaPrestamoResumenProvider);
    ref.invalidate(patrimonioNetoEstimadoProvider);
    try {
      await Future.wait([
        ref.read(patrimonioProvider.future),
        ref.read(deudaPrestamoResumenProvider.future),
        ref.read(patrimonioNetoEstimadoProvider.future),
      ]);
    } catch (_) {
      // La operacion principal ya fue exitosa; las pantallas con watch mostraran
      // el error normal del provider si el refresh financiero falla.
    }
  }

  @override
  Widget build(BuildContext context) {
    final cuentaState = ref.watch(cuentaControllerProvider);
    final cuentas = _cuentas(cuentaState);
    final action = widget.item.esDebo ? 'pago' : 'cobro';
    return Scaffold(
      appBar: AppBar(title: Text('Registrar $action')),
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
                'Pendiente: ${widget.item.moneda} ${widget.item.saldoPendiente.toStringAsFixed(2)}',
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
                  if (n > widget.item.saldoPendiente)
                    return 'No puede superar el saldo pendiente';
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
                label: widget.item.esDebo
                    ? 'Registrar pago'
                    : 'Registrar cobro',
                onPressed: _loading ? null : _submit,
                icon: Icons.payments_outlined,
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
