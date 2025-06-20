import '/features/features.dart';

class GetRecentTradesStreamUseCase {
  final TradingPairRepository _repository;

  GetRecentTradesStreamUseCase(this._repository);

  /// Ejecuta el caso de uso para obtener stream de trades recientes
  Stream<List<TradeEntity>> execute(String symbol) {
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

    return _repository.getRecentTradesStream(normalizedSymbol);
  }

  /// Ejecuta con filtro de trades grandes
  Stream<List<TradeEntity>> executeLargeTrades({
    required String symbol,
    double minTradeValue = 10000.0, // Valor mínimo en quote asset
  }) {
    return execute(symbol).map((trades) {
      return trades
          .where((trade) => trade.quoteQuantity >= minTradeValue)
          .toList();
    });
  }

  /// Ejecuta con filtro por tipo de trade
  Stream<List<TradeEntity>> executeByTradeType({
    required String symbol,
    required bool buyTrades, // true para compras, false para ventas
  }) {
    return execute(symbol).map((trades) {
      return trades.where((trade) => trade.isBuy == buyTrades).toList();
    });
  }

  /// Ejecuta con análisis de volumen de compra/venta
  Stream<TradeVolumeAnalysis> executeWithVolumeAnalysis({
    required String symbol,
    Duration analysisWindow = const Duration(minutes: 5),
  }) {
    return execute(
      symbol,
    ).map((trades) => _analyzeTradeVolume(trades, analysisWindow));
  }

  /// Analiza el volumen de trades
  TradeVolumeAnalysis _analyzeTradeVolume(
    List<TradeEntity> trades,
    Duration window,
  ) {
    final cutoffTime = DateTime.now().subtract(window);
    final recentTrades = trades
        .where((trade) => trade.timestamp.isAfter(cutoffTime))
        .toList();

    double buyVolume = 0.0;
    double sellVolume = 0.0;
    int buyCount = 0;
    int sellCount = 0;

    for (final trade in recentTrades) {
      if (trade.isBuy) {
        buyVolume += trade.quoteQuantity;
        buyCount++;
      } else {
        sellVolume += trade.quoteQuantity;
        sellCount++;
      }
    }

    final totalVolume = buyVolume + sellVolume;
    final buyPressure = totalVolume > 0 ? buyVolume / totalVolume : 0.5;

    return TradeVolumeAnalysis(
      buyVolume: buyVolume,
      sellVolume: sellVolume,
      totalVolume: totalVolume,
      buyCount: buyCount,
      sellCount: sellCount,
      buyPressure: buyPressure,
      sellPressure: 1.0 - buyPressure,
      totalTrades: recentTrades.length,
      analysisWindow: window,
    );
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
    final commonQuoteAssets = ['USDT', 'BUSD', 'BTC', 'ETH', 'BNB', 'USDC'];
    return commonQuoteAssets.any((quote) => symbol.endsWith(quote));
  }
}
