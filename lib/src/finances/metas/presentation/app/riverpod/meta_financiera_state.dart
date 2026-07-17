import '../../../domain/entities/aporte_meta.dart';
import '../../../domain/entities/meta_financiera.dart';
import '../../../domain/entities/meta_financiera_resumen.dart';

abstract class MetaFinancieraState {
  const MetaFinancieraState();
}

class MetaFinancieraInitial extends MetaFinancieraState {
  const MetaFinancieraInitial();
}

class MetaFinancieraLoading extends MetaFinancieraState {
  const MetaFinancieraLoading();
}

class MetaFinancieraLoaded extends MetaFinancieraState {
  final List<MetaFinanciera> items;
  final MetaFinancieraResumen? resumen;
  final MetaFinanciera? selected;
  final List<AporteMeta> aportes;

  const MetaFinancieraLoaded({
    required this.items,
    this.resumen,
    this.selected,
    this.aportes = const [],
  });
}

class MetaFinancieraError extends MetaFinancieraState {
  final String message;
  final List<MetaFinanciera> previousItems;
  final MetaFinancieraResumen? previousResumen;

  const MetaFinancieraError(
    this.message, {
    this.previousItems = const [],
    this.previousResumen,
  });
}
