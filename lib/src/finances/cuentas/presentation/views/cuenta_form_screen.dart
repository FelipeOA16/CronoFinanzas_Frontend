import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design_system/components/components.dart';
import '../../domain/entities/cuenta.dart';
import '../app/riverpod/cuenta_controller.dart';
import '../widgets/cuenta_card.dart' show hexToColor;

const _tipos = [
  ('banco', 'Banco'),
  ('efectivo', 'Efectivo'),
  ('tarjeta_credito', 'Tarjeta crédito'),
  ('tarjeta_debito', 'Tarjeta débito'),
  ('inversion', 'Inversión'),
  ('cripto', 'Cripto'),
  ('otro', 'Otro'),
];

const _presetColors = [
  '#1A73E8',
  '#34A853',
  '#FBBC05',
  '#EA4335',
  '#9C27B0',
  '#FF5722',
  '#00ACC1',
  '#607D8B',
];

class CuentaFormScreen extends ConsumerStatefulWidget {
  final Cuenta? cuenta;

  const CuentaFormScreen({super.key, this.cuenta});

  @override
  ConsumerState<CuentaFormScreen> createState() => _CuentaFormScreenState();
}

class _CuentaFormScreenState extends ConsumerState<CuentaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _saldoCtrl;
  late final TextEditingController _institucionCtrl;
  late final TextEditingController _notasCtrl;
  late final TextEditingController _monedaCtrl;

  String _tipo = 'banco';
  String? _colorHex;
  bool _incluirEnTotal = true;
  bool _saving = false;

  bool get _isEditing => widget.cuenta != null;

  @override
  void initState() {
    super.initState();
    final c = widget.cuenta;
    _nombreCtrl = TextEditingController(text: c?.nombre ?? '');
    _saldoCtrl = TextEditingController(
      text: c == null ? '' : c.saldoInicial.toStringAsFixed(2),
    );
    _institucionCtrl = TextEditingController(text: c?.institucion ?? '');
    _notasCtrl = TextEditingController(text: c?.notas ?? '');
    _monedaCtrl = TextEditingController(text: c?.moneda ?? 'PEN');
    _tipo = c?.tipo ?? 'banco';
    _colorHex = c?.color ?? _presetColors[0];
    _incluirEnTotal = c?.incluirEnTotal ?? true;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _saldoCtrl.dispose();
    _institucionCtrl.dispose();
    _notasCtrl.dispose();
    _monedaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar cuenta' : 'Nueva cuenta'),
        centerTitle: true,
      ),
      body: CFResponsiveFormLayout(
        title: _isEditing ? 'Editar cuenta' : 'Nueva cuenta',
        subtitle: _isEditing
            ? 'Actualiza la información de esta cuenta.'
            : 'Agrega una cuenta para organizar tu dinero.',
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la cuenta *',
                  hintText: 'Ej: BCP Ahorros, Billetera',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Tipo
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _tipo,
                decoration: const InputDecoration(
                  labelText: 'Tipo de cuenta *',
                  border: OutlineInputBorder(),
                ),
                items: _tipos
                    .map(
                      (t) => DropdownMenuItem(value: t.$1, child: Text(t.$2)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _tipo = v!),
              ),
              const SizedBox(height: 16),

              // Moneda + Saldo inicial (row)
              CFResponsiveFormRow(
                children: [
                  TextFormField(
                    controller: _monedaCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Moneda',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 5,
                    buildCounter:
                        (
                          _, {
                          required int currentLength,
                          required bool isFocused,
                          required int? maxLength,
                        }) => null,
                  ),
                  TextFormField(
                    controller: _saldoCtrl,
                    enabled: !_isEditing,
                    decoration: InputDecoration(
                      labelText: _isEditing
                          ? 'Saldo inicial (no editable)'
                          : 'Saldo inicial *',
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _isEditing
                        ? null
                        : (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Requerido';
                            }
                            if (double.tryParse(v.trim()) == null) {
                              return 'Número inválido';
                            }
                            return null;
                          },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Institución
              TextFormField(
                controller: _institucionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Institución (opcional)',
                  hintText: 'Ej: BCP, Interbank, Binance',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Color
              Text('Color', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 10),
              _buildColorPicker(),
              const SizedBox(height: 20),

              // Incluir en total
              CFFormSwitchCard(
                value: _incluirEnTotal,
                onChanged: (v) => setState(() => _incluirEnTotal = v),
                title: 'Incluir en patrimonio total',
                subtitle: 'Desactiva esta opción para tarjetas de crédito.',
              ),
              const SizedBox(height: 8),

              // Notas
              TextFormField(
                controller: _notasCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  hintText: 'Agrega un detalle que te ayude a identificarla.',
                ),
                maxLines: 3,
                maxLength: 500,
              ),
              const SizedBox(height: 28),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: CFButton(
                  label: _isEditing ? 'Guardar cambios' : 'Crear cuenta',
                  onPressed: _saving ? null : _submit,
                  loading: _saving,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _presetColors.map((hex) {
        final selected = _colorHex == hex;
        return GestureDetector(
          onTap: () => setState(() => _colorHex = hex),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: hexToColor(hex),
              shape: BoxShape.circle,
              border: selected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.onSurface,
                      width: 3,
                    )
                  : null,
            ),
            child: selected
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final controller = ref.read(cuentaControllerProvider.notifier);
    bool ok;

    if (_isEditing) {
      ok = await controller.updateCuenta(
        id: widget.cuenta!.id,
        nombre: _nombreCtrl.text.trim(),
        tipo: _tipo,
        moneda: _monedaCtrl.text.trim().toUpperCase(),
        color: _colorHex,
        institucion: _institucionCtrl.text.trim().isEmpty
            ? null
            : _institucionCtrl.text.trim(),
        incluirEnTotal: _incluirEnTotal,
        notas: _notasCtrl.text.trim().isEmpty ? null : _notasCtrl.text.trim(),
      );
    } else {
      ok = await controller.createCuenta(
        nombre: _nombreCtrl.text.trim(),
        tipo: _tipo,
        moneda: _monedaCtrl.text.trim().toUpperCase(),
        saldoInicial: double.parse(_saldoCtrl.text.trim()),
        color: _colorHex,
        institucion: _institucionCtrl.text.trim().isEmpty
            ? null
            : _institucionCtrl.text.trim(),
        incluirEnTotal: _incluirEnTotal,
        notas: _notasCtrl.text.trim().isEmpty ? null : _notasCtrl.text.trim(),
      );
    }

    setState(() => _saving = false);
    if (ok && mounted) Navigator.of(context).pop();
  }
}
