import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'exchange_info_model.g.dart';

@JsonSerializable()
class ExchangeInfoModel extends Equatable {
  const ExchangeInfoModel({
    required this.timezone,
    required this.serverTime,
    required this.symbols,
  });

  final String timezone; // Zona horaria del servidor
  final int serverTime; // Timestamp del servidor
  final List<SymbolInfoModel> symbols; // Lista de símbolos disponibles

  factory ExchangeInfoModel.fromJson(Map<String, dynamic> json) =>
      _$ExchangeInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExchangeInfoModelToJson(this);

  @override
  List<Object?> get props => [timezone, serverTime, symbols];

  /// Busca información de un símbolo específico
  SymbolInfoModel? getSymbolInfo(String symbol) {
    try {
      return symbols.firstWhere(
        (s) => s.symbol.toUpperCase() == symbol.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Obtiene todos los símbolos activos
  List<SymbolInfoModel> get activeSymbols =>
      symbols.where((s) => s.status == 'TRADING').toList();
}

/// Modelo para información de un símbolo específico
@JsonSerializable()
class SymbolInfoModel extends Equatable {
  const SymbolInfoModel({
    required this.symbol,
    required this.status,
    required this.baseAsset,
    required this.baseAssetPrecision,
    required this.quoteAsset,
    required this.quotePrecision,
    required this.quoteAssetPrecision,
    required this.filters,
  });

  final String symbol; // Nombre del símbolo (ej: BTCUSDT)
  final String status; // Estado (TRADING, HALT, etc.)
  final String baseAsset; // Activo base (ej: BTC)
  final int baseAssetPrecision; // Precisión del activo base
  final String quoteAsset; // Activo cotizado (ej: USDT)
  final int quotePrecision; // Precisión de cotización
  final int quoteAssetPrecision; // Precisión del activo cotizado
  final List<FilterModel> filters; // Filtros de trading

  factory SymbolInfoModel.fromJson(Map<String, dynamic> json) =>
      _$SymbolInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$SymbolInfoModelToJson(this);

  @override
  List<Object?> get props => [
    symbol,
    status,
    baseAsset,
    baseAssetPrecision,
    quoteAsset,
    quotePrecision,
    quoteAssetPrecision,
    filters,
  ];

  /// Verifica si el símbolo está disponible para trading
  bool get isTrading => status == 'TRADING';

  /// Obtiene el filtro de precio si existe
  FilterModel? get priceFilter => filters.cast<FilterModel?>().firstWhere(
    (f) => f?.filterType == 'PRICE_FILTER',
    orElse: () => null,
  );

  /// Obtiene la precisión decimal apropiada para el precio
  int get priceDecimalPlaces {
    final filter = priceFilter;
    if (filter != null && filter.tickSize != null) {
      final tickSize = double.tryParse(filter.tickSize!) ?? 0.01;
      return tickSize >= 1 ? 0 : tickSize.toString().split('.')[1].length;
    }
    return quotePrecision;
  }
}

/// Modelo para filtros de trading
@JsonSerializable()
class FilterModel extends Equatable {
  const FilterModel({
    required this.filterType,
    this.minPrice,
    this.maxPrice,
    this.tickSize,
    this.minQty,
    this.maxQty,
    this.stepSize,
  });

  final String filterType; // Tipo de filtro
  final String? minPrice; // Precio mínimo
  final String? maxPrice; // Precio máximo
  final String? tickSize; // Incremento de precio
  final String? minQty; // Cantidad mínima
  final String? maxQty; // Cantidad máxima
  final String? stepSize; // Incremento de cantidad

  factory FilterModel.fromJson(Map<String, dynamic> json) =>
      _$FilterModelFromJson(json);

  Map<String, dynamic> toJson() => _$FilterModelToJson(this);

  @override
  List<Object?> get props => [
    filterType,
    minPrice,
    maxPrice,
    tickSize,
    minQty,
    maxQty,
    stepSize,
  ];
}
