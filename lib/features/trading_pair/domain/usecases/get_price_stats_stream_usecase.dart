import '../entities/entities.dart';
import '../repositories/repositories.dart';

class GetPriceStatsStreamUseCase {
  final TradingPairRepository _repository;

  GetPriceStatsStreamUseCase(this._repository);

  /// Ejecuta el caso de uso para obtener stream de estadísticas de precio
  Stream<PriceStatsEntity> execute(String symbol) {
    // Validar símbolo
    if (symbol.isEmpty) {
      throw ArgumentError('El símbolo no puede estar vacío');
    }

    // Normalizar símbolo
    final normalizedSymbol = symbol.trim().toUpperCase();

    // Validar formato
    if (!_isValidSymbolFormat(normalizedSymbol)) {
      throw ArgumentError('Formato de símbolo inválido: $normalizedSymbol');
    }

    return _repository.getPriceStatsStream(normalizedSymbol);
  }

  /// Ejecuta con alertas de cambio significativo
  Stream<PriceStatsEntity> executeWithAlerts({
    required String symbol,
    double significantChangePercent = 5.0, // 5% de cambio significativo
  }) {
    return execute(symbol).where((stats) {
      final changePercent = stats.priceChangePercent.abs();
      return changePercent >= significantChangePercent;
    });
  }

  /// Ejecuta con filtro de tendencia específica
  Stream<PriceStatsEntity> executeWithTrendFilter({
    required String symbol,
    required PriceTrend targetTrend,
  }) {
    return execute(symbol).where((stats) => stats.trend == targetTrend);
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
