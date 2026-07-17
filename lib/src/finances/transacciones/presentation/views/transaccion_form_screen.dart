import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design_system/components/components.dart';
import '../../../../../core/design_system/tokens/theme_tokens.dart';
import '../app/riverpod/transaccion_controller.dart';
import '../app/riverpod/transaccion_state.dart';
import '../widgets/categoria_picker_widget.dart';
import '../../domain/entities/categoria.dart';
import '../../domain/entities/transaccion.dart';
import '../../../cuentas/domain/entities/cuenta.dart';
import '../../../cuentas/presentation/app/riverpod/cuenta_controller.dart';
import '../../../cuentas/presentation/app/riverpod/cuenta_state.dart';
import '../../../presupuestos/presentation/app/riverpod/presupuesto_controller.dart';
import '../../../presupuestos/presentation/app/riverpod/presupuesto_state.dart';

class TransaccionFormScreen extends ConsumerStatefulWidget {
  const TransaccionFormScreen({super.key});

  @override
  ConsumerState<TransaccionFormScreen> createState() =>
      _TransaccionFormScreenState();
}

class _TransaccionFormScreenState extends ConsumerState<TransaccionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  Transaccion? _editing;
  List<Categoria> _categorias = const [];

  // Form fields
  String _tipo = 'gasto';
  final _montoCtrl = TextEditingController();
  String _moneda = 'PEN';
  DateTime _fecha = DateTime.now();
  Categoria? _categoria;
  final _descripcionCtrl = TextEditingController();
  final _pagadoACtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  bool _esRecurrente = false;
  int? _cuentaId; // must be passed via arguments
  int? _cuentaDestinoId;

  bool _isLoading = false;
  bool _argsLoaded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final s = ref.read(cuentaControllerProvider);
      if (s is CuentaInitial) {
        ref.read(cuentaControllerProvider.notifier).loadCuentas();
      }
      // Si no se recibieron categorías vía args, cargarlas desde el controller
      final ts = ref.read(transaccionControllerProvider);
      if (ts is TransaccionInitial) {
        ref.read(transaccionControllerProvider.notifier).load().then((_) {
          _syncCategoriasFromController();
        });
      } else {
        _syncCategoriasFromController();
      }
    });
  }

  void _syncCategoriasFromController() {
    if (_categorias.isNotEmpty) return;
    final s = ref.read(transaccionControllerProvider);
    List<Categoria> cats = const [];
    if (s is TransaccionLoaded) cats = s.categorias;
    if (s is TransaccionOperationSuccess) cats = s.categorias;
    if (cats.isNotEmpty) setState(() => _categorias = cats);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsLoaded) return;
    _argsLoaded = true;
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _categorias = (args['categorias'] as List<Categoria>?) ?? [];
      final tx = args['transaccion'] as Transaccion?;
      _cuentaId = args['cuentaId'] as int?;
      if (tx != null) {
        _editing = tx;
        _tipo = tx.tipo;
        _montoCtrl.text = tx.monto.toStringAsFixed(2);
        _moneda = tx.moneda;
        _fecha = tx.fecha;
        _descripcionCtrl.text = tx.descripcion ?? '';
        _pagadoACtrl.text = tx.pagadoA ?? '';
        _notasCtrl.text = tx.notas ?? '';
        _esRecurrente = tx.esRecurrente;
        _cuentaId = tx.cuentaId;
        _cuentaDestinoId = tx.cuentaDestinoId;
        if (tx.categoriaId != null) {
          _categoria = _categorias
              .where((c) => c.id == tx.categoriaId)
              .firstOrNull;
        }
      }
    }
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    _descripcionCtrl.dispose();
    _pagadoACtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tipo == 'transferencia' && _cuentaDestinoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona la cuenta destino')),
      );
      return;
    }
    if (_tipo == 'transferencia' && _cuentaId == _cuentaDestinoId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La cuenta origen y destino no pueden ser la misma'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final notifier = ref.read(transaccionControllerProvider.notifier);
    bool ok;

    if (_editing == null) {
      ok = await notifier.createTransaccion(
        cuentaId: _cuentaId!,
        tipo: _tipo,
        monto: double.parse(_montoCtrl.text.trim()),
        moneda: _moneda,
        fecha: _fecha,
        categoriaId: _categoria?.id,
        cuentaDestinoId: _tipo == 'transferencia' ? _cuentaDestinoId : null,
        descripcion: _descripcionCtrl.text.trim().isEmpty
            ? null
            : _descripcionCtrl.text.trim(),
        pagadoA: _pagadoACtrl.text.trim().isEmpty
            ? null
            : _pagadoACtrl.text.trim(),
        notas: _notasCtrl.text.trim().isEmpty ? null : _notasCtrl.text.trim(),
        esRecurrente: _esRecurrente,
      );
    } else {
      ok = await notifier.updateTransaccion(
        id: _editing!.id,
        tipo: _tipo,
        monto: double.parse(_montoCtrl.text.trim()),
        moneda: _moneda,
        fecha: _fecha,
        categoriaId: _categoria?.id,
        descripcion: _descripcionCtrl.text.trim().isEmpty
            ? null
            : _descripcionCtrl.text.trim(),
        pagadoA: _pagadoACtrl.text.trim().isEmpty
            ? null
            : _pagadoACtrl.text.trim(),
        notas: _notasCtrl.text.trim().isEmpty ? null : _notasCtrl.text.trim(),
        esRecurrente: _esRecurrente,
      );
    }

    setState(() => _isLoading = false);
    if (ok && mounted) {
      // Check presupuesto alerts after a gasto transaction
      if (_tipo == 'gasto') {
        await _checkPresupuestosAlert();
      }
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  Future<void> _deleteEditingTransaction() async {
    final transaction = _editing;
    if (transaction == null || _isLoading) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar transacción'),
        content: const Text(
          'Esta acción eliminará el movimiento y revertirá su impacto financiero.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: CFColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);
    final deleted = await ref
        .read(transaccionControllerProvider.notifier)
        .deleteTransaccion(transaction.id);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (deleted) Navigator.of(context).pop(true);
  }

  Future<void> _checkPresupuestosAlert() async {
    await ref
        .read(presupuestoControllerProvider.notifier)
        .loadPresupuestos(mes: _fecha.month, anio: _fecha.year);
    if (!mounted) return;
    final state = ref.read(presupuestoControllerProvider);
    if (state is! PresupuestoLoaded) return;
    final alertas = state.presupuestos.where(
      (p) => p.estado == 'alerta' || p.estado == 'excedido',
    );
    for (final p in alertas) {
      if (!mounted) break;
      final label = p.esGlobal ? 'Presupuesto global' : p.categoriaNombre ?? '';
      final icon = p.estado == 'excedido' ? '🚨' : '⚠️';
      final msg = p.estado == 'excedido'
          ? '$icon $label: ¡Límite superado! (${p.porcentaje.toStringAsFixed(0)}%)'
          : '$icon $label: Alcanzaste el ${p.porcentaje.toStringAsFixed(0)}% del límite';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: p.estado == 'excedido'
              ? CFColors.danger
              : CFColors.warning,
          duration: const Duration(seconds: 4),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _fecha = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _editing != null;
    final filteredCats = _categorias.where((c) {
      if (_tipo == 'transferencia') return false;
      return c.tipo == _tipo || c.tipo == 'ambos';
    }).toList();

    // Watch cuentas for the dropdowns
    final cuentaState = ref.watch(cuentaControllerProvider);
    List<Cuenta> cuentas = const [];
    if (cuentaState is CuentaLoaded) cuentas = cuentaState.cuentas;
    if (cuentaState is CuentaOperationSuccess) cuentas = cuentaState.cuentas;
    if (cuentaState is CuentaError) cuentas = cuentaState.previousCuentas;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar transacción' : 'Nueva transacción'),
      ),
      body: CFResponsiveFormLayout(
        title: isEdit ? 'Editar transacción' : 'Nueva transacción',
        subtitle: isEdit
            ? 'Actualiza la información de este movimiento financiero.'
            : 'Registra un nuevo movimiento financiero.',
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tipo selector
              CFFormSegmented<String>(
                segments: const [
                  ButtonSegment(value: 'gasto', label: Text('Gasto')),
                  ButtonSegment(value: 'ingreso', label: Text('Ingreso')),
                  ButtonSegment(value: 'transferencia', label: Text('Transf.')),
                ],
                selected: {_tipo},
                onSelectionChanged: (values) {
                  setState(() {
                    _tipo = values.first;
                    _categoria = null;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Cuenta origen
              DropdownButtonFormField<int>(
                isExpanded: true,
                value: _cuentaId,
                decoration: InputDecoration(
                  labelText: _tipo == 'transferencia'
                      ? 'Cuenta origen *'
                      : _tipo == 'ingreso'
                      ? 'Cuenta que recibe *'
                      : 'Cuenta que paga *',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.account_balance_wallet),
                ),
                items: cuentas
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.nombre, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() {
                  _cuentaId = v;
                  // Reset destino if same account selected
                  if (_cuentaDestinoId == v) _cuentaDestinoId = null;
                }),
                validator: (v) => v == null ? 'Selecciona una cuenta' : null,
              ),
              const SizedBox(height: 16),

              // Cuenta destino (solo transferencia)
              if (_tipo == 'transferencia')
                ...([
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    value: _cuentaDestinoId,
                    decoration: const InputDecoration(
                      labelText: 'Cuenta destino *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.account_balance),
                    ),
                    items: cuentas
                        .where((c) => c.id != _cuentaId)
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(
                              c.nombre,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _cuentaDestinoId = v),
                    validator: (v) => _tipo == 'transferencia' && v == null
                        ? 'Selecciona cuenta destino'
                        : null,
                  ),
                  const SizedBox(height: 16),
                ]),

              // Monto + Moneda
              CFResponsiveFormRow(
                children: [
                  TextFormField(
                    controller: _montoCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Monto *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requerido';
                      final n = double.tryParse(v);
                      if (n == null || n <= 0) return 'Monto inválido';
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _moneda,
                    decoration: const InputDecoration(
                      labelText: 'Moneda',
                      border: OutlineInputBorder(),
                    ),
                    items: ['PEN', 'USD', 'EUR']
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) => setState(() => _moneda = v!),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Fecha
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_fecha.year}-${_fecha.month.toString().padLeft(2, '0')}-${_fecha.day.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Categoría (solo para gasto/ingreso)
              if (_tipo != 'transferencia')
                InkWell(
                  onTap: () async {
                    final picked = await CategoriaPickerWidget.show(
                      context,
                      categorias: filteredCats,
                      selectedId: _categoria?.id,
                    );
                    if (picked != null) setState(() => _categoria = picked);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.label_outline),
                    ),
                    child: Text(
                      _categoria?.nombre ?? 'Sin categoría',
                      style: TextStyle(
                        color: _categoria == null ? CFColors.textMuted : null,
                      ),
                    ),
                  ),
                ),
              if (_tipo != 'transferencia') const SizedBox(height: 16),

              // Descripcion
              TextFormField(
                controller: _descripcionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLength: 200,
              ),
              const SizedBox(height: 8),

              // Pagado a / Recibido de
              if (_tipo != 'transferencia')
                TextFormField(
                  controller: _pagadoACtrl,
                  decoration: InputDecoration(
                    labelText: _tipo == 'ingreso' ? 'Recibido de' : 'Pagado a',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  maxLength: 200,
                ),
              if (_tipo != 'transferencia') const SizedBox(height: 8),

              // Notas
              TextFormField(
                controller: _notasCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notas adicionales',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                maxLength: 500,
              ),
              const SizedBox(height: 8),

              // Recurrente
              CFFormSwitchCard(
                title: 'Transacción recurrente',
                subtitle: 'Se mantendrá identificada para su seguimiento.',
                value: _esRecurrente,
                onChanged: (v) => setState(() => _esRecurrente = v),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: CFButton(
                  label: isEdit ? 'Guardar cambios' : 'Crear transacción',
                  onPressed: _isLoading ? null : _submit,
                  loading: _isLoading,
                ),
              ),
              if (isEdit) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: CFOutlinedButton(
                    label: 'Eliminar transacción',
                    onPressed: _isLoading ? null : _deleteEditingTransaction,
                    tone: CFButtonTone.danger,
                    icon: Icons.delete_outline,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
