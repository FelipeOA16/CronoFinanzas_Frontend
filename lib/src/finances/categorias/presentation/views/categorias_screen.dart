import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design_system/components/components.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../finances/transacciones/domain/entities/categoria.dart';
import '../app/riverpod/categoria_controller.dart';
import '../app/riverpod/categoria_state.dart';
import '../widgets/categoria_detail_sheet.dart';
import '../widgets/categoria_form_sheet.dart';

class CategoriasScreen extends ConsumerStatefulWidget {
  const CategoriasScreen({super.key});

  @override
  ConsumerState<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends ConsumerState<CategoriasScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(categoriaControllerProvider.notifier).loadCategorias(),
    );
  }

  Future<void> _refresh() async {
    await ref.read(categoriaControllerProvider.notifier).loadCategorias();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoriaControllerProvider);
    final showExtendedFab = MediaQuery.sizeOf(context).width >= 840;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Categorías',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          if (!showExtendedFab)
            IconButton(
              icon: const Icon(Icons.add, color: AppColors.primary),
              tooltip: 'Agregar',
              onPressed: () => CategoriaFormSheet.show(context),
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _refresh,
          ),
        ],
      ),
      body: switch (state) {
        CategoriaLoading() => const Center(child: CircularProgressIndicator()),
        CategoriaError(message: final m) => _ErrorView(
          message: m,
          onRetry: _refresh,
        ),
        CategoriaLoaded(categorias: final cats) => _CategoriasBody(
          categorias: cats,
          onRefresh: _refresh,
        ),
        _ => const SizedBox.shrink(),
      },
      floatingActionButton: CFExtendedFab(
        visible: showExtendedFab,
        onPressed: () => CategoriaFormSheet.show(context),
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _CategoriasBody extends ConsumerWidget {
  final List<Categoria> categorias;
  final Future<void> Function() onRefresh;

  const _CategoriasBody({required this.categorias, required this.onRefresh});

  Map<String, List<Categoria>> _agrupar(List<Categoria> cats) {
    final Map<String, List<Categoria>> grupos = {
      'gasto': [],
      'ingreso': [],
      'ambos': [],
    };
    for (final c in cats) {
      grupos.putIfAbsent(c.tipo, () => []).add(c);
    }
    return grupos;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (categorias.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CFEmptyState(
              title: 'Sin categorías',
              message: 'Crea una categoría para organizar tus movimientos.',
            ),
            CFButton(
              label: 'Crear categoría',
              onPressed: () => CategoriaFormSheet.show(context),
              icon: Icons.add,
            ),
          ],
        ),
      );
    }

    final grupos = _agrupar(categorias);
    final tiposOrden = ['gasto', 'ingreso', 'ambos'];

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          for (final tipo in tiposOrden)
            if (grupos[tipo]!.isNotEmpty)
              _GrupoTipo(tipo: tipo, categorias: grupos[tipo]!, ref: ref),
        ],
      ),
    );
  }
}

class _GrupoTipo extends StatelessWidget {
  final String tipo;
  final List<Categoria> categorias;
  final WidgetRef ref;

  const _GrupoTipo({
    required this.tipo,
    required this.categorias,
    required this.ref,
  });

  String get _label => switch (tipo) {
    'gasto' => 'Gastos',
    'ingreso' => 'Ingresos',
    'ambos' => 'Ambos',
    _ => tipo,
  };

  Color get _labelColor => switch (tipo) {
    'gasto' => AppColors.gasto,
    'ingreso' => AppColors.ingreso,
    _ => AppColors.primary,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 4),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: _labelColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _label,
                style: TextStyle(
                  color: _labelColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categorias.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 64),
            itemBuilder: (context, i) =>
                _CategoriaRow(cat: categorias[i], ref: ref),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _CategoriaRow extends StatelessWidget {
  final Categoria cat;
  final WidgetRef ref;

  const _CategoriaRow({required this.cat, required this.ref});

  Color _hex(String? hex) {
    if (hex == null) return AppColors.primary;
    final clean = hex.replaceAll('#', '');
    return Color(int.tryParse('FF$clean', radix: 16) ?? 0xFF4F46E5);
  }

  static const _iconMap = <String, IconData>{
    'restaurant': Icons.restaurant,
    'directions_car': Icons.directions_car,
    'home': Icons.home,
    'local_hospital': Icons.local_hospital,
    'movie': Icons.movie,
    'checkroom': Icons.checkroom,
    'school': Icons.school,
    'work': Icons.work,
    'laptop': Icons.laptop,
    'trending_up': Icons.trending_up,
    'card_giftcard': Icons.card_giftcard,
    'category': Icons.category,
    'sports_esports': Icons.sports_esports,
    'fitness_center': Icons.fitness_center,
    'flight': Icons.flight,
    'shopping_cart': Icons.shopping_cart,
    'local_cafe': Icons.local_cafe,
    'pets': Icons.pets,
    'attach_money': Icons.attach_money,
    'savings': Icons.savings,
  };

  IconData _parseIcon(String? name) => _iconMap[name ?? ''] ?? Icons.category;

  Future<void> _delete(BuildContext context, Categoria cat) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content: Text(
          '¿Eliminar "${cat.nombre}"? Esta acción eliminará también sus subcategorías.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.gasto),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref
          .read(categoriaControllerProvider.notifier)
          .deleteCategoria(cat.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _hex(cat.color);
    final conteo = cat.hijas.length;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => CategoriaDetailSheet.show(context, cat),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Icono
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_parseIcon(cat.icono), color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),

            // Nombre + subtítulo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat.nombre,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  if (cat.esSistema)
                    const Text(
                      'Sistema',
                      style: TextStyle(color: AppColors.textHint, fontSize: 12),
                    )
                  else
                    const Text(
                      'Personal',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),

            // Badge subcategorías
            if (conteo > 0)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$conteo',
                  style: TextStyle(
                    color: iconColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),

            // Acciones (solo categorías del usuario)
            if (!cat.esSistema) ...[
              SizedBox(
                width: 44,
                height: 44,
                child: PopupMenuButton<String>(
                  tooltip: 'Acciones de categoría',
                  onSelected: (value) {
                    if (value == 'edit') {
                      CategoriaFormSheet.show(context, categoria: cat);
                    }
                    if (value == 'delete') _delete(context, cat);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Editar')),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Eliminar',
                        style: TextStyle(color: AppColors.gasto),
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

// ─── Error view ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.gasto),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            CFButton(
              label: 'Reintentar',
              onPressed: onRetry,
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }
}
