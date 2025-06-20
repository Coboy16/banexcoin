class SymbolInfoTraiding {
  final String symbol;
  final String baseAsset;
  final String quoteAsset;
  final String status;
  final int baseAssetPrecision;
  final int quoteAssetPrecision;
  final bool isActive;

  SymbolInfoTraiding({
    required this.symbol,
    required this.baseAsset,
    required this.quoteAsset,
    required this.status,
    required this.baseAssetPrecision,
    required this.quoteAssetPrecision,
    required this.isActive,
  });

  /// Descripción formateada del símbolo
  String get description => '$baseAsset / $quoteAsset';

  /// Precisión de decimales para el precio
  int get priceDecimalPlaces => quoteAssetPrecision;

  /// Precisión de decimales para la cantidad
  int get quantityDecimalPlaces => baseAssetPrecision;
}
