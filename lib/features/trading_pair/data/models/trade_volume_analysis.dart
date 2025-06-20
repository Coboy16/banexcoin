class TradeVolumeAnalysis {
  final double buyVolume;
  final double sellVolume;
  final double totalVolume;
  final int buyCount;
  final int sellCount;
  final double buyPressure; // 0.0 - 1.0
  final double sellPressure; // 0.0 - 1.0
  final int totalTrades;
  final Duration analysisWindow;

  TradeVolumeAnalysis({
    required this.buyVolume,
    required this.sellVolume,
    required this.totalVolume,
    required this.buyCount,
    required this.sellCount,
    required this.buyPressure,
    required this.sellPressure,
    required this.totalTrades,
    required this.analysisWindow,
  });

  /// Determina el sentimiento del mercado
  String get marketSentiment {
    if (buyPressure >= 0.65) return 'Alcista';
    if (sellPressure >= 0.65) return 'Bajista';
    return 'Neutral';
  }

  /// Obtiene descripción del análisis
  String get summary {
    return 'Presión de compra: ${(buyPressure * 100).toStringAsFixed(1)}% | '
        'Trades: $totalTrades | '
        'Volumen: \${totalVolume.toStringAsFixed(0)}';
  }
}
