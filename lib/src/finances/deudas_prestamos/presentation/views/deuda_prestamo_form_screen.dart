import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design_system/components/components.dart';
import '../../../cuentas/domain/entities/cuenta.dart';
import '../../../cuentas/presentation/app/riverpod/cuenta_controller.dart';
import '../../../cuentas/presentation/app/riverpod/cuenta_state.dart';
import '../../domain/entities/deuda_prestamo.dart';
import '../app/riverpod/deuda_prestamo_controller.dart';

class DeudaPrestamoFormScreen extends ConsumerStatefulWidget {
  final DeudaPrestamo? item;
  const DeudaPrestamoFormScreen({super.key, this.item});

  @override
  ConsumerState<DeudaPrestamoFormScreen> createState() =>
      _DeudaPrestamoFormScreenState();
}

class _DeudaPrestamoFormScreenState
    extends ConsumerState<DeudaPrestamoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _tipo;
  late String _prioridad;
  late DateTime _fechaInicio;
  DateTime? _fechaProxima;
  int? _cuentaId;
  final _nombreCtrl = TextEditingController();
  final _contraparteCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();
  final _montoProximoCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  bool _loading = false;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _tipo = item?.tipo ?? 'debo';
    _prioridad = item?.prioridad ?? 'media';
    _fechaInicio = item?.fechaInicio ?? DateTime.now();
    _fechaProxima = item?.fechaProxima;
    _cuentaId = item?.cuentaId;
    _nombreCtrl.text = item?.nombre ?? '';
    _contraparteCtrl.text = item?.contraparte ?? '';
    _descripcionCtrl.text = item?.descripcion ?? '';
    _montoCtrl.text = item?.montoOriginal.toStringAsFixed(2) ?? '';
    _montoProximoCtrl.text = item?.montoProximo?.toStringAsFixed(2) ?? '';
    _notasCtrl.text = item?.notas ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(cuentaControllerProvider);
      if (state is CuentaInitial) {
        ref.read(cuentaControllerProvider.notifier).loadCuentas();
      }
    });
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _contraparteCtrl.dispose();
    _descripcionCtrl.dispose();
    _montoCtrl.dispose();
    _montoProximoCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool proxima}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: proxima ? (_fechaProxima ?? DateTime.now()) : _fechaInicio,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (proxima) {
        _fechaProxima = picked;
      } else {
        _fechaInicio = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final body = <String, dynamic>{
      if (!_isEdit) 'tipo': _tipo,
      'nombre': _nombreCtrl.text.trim(),
      'contraparte': _contraparteCtrl.text.trim(),
      if (_descripcionCtrl.text.trim().isNotEmpty)
        'descripcion': _descripcionCtrl.text.trim(),
      if (!_isEdit) 'monto_original': double.parse(_montoCtrl.text.trim()),
      if (!_isEdit) 'fecha_inicio': _date(_fechaInicio),
      if (_fechaProxima != null) 'fecha_proxima': _date(_fechaProxima!),
      if (_montoProximoCtrl.text.trim().isNotEmpty)
        'monto_proximo': double.parse(_montoProximoCtrl.text.trim()),
      'prioridad': _prioridad,
      if (_cuentaId != null) 'cuenta_id': _cuentaId,
      if (_notasCtrl.text.trim().isNotEmpty) 'notas': _notasCtrl.text.trim(),
    };
    final controller = ref.read(deudaPrestamoControllerProvider.notifier);
    final ok = _isEdit
        ? await controller.update(widget.item!.id, body)
        : await controller.create(body);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final cuentaState = ref.watch(cuentaControllerProvider);
    final cuentas = _cuentas(cuentaState);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar registro' : 'Nuevo registro'),
      ),
      body: CFResponsiveFormLayout(
        title: _isEdit ? 'Editar deuda o préstamo' : 'Nueva deuda o préstamo',
        subtitle: _isEdit
            ? 'Actualiza los datos de este compromiso.'
            : 'Registra un compromiso para mantenerlo bajo control.',
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_isEdit)
                CFFormSegmented<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'debo',
                      label: Text('Debo'),
                      icon: Icon(Icons.trending_down),
                    ),
                    ButtonSegment(
                      value: 'me_deben',
                      label: Text('Me deben'),
                      icon: Icon(Icons.trending_up),
                    ),
                  ],
                  selected: {_tipo},
                  onSelectionChanged: (v) => setState(() => _tipo = v.first),
                ),
              if (!_isEdit) const SizedBox(height: 16),
              _field(_nombreCtrl, 'Nombre', required: true),
              const SizedBox(height: 12),
              _field(_contraparteCtrl, 'Contraparte', required: true),
              const SizedBox(height: 12),
              _field(_descripcionCtrl, 'Descripcion'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _montoCtrl,
                enabled: !_isEdit,
                decoration: const InputDecoration(
                  labelText: 'Monto original',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  if (_isEdit) return null;
                  final n = double.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Monto invalido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
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
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _prioridad,
                decoration: const InputDecoration(
                  labelText: 'Prioridad',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'baja', child: Text('Baja')),
                  DropdownMenuItem(value: 'media', child: Text('Media')),
                  DropdownMenuItem(value: 'alta', child: Text('Alta')),
                  DropdownMenuItem(value: 'critica', child: Text('Critica')),
                ],
                onChanged: (v) => setState(() => _prioridad = v ?? 'media'),
              ),
              const SizedBox(height: 12),
              if (!_isEdit)
                _dateTile(
                  'Fecha inicio',
                  _fechaInicio,
                  () => _pickDate(proxima: false),
                ),
              if (!_isEdit) const SizedBox(height: 12),
              _dateTile(
                'Fecha proxima',
                _fechaProxima,
                () => _pickDate(proxima: true),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _montoProximoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Monto proximo',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 12),
              _field(_notasCtrl, 'Notas', maxLines: 3),
              const SizedBox(height: 24),
              CFButton(
                label: _isEdit ? 'Guardar cambios' : 'Crear registro',
                onPressed: _loading ? null : _submit,
                icon: Icons.save_outlined,
                loading: _loading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    bool required = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      maxLength: maxLines > 1 ? 500 : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: maxLines > 1
            ? 'Agrega información útil sobre este compromiso.'
            : null,
      ),
      validator: required
          ? (v) => v == null || v.trim().isEmpty ? 'Requerido' : null
          : null,
    );
  }

  Widget _dateTile(String label, DateTime? value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(value == null ? 'Sin fecha' : _fmt(value)),
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
