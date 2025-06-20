import '/features/features.dart';

class InitialMarketData {
  final List<TickerEntity> tickers;
  final MarketStatistics? statistics;
  final bool isConnected;
  final List<String> symbols;
  final DateTime loadedAt;

  InitialMarketData({
    required this.tickers,
    this.statistics,
    required this.isConnected,
    required this.symbols,
    required this.loadedAt,
  });

  /// Obtiene ticker por símbolo
  TickerEntity? getTickerBySymbol(String symbol) {
    try {
      return tickers.firstWhere(
        (ticker) => ticker.symbol.toUpperCase() == symbol.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Obtiene símbolos con mayor ganancia
  List<TickerEntity> getTopGainers({int limit = 10}) {
    final sortedTickers = List<TickerEntity>.from(tickers)
      ..sort(
        (a, b) => b.priceChangePercentAsDouble.compareTo(
          a.priceChangePercentAsDouble,
        ),
      );

    return sortedTickers
        .where((ticker) => ticker.isPriceChangePositive)
        .take(limit)
        .toList();
  }

  /// Obtiene símbolos con mayor pérdida
  List<TickerEntity> getTopLosers({int limit = 10}) {
    final sortedTickers = List<TickerEntity>.from(tickers)
      ..sort(
        (a, b) => a.priceChangePercentAsDouble.compareTo(
          b.priceChangePercentAsDouble,
        ),
      );

    return sortedTickers
        .where((ticker) => !ticker.isPriceChangePositive)
        .take(limit)
        .toList();
  }

  /// Obtiene símbolos más activos por volumen
  List<TickerEntity> getMostActive({int limit = 10}) {
    final sortedTickers = List<TickerEntity>.from(tickers)
      ..sort((a, b) {
        final volumeA = double.tryParse(a.quoteVolume) ?? 0;
        final volumeB = double.tryParse(b.quoteVolume) ?? 0;
        return volumeB.compareTo(volumeA);
      });

    return sortedTickers.take(limit).toList();
  }

  /// Verifica si los datos están actualizados
  bool get isDataFresh {
    const freshnessDuration = Duration(minutes: 5);
    return DateTime.now().difference(loadedAt) < freshnessDuration;
  }

  /// Obtiene resumen de carga
  String get loadSummary {
    return 'Cargados ${tickers.length} símbolos de ${symbols.length} solicitados. '
        'Conectividad: ${isConnected ? 'OK' : 'ERROR'}. '
        'Cargado: ${loadedAt.toString()}';
  }
}
