import 'package:banexcoin/features/features.dart';
import 'package:flutter/foundation.dart';

class GetInitialTradingPairDataUseCase {
  final TradingPairRepository _repository;

  GetInitialTradingPairDataUseCase(this._repository);

  /// Ejecuta para obtener todos los datos iniciales del par de trading
  Future<InitialTradingPairData> execute(String symbol) async {
    if (symbol.isEmpty) {
      throw ArgumentError('El símbolo no puede estar vacío');
    }

    final normalizedSymbol = symbol.trim().toUpperCase();

    if (!_isValidSymbolFormat(normalizedSymbol)) {
      throw ArgumentError('Formato de símbolo inválido: $normalizedSymbol');
    }

    try {
      // Obtener datos en paralelo para mayor eficiencia
      final futures = await Future.wait([
        _repository.getInitialTradingPairData(normalizedSymbol),
        _repository.getInitialPriceStats(normalizedSymbol),
        _repository.getHistoricalKlines(
          symbol: normalizedSymbol,
          interval: '1h',
          limit: 100,
        ),
        _repository.getInitialRecentTrades(symbol: normalizedSymbol, limit: 50),
        _repository.getSymbolInfo(normalizedSymbol),
      ]);

      return InitialTradingPairData(
        tradingPair: futures[0] as TradingPairEntity,
        priceStats: futures[1] as PriceStatsEntity,
        klines: futures[2] as List<KlineEntity>,
        recentTrades: futures[3] as List<TradeEntity>,
        symbolInfo: futures[4] as SymbolInfoTraiding,
        loadedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error obteniendo datos iniciales para $normalizedSymbol: $e');
      rethrow;
    }
  }

  /// Ejecuta con configuración personalizada
  Future<InitialTradingPairData> executeWithConfig({
    required String symbol,
    String klineInterval = '1h',
    int klineLimit = 100,
    int tradesLimit = 50,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final normalizedSymbol = symbol.trim().toUpperCase();

    if (!_isValidSymbolFormat(normalizedSymbol)) {
      throw ArgumentError('Formato de símbolo inválido: $normalizedSymbol');
    }

    try {
      // Obtener datos con configuración personalizada
      final futures = await Future.wait([
        _repository.getInitialTradingPairData(normalizedSymbol),
        _repository.getInitialPriceStats(normalizedSymbol),
        _repository.getHistoricalKlines(
          symbol: normalizedSymbol,
          interval: klineInterval,
          limit: klineLimit,
        ),
        _repository.getInitialRecentTrades(
          symbol: normalizedSymbol,
          limit: tradesLimit,
        ),
        _repository.getSymbolInfo(normalizedSymbol),
      ]).timeout(timeout);

      return InitialTradingPairData(
        tradingPair: futures[0] as TradingPairEntity,
        priceStats: futures[1] as PriceStatsEntity,
        klines: futures[2] as List<KlineEntity>,
        recentTrades: futures[3] as List<TradeEntity>,
        symbolInfo: futures[4] as SymbolInfoTraiding,
        loadedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint(
        'Error obteniendo datos iniciales con configuración para $normalizedSymbol: $e',
      );
      rethrow;
    }
  }

  /// Ejecuta solo para validar símbolo
  Future<bool> validateSymbol(String symbol) async {
    final normalizedSymbol = symbol.trim().toUpperCase();

    if (!_isValidSymbolFormat(normalizedSymbol)) {
      return false;
    }

    try {
      return await _repository.isValidSymbol(normalizedSymbol);
    } catch (e) {
      debugPrint('Error validando símbolo $normalizedSymbol: $e');
      return false;
    }
  }

  /// Valida el formato básico de un símbolo de trading
  bool _isValidSymbolFormat(String symbol) {
    // Debe tener entre 6 y 12 caracteres
    if (symbol.length < 6 || symbol.length > 12) {
      return false;
    }

    // Debe contener solo letras y números
    if (!RegExp(r'^[A-Z0-9]+[A-Z0-9]+$').hasMatch(symbol)) {
      return false;
    }

    // Debe terminar con una moneda base conocida
    const commonQuoteAssets = ['USDT', 'BUSD', 'BTC', 'ETH', 'BNB', 'USDC'];
    return commonQuoteAssets.any((quote) => symbol.endsWith(quote));
  }
}
