class SymbolInfo {
  final String symbol;
  final String baseAsset;
  final String quoteAsset;
  final bool isActive;
  final int priceDecimalPlaces;
  final int quantityDecimalPlaces;

  SymbolInfo({
    required this.symbol,
    required this.baseAsset,
    required this.quoteAsset,
    required this.isActive,
    required this.priceDecimalPlaces,
    required this.quantityDecimalPlaces,
  });
}
