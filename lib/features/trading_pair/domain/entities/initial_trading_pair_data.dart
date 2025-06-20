import '/features/features.dart';

class InitialTradingPairData {
  final TradingPairEntity tradingPair;
  final PriceStatsEntity priceStats;
  final List<KlineEntity> klines;
  final List<TradeEntity> recentTrades;
  final SymbolInfoTraiding symbolInfo;
  final DateTime loadedAt;

  InitialTradingPairData({
    required this.tradingPair,
    required this.priceStats,
    required this.klines,
    required this.recentTrades,
    required this.symbolInfo,
    required this.loadedAt,
  });

  bool get isDataFresh {
    const freshnessDuration = Duration(minutes: 5);
    return DateTime.now().difference(loadedAt) < freshnessDuration;
  }

  String get loadSummary {
    return 'Símbolo: ${tradingPair.symbol} | '
        'Precio: \${tradingPair.formattedCurrentPrice} | '
        'Klines: ${klines.length} | '
        'Trades: ${recentTrades.length} | '
        'Cargado: ${loadedAt.toString()}';
  }

  /// Obtiene el precio actual del par
  double get currentPrice => tradingPair.currentPrice;

  /// Obtiene el cambio de precio en 24h
  double get priceChange24h => tradingPair.priceChange24h;

  /// Obtiene el cambio porcentual en 24h
  double get priceChangePercent24h => tradingPair.priceChangePercent24h;

  /// Determina si el cambio es positivo
  bool get isPriceChangePositive => tradingPair.isPriceChangePositive;

  /// Obtiene las últimas klines ordenadas por tiempo
  List<KlineEntity> get sortedKlines {
    final sorted = List<KlineEntity>.from(klines);
    sorted.sort((a, b) => a.openTime.compareTo(b.openTime));
    return sorted;
  }

  /// Obtiene los trades más recientes ordenados por tiempo
  List<TradeEntity> get sortedRecentTrades {
    final sorted = List<TradeEntity>.from(recentTrades);
    sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted;
  }

  /// Calcula el promedio de volumen de las últimas klines
  double get averageVolume {
    if (klines.isEmpty) return 0.0;
    final totalVolume = klines.fold<double>(
      0.0,
      (sum, kline) => sum + kline.quoteVolume,
    );
    return totalVolume / klines.length;
  }

  /// Obtiene estadísticas de trades por tipo
  TradeTypeStats get tradeStats {
    int buyTrades = 0;
    int sellTrades = 0;
    double buyVolume = 0.0;
    double sellVolume = 0.0;

    for (final trade in recentTrades) {
      if (trade.isBuy) {
        buyTrades++;
        buyVolume += trade.quoteQuantity;
      } else {
        sellTrades++;
        sellVolume += trade.quoteQuantity;
      }
    }

    return TradeTypeStats(
      buyTrades: buyTrades,
      sellTrades: sellTrades,
      buyVolume: buyVolume,
      sellVolume: sellVolume,
    );
  }

  /// Obtiene la tendencia general basada en múltiples indicadores
  PriceTrend get overallTrend {
    // Combinar tendencia de precio stats con análisis de klines
    final priceStatsTrend = priceStats.trend;

    if (klines.length < 5) return priceStatsTrend;

    // Analizar últimas 5 klines para confirmar tendencia
    final lastFiveKlines = sortedKlines.take(5).toList();
    int greenCandles = 0;
    int redCandles = 0;

    for (final kline in lastFiveKlines) {
      if (kline.isGreen) {
        greenCandles++;
      } else if (kline.isRed) {
        redCandles++;
      }
    }

    // Si la mayoría de velas recientes confirman la tendencia de precio
    if (greenCandles > redCandles && priceStatsTrend == PriceTrend.bullish) {
      return PriceTrend.bullish;
    } else if (redCandles > greenCandles &&
        priceStatsTrend == PriceTrend.bearish) {
      return PriceTrend.bearish;
    }

    return priceStatsTrend;
  }
}

/// Estadísticas de tipos de trades
class TradeTypeStats {
  final int buyTrades;
  final int sellTrades;
  final double buyVolume;
  final double sellVolume;

  TradeTypeStats({
    required this.buyTrades,
    required this.sellTrades,
    required this.buyVolume,
    required this.sellVolume,
  });

  /// Total de trades
  int get totalTrades => buyTrades + sellTrades;

  /// Volumen total
  double get totalVolume => buyVolume + sellVolume;

  /// Presión de compra (0.0 - 1.0)
  double get buyPressure {
    if (totalVolume == 0) return 0.5;
    return buyVolume / totalVolume;
  }

  /// Presión de venta (0.0 - 1.0)
  double get sellPressure => 1.0 - buyPressure;

  /// Determina el sentimiento dominante
  String get sentiment {
    if (buyPressure >= 0.6) return 'Alcista';
    if (sellPressure >= 0.6) return 'Bajista';
    return 'Neutral';
  }

  /// Obtiene descripción formateada
  String get description {
    return 'Compras: $buyTrades (${(buyPressure * 100).toStringAsFixed(1)}%) | '
        'Ventas: $sellTrades (${(sellPressure * 100).toStringAsFixed(1)}%) | '
        'Sentimiento: $sentiment';
  }
}
