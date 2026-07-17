import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/design_system/components/components.dart';
import '../../../cuentas/domain/entities/cuenta.dart';
import '../../../cuentas/presentation/app/riverpod/cuenta_controller.dart';
import '../../../cuentas/presentation/app/riverpod/cuenta_state.dart';
import '../../domain/entities/meta_financiera.dart';
import '../app/riverpod/meta_financiera_controller.dart';

class MetaFinancieraFormScreen extends ConsumerStatefulWidget {
  final MetaFinanciera? item;
  const MetaFinancieraFormScreen({super.key, this.item});

  @override
  ConsumerState<MetaFinancieraFormScreen> createState() =>
      _MetaFinancieraFormScreenState();
}

class _MetaFinancieraFormScreenState
    extends ConsumerState<MetaFinancieraFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();
  final _montoInicialCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  late String _prioridad;
  late DateTime _fechaInicio;
  DateTime? _fechaObjetivo;
  int? _cuentaId;
  bool _loading = false;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _prioridad = item?.prioridad ?? 'media';
    _fechaInicio = item?.fechaInicio ?? DateTime.now();
    _fechaObjetivo = item?.fechaObjetivo;
    _cuentaId = item?.cuentaId;
    _nombreCtrl.text = item?.nombre ?? '';
    _descripcionCtrl.text = item?.descripcion ?? '';
    _montoCtrl.text = item?.montoObjetivo.toStringAsFixed(2) ?? '';
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
    _descripcionCtrl.dispose();
    _montoCtrl.dispose();
    _montoInicialCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool objetivo}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: objetivo ? (_fechaObjetivo ?? DateTime.now()) : _fechaInicio,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (objetivo) {
        _fechaObjetivo = picked;
      } else {
        _fechaInicio = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final body = <String, dynamic>{
      'nombre': _nombreCtrl.text.trim(),
      if (_descripcionCtrl.text.trim().isNotEmpty)
        'descripcion': _descripcionCtrl.text.trim(),
      'monto_objetivo': double.parse(_montoCtrl.text.trim()),
      if (!_isEdit && _montoInicialCtrl.text.trim().isNotEmpty)
        'monto_actual': double.parse(_montoInicialCtrl.text.trim()),
      if (!_isEdit) 'fecha_inicio': _date(_fechaInicio),
      if (_fechaObjetivo != null) 'fecha_objetivo': _date(_fechaObjetivo!),
      'prioridad': _prioridad,
      if (_cuentaId != null) 'cuenta_id': _cuentaId,
      if (_notasCtrl.text.trim().isNotEmpty) 'notas': _notasCtrl.text.trim(),
    };
    final controller = ref.read(metaFinancieraControllerProvider.notifier);
    final ok = _isEdit
        ? await controller.update(widget.item!.id, body)
        : await controller.create(body);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final cuentas = _cuentas(ref.watch(cuentaControllerProvider));
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Editar meta' : 'Nueva meta')),
      body: CFResponsiveFormLayout(
        title: _isEdit ? 'Editar meta' : 'Nueva meta',
        subtitle: _isEdit
            ? 'Actualiza el objetivo y los detalles de esta meta.'
            : 'Dale dirección a tu dinero con un objetivo claro.',
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _field(_nombreCtrl, 'Nombre', required: true),
              const SizedBox(height: 12),
              _field(_descripcionCtrl, 'Descripcion'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _montoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Monto objetivo',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Monto invalido';
                  if (_isEdit && n < widget.item!.montoActual) {
                    return 'No puede ser menor al monto actual';
                  }
                  return null;
                },
              ),
              if (!_isEdit) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _montoInicialCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Monto inicial opcional',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final inicial = double.tryParse(v);
                    final objetivo = double.tryParse(_montoCtrl.text);
                    if (inicial == null || inicial < 0) return 'Monto invalido';
                    if (objetivo != null && inicial > objetivo) {
                      return 'No puede superar el objetivo';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                isExpanded: true,
                value: _cuentaId,
                decoration: const InputDecoration(
                  labelText: 'Cuenta sugerida',
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
                ],
                onChanged: (v) => setState(() => _prioridad = v ?? 'media'),
              ),
              const SizedBox(height: 12),
              if (!_isEdit)
                _dateTile(
                  'Fecha inicio',
                  _fechaInicio,
                  () => _pickDate(objetivo: false),
                ),
              if (!_isEdit) const SizedBox(height: 12),
              _dateTile(
                'Fecha objetivo',
                _fechaObjetivo,
                () => _pickDate(objetivo: true),
              ),
              const SizedBox(height: 12),
              _field(_notasCtrl, 'Notas', maxLines: 3),
              const SizedBox(height: 24),
              CFButton(
                label: _isEdit ? 'Guardar cambios' : 'Crear meta',
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
            ? 'Agrega detalles útiles para esta meta.'
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
      child: InputDecorator(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ).copyWith(labelText: label),
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
