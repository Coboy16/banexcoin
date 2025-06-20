import '../entities/entities.dart';
import '../repositories/repositories.dart';

class GetKlineStreamUseCase {
  final TradingPairRepository _repository;

  GetKlineStreamUseCase(this._repository);

  /// Ejecuta el caso de uso para obtener stream de klines
  Stream<List<KlineEntity>> execute({
    required String symbol,
    required String interval,
    int? limit,
  }) {
    // Validar símbolo
    if (symbol.isEmpty) {
      throw ArgumentError('El símbolo no puede estar vacío');
    }

    // Validar intervalo
    if (!_isValidInterval(interval)) {
      throw ArgumentError('Intervalo inválido: $interval');
    }

    // Normalizar símbolo
    final normalizedSymbol = symbol.trim().toUpperCase();

    // Validar formato
    if (!_isValidSymbolFormat(normalizedSymbol)) {
      throw ArgumentError('Formato de símbolo inválido: $normalizedSymbol');
    }

    return _repository.getKlineStream(
      symbol: normalizedSymbol,
      interval: interval,
      limit: limit,
    );
  }

  /// Ejecuta para obtener solo velas completas (cerradas)
  Stream<List<KlineEntity>> executeCompleteCandles({
    required String symbol,
    required String interval,
    int? limit,
  }) {
    return execute(symbol: symbol, interval: interval, limit: limit).map((
      klines,
    ) {
      // Filtrar solo velas que ya cerraron
      final now = DateTime.now();
      return klines.where((kline) => kline.closeTime.isBefore(now)).toList();
    });
  }

  /// Ejecuta con análisis de tendencia
  Stream<KlineTrendAnalysis> executeWithTrendAnalysis({
    required String symbol,
    required String interval,
    int lookbackPeriod = 10,
  }) {
    return execute(
      symbol: symbol,
      interval: interval,
      limit: lookbackPeriod + 1,
    ).map((klines) => _analyzeKlineTrend(klines, lookbackPeriod));
  }

  /// Analiza la tendencia de las klines
  KlineTrendAnalysis _analyzeKlineTrend(List<KlineEntity> klines, int period) {
    if (klines.length < period) {
      return KlineTrendAnalysis(
        trend: PriceTrend.neutral,
        strength: 0.0,
        greenCandles: 0,
        redCandles: 0,
        totalCandles: klines.length,
      );
    }

    int greenCandles = 0;
    int redCandles = 0;
    double totalChange = 0.0;

    for (final kline in klines.take(period)) {
      if (kline.isGreen) {
        greenCandles++;
      } else if (kline.isRed) {
        redCandles++;
      }
      totalChange += kline.priceChangePercent;
    }

    final avgChange = totalChange / period;
    final strength = (greenCandles - redCandles).abs() / period;

    PriceTrend trend;
    if (avgChange > 1.0 && greenCandles > redCandles) {
      trend = PriceTrend.bullish;
    } else if (avgChange < -1.0 && redCandles > greenCandles) {
      trend = PriceTrend.bearish;
    } else {
      trend = PriceTrend.neutral;
    }

    return KlineTrendAnalysis(
      trend: trend,
      strength: strength,
      greenCandles: greenCandles,
      redCandles: redCandles,
      totalCandles: period,
    );
  }

  /// Valida si el intervalo es válido
  bool _isValidInterval(String interval) {
    const validIntervals = [
      '1m',
      '3m',
      '5m',
      '15m',
      '30m',
      '1h',
      '2h',
      '4h',
      '6h',
      '8h',
      '12h',
      '1d',
      '3d',
      '1w',
      '1M',
    ];
    return validIntervals.contains(interval);
  }

  /// Valida el formato básico de un símbolo de trading
  bool _isValidSymbolFormat(String symbol) {
    // Debe tener entre 6 y 12 caracteres
    if (symbol.length < 6 || symbol.length > 12) {
      return false;
    }

    // Debe contener solo letras y números
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(symbol)) {
      return false;
    }

    // Debe terminar con una moneda base conocida
    const commonQuoteAssets = ['USDT', 'BUSD', 'BTC', 'ETH', 'BNB', 'USDC'];
    return commonQuoteAssets.any((quote) => symbol.endsWith(quote));
  }
}

/// Análisis de tendencia de klines
class KlineTrendAnalysis {
  final PriceTrend trend;
  final double strength; // 0.0 - 1.0
  final int greenCandles;
  final int redCandles;
  final int totalCandles;

  KlineTrendAnalysis({
    required this.trend,
    required this.strength,
    required this.greenCandles,
    required this.redCandles,
    required this.totalCandles,
  });

  /// Obtiene descripción de la fuerza
  String get strengthDescription {
    if (strength >= 0.8) return 'Muy fuerte';
    if (strength >= 0.6) return 'Fuerte';
    if (strength >= 0.4) return 'Moderada';
    if (strength >= 0.2) return 'Débil';
    return 'Muy débil';
  }
}
