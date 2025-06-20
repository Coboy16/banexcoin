import 'package:equatable/equatable.dart';

class PriceStatsEntity extends Equatable {
  const PriceStatsEntity({
    required this.symbol,
    required this.currentPrice,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.priceChange,
    required this.priceChangePercent,
    required this.volume,
    required this.quoteVolume,
    required this.lastUpdateTime,
  });

  final String symbol;
  final double currentPrice;
  final double openPrice;
  final double highPrice;
  final double lowPrice;
  final double priceChange;
  final double priceChangePercent;
  final double volume;
  final double quoteVolume;
  final DateTime lastUpdateTime;

  /// Determina si el cambio es positivo
  bool get isPriceChangePositive => priceChange >= 0;

  /// Calcula el rango de precio del día
  double get dayRange => highPrice - lowPrice;

  /// Calcula la posición actual en el rango del día (0-1)
  double get pricePositionInRange {
    if (dayRange == 0) return 0.5;
    return (currentPrice - lowPrice) / dayRange;
  }

  /// Determina la tendencia basada en la posición en el rango
  PriceTrend get trend {
    final position = pricePositionInRange;
    if (position >= 0.7) return PriceTrend.bullish;
    if (position <= 0.3) return PriceTrend.bearish;
    return PriceTrend.neutral;
  }

  @override
  List<Object?> get props => [
    symbol,
    currentPrice,
    openPrice,
    highPrice,
    lowPrice,
    priceChange,
    priceChangePercent,
    volume,
    quoteVolume,
    lastUpdateTime,
  ];
}

/// Enum para tendencias de precio
enum PriceTrend {
  bullish,
  bearish,
  neutral;

  String get displayName {
    switch (this) {
      case PriceTrend.bullish:
        return 'Alcista';
      case PriceTrend.bearish:
        return 'Bajista';
      case PriceTrend.neutral:
        return 'Neutral';
    }
  }
}
