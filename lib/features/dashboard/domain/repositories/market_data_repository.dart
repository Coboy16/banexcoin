import '../entities/entities.dart';

abstract class MarketDataRepository {
  /// Stream de datos de ticker en tiempo real
  Stream<TickerEntity> getTickerStream(String symbol);

  /// Stream de mini ticker en tiempo real
  Stream<MiniTickerEntity> getMiniTickerStream(String symbol);

  /// Stream de libro de órdenes en tiempo real
  Stream<DepthEntity> getDepthStream(String symbol);

  /// Obtiene datos iniciales de ticker
  Future<TickerEntity> getInitialTickerData(String symbol);

  /// Obtiene datos iniciales de múltiples tickers
  Future<List<TickerEntity>> getInitialMarketData(List<String> symbols);

  /// Obtiene información del exchange
  Future<ExchangeInfo> getExchangeInfo();

  /// Obtiene precio actual de un símbolo
  Future<double> getCurrentPrice(String symbol);

  /// Obtiene libro de órdenes
  Future<DepthEntity> getOrderBook(String symbol);

  /// Verifica conectividad con el exchange
  Future<bool> checkConnectivity();

  /// Obtiene estadísticas del mercado
  Future<MarketStatistics> getMarketStatistics();

  /// Libera recursos
  Future<void> dispose();
}
