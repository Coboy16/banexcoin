import '/features/features.dart';

class MarketStatistics {
  final double totalMarketCap;
  final double total24hVolume;
  final int totalTradingPairs;
  final int gainersCount;
  final int losersCount;
  final int stableCount;
  final DateTime lastUpdated;

  MarketStatistics({
    required this.totalMarketCap,
    required this.total24hVolume,
    required this.totalTradingPairs,
    required this.gainersCount,
    required this.losersCount,
    required this.stableCount,
    required this.lastUpdated,
  });

  /// Porcentaje de pares que subieron
  double get gainersPercent =>
      totalTradingPairs > 0 ? (gainersCount / totalTradingPairs) * 100 : 0;

  /// Porcentaje de pares que bajaron
  double get losersPercent =>
      totalTradingPairs > 0 ? (losersCount / totalTradingPairs) * 100 : 0;

  /// Sentimiento general del mercado
  MarketSentiment get sentiment {
    if (gainersCount > losersCount * 1.5) {
      return MarketSentiment.bullish;
    } else if (losersCount > gainersCount * 1.5) {
      return MarketSentiment.bearish;
    } else {
      return MarketSentiment.neutral;
    }
  }
}
