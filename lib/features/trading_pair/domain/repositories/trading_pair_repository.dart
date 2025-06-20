import '/features/features.dart';

abstract class TradingPairRepository {
  /// Stream de datos del par de trading en tiempo real
  Stream<TradingPairEntity> getTradingPairStream(String symbol);

  /// Stream de estadísticas de precio en tiempo real
  Stream<PriceStatsEntity> getPriceStatsStream(String symbol);

  /// Stream de klines/candlesticks en tiempo real
  Stream<List<KlineEntity>> getKlineStream({
    required String symbol,
    required String interval,
    int? limit,
  });

  /// Stream de trades recientes en tiempo real
  Stream<List<TradeEntity>> getRecentTradesStream(String symbol);

  /// Obtiene datos iniciales del par de trading
  Future<TradingPairEntity> getInitialTradingPairData(String symbol);

  /// Obtiene estadísticas iniciales de precio
  Future<PriceStatsEntity> getInitialPriceStats(String symbol);

  /// Obtiene klines históricos
  Future<List<KlineEntity>> getHistoricalKlines({
    required String symbol,
    required String interval,
    int? limit,
    DateTime? startTime,
    DateTime? endTime,
  });

  /// Obtiene trades recientes iniciales
  Future<List<TradeEntity>> getInitialRecentTrades({
    required String symbol,
    int limit = 50,
  });

  /// Verifica si el símbolo existe y es válido
  Future<bool> isValidSymbol(String symbol);

  /// Obtiene información básica del símbolo
  Future<SymbolInfoTraiding> getSymbolInfo(String symbol);

  /// Libera recursos
  Future<void> dispose();
}
