import '/features/features.dart';

class DepthAnalysis {
  final DepthEntity depth;
  final double? spread;
  final double? spreadPercent;
  final double totalBidVolume;
  final double totalAskVolume;
  final double weightedMidPrice;
  final LiquidityQuality liquidityQuality;

  DepthAnalysis({
    required this.depth,
    required this.spread,
    required this.spreadPercent,
    required this.totalBidVolume,
    required this.totalAskVolume,
    required this.weightedMidPrice,
    required this.liquidityQuality,
  });

  factory DepthAnalysis.fromDepth(DepthEntity depth) {
    // Calcular volúmenes totales
    final totalBidVolume = depth.bids.fold<double>(
      0.0,
      (sum, bid) => sum + bid.totalValue,
    );

    final totalAskVolume = depth.asks.fold<double>(
      0.0,
      (sum, ask) => sum + ask.totalValue,
    );

    // Calcular precio medio ponderado
    double weightedMidPrice = 0.0;
    if (depth.bestBidPrice != null && depth.bestAskPrice != null) {
      weightedMidPrice = (depth.bestBidPrice! + depth.bestAskPrice!) / 2;
    }

    // Determinar calidad de liquidez
    final liquidityQuality = _determineLiquidityQuality(
      spread: depth.spreadPercent,
      bidVolume: totalBidVolume,
      askVolume: totalAskVolume,
      bidLevels: depth.bids.length,
      askLevels: depth.asks.length,
    );

    return DepthAnalysis(
      depth: depth,
      spread: depth.spread,
      spreadPercent: depth.spreadPercent,
      totalBidVolume: totalBidVolume,
      totalAskVolume: totalAskVolume,
      weightedMidPrice: weightedMidPrice,
      liquidityQuality: liquidityQuality,
    );
  }

  /// Determina la calidad de liquidez basada en métricas
  static LiquidityQuality _determineLiquidityQuality({
    double? spread,
    required double bidVolume,
    required double askVolume,
    required int bidLevels,
    required int askLevels,
  }) {
    // Factores para determinar calidad
    int qualityScore = 0;

    // Factor 1: Spread (30% del score)
    if (spread != null) {
      if (spread < 0.1) {
        qualityScore += 30;
      } else if (spread < 0.5)
        // ignore: curly_braces_in_flow_control_structures
        qualityScore += 20;
      else if (spread < 1.0)
        // ignore: curly_braces_in_flow_control_structures
        qualityScore += 10;
    }

    // Factor 2: Volumen (40% del score)
    final totalVolume = bidVolume + askVolume;
    if (totalVolume > 1000000) {
      qualityScore += 40;
    } else if (totalVolume > 500000)
      // ignore: curly_braces_in_flow_control_structures
      qualityScore += 30;
    else if (totalVolume > 100000)
      // ignore: curly_braces_in_flow_control_structures
      qualityScore += 20;
    else if (totalVolume > 50000)
      // ignore: curly_braces_in_flow_control_structures
      qualityScore += 10;

    // Factor 3: Balance entre bid y ask (15% del score)
    final volumeRatio =
        bidVolume / (askVolume + 0.0001); // Evitar división por 0
    if (volumeRatio >= 0.8 && volumeRatio <= 1.2) {
      qualityScore += 15;
    } else if (volumeRatio >= 0.6 && volumeRatio <= 1.4)
      // ignore: curly_braces_in_flow_control_structures
      qualityScore += 10;
    else if (volumeRatio >= 0.4 && volumeRatio <= 1.6)
      // ignore: curly_braces_in_flow_control_structures
      qualityScore += 5;

    // Factor 4: Profundidad (15% del score)
    final totalLevels = bidLevels + askLevels;
    if (totalLevels >= 40) {
      qualityScore += 15;
    } else if (totalLevels >= 30)
      // ignore: curly_braces_in_flow_control_structures
      qualityScore += 10;
    else if (totalLevels >= 20)
      // ignore: curly_braces_in_flow_control_structures
      qualityScore += 5;

    // Determinar calidad final
    if (qualityScore >= 80) return LiquidityQuality.excellent;
    if (qualityScore >= 60) return LiquidityQuality.good;
    if (qualityScore >= 40) return LiquidityQuality.fair;
    return LiquidityQuality.poor;
  }

  /// Obtiene resumen textual del análisis
  String get summary {
    final spreadText = spreadPercent != null
        ? '${spreadPercent!.toStringAsFixed(3)}%'
        : 'N/A';

    return 'Spread: $spreadText | '
        'Liquidez: ${liquidityQuality.name} | '
        'Vol. Total: \${(totalBidVolume + totalAskVolume).toStringAsFixed(0)}';
  }
}
