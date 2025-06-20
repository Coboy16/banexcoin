import 'package:flutter/foundation.dart';

import '/features/features.dart';

class GetInitialMarketDataUseCase {
  final MarketDataRepository _repository;

  GetInitialMarketDataUseCase(this._repository);

  /// Ejecuta para obtener datos iniciales de símbolos específicos
  Future<InitialMarketData> execute(List<String> symbols) async {
    if (symbols.isEmpty) {
      throw ArgumentError('La lista de símbolos no puede estar vacía');
    }

    try {
      // Normalizar símbolos
      final normalizedSymbols = symbols
          .map((s) => s.trim().toUpperCase())
          .where((s) => _isValidSymbolFormat(s))
          .toList();

      if (normalizedSymbols.isEmpty) {
        throw ArgumentError('No se encontraron símbolos válidos');
      }

      // Obtener datos en paralelo para mayor eficiencia
      final futures = <Future>[
        _repository.getInitialMarketData(normalizedSymbols),
        _repository.getMarketStatistics(),
        _repository.checkConnectivity(),
      ];

      final results = await Future.wait(futures);

      final tickers = results[0] as List<TickerEntity>;
      final statistics = results[1] as MarketStatistics;
      final isConnected = results[2] as bool;

      return InitialMarketData(
        tickers: tickers,
        statistics: statistics,
        isConnected: isConnected,
        symbols: normalizedSymbols,
        loadedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error obteniendo datos iniciales del mercado: $e');
      rethrow;
    }
  }

  /// Ejecuta para obtener datos iniciales con configuración personalizada
  Future<InitialMarketData> executeWithConfig({
    required List<String> symbols,
    bool includeStatistics = true,
    bool checkConnectivity = true,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      // Normalizar símbolos
      final normalizedSymbols = symbols
          .map((s) => s.trim().toUpperCase())
          .where((s) => _isValidSymbolFormat(s))
          .toList();

      if (normalizedSymbols.isEmpty) {
        throw ArgumentError('No se encontraron símbolos válidos');
      }

      // Preparar futures según configuración
      final futures = <Future>[];

      // Siempre obtener tickers principales
      futures.add(_repository.getInitialMarketData(normalizedSymbols));

      // Estadísticas opcionales
      if (includeStatistics) {
        futures.add(_repository.getMarketStatistics());
      }

      // Conectividad opcional
      if (checkConnectivity) {
        futures.add(_repository.checkConnectivity());
      }

      // Ejecutar con timeout
      final results = await Future.wait(futures).timeout(timeout);

      final tickers = results[0] as List<TickerEntity>;
      final statistics = includeStatistics
          ? results[includeStatistics ? 1 : -1] as MarketStatistics?
          : null;
      final isConnected = checkConnectivity
          ? results[futures.length - 1] as bool
          : true;

      return InitialMarketData(
        tickers: tickers,
        statistics: statistics,
        isConnected: isConnected,
        symbols: normalizedSymbols,
        loadedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error obteniendo datos iniciales con configuración: $e');
      rethrow;
    }
  }

  /// Ejecuta para obtener solo información del exchange
  Future<ExchangeInfo> executeExchangeInfo() async {
    try {
      return await _repository.getExchangeInfo();
    } catch (e) {
      debugPrint('Error obteniendo información del exchange: $e');
      rethrow;
    }
  }

  /// Ejecuta para obtener precio actual de un símbolo específico
  Future<double> executeCurrentPrice(String symbol) async {
    if (symbol.isEmpty) {
      throw ArgumentError('El símbolo no puede estar vacío');
    }

    final normalizedSymbol = symbol.trim().toUpperCase();

    if (!_isValidSymbolFormat(normalizedSymbol)) {
      throw ArgumentError('Formato de símbolo inválido: $normalizedSymbol');
    }

    try {
      return await _repository.getCurrentPrice(normalizedSymbol);
    } catch (e) {
      debugPrint('Error obteniendo precio actual para $normalizedSymbol: $e');
      rethrow;
    }
  }

  /// Ejecuta para obtener múltiples precios actuales
  Future<Map<String, double>> executeMultipleCurrentPrices(
    List<String> symbols,
  ) async {
    if (symbols.isEmpty) {
      throw ArgumentError('La lista de símbolos no puede estar vacía');
    }

    final normalizedSymbols = symbols
        .map((s) => s.trim().toUpperCase())
        .where((s) => _isValidSymbolFormat(s))
        .toList();

    if (normalizedSymbols.isEmpty) {
      throw ArgumentError('No se encontraron símbolos válidos');
    }

    final Map<String, double> prices = {};

    // Obtener precios en paralelo
    final futures = normalizedSymbols.map((symbol) async {
      try {
        final price = await _repository.getCurrentPrice(symbol);
        return MapEntry(symbol, price);
      } catch (e) {
        debugPrint('Error obteniendo precio para $symbol: $e');
        return null;
      }
    });

    final results = await Future.wait(futures);

    for (final result in results) {
      if (result != null) {
        prices[result.key] = result.value;
      }
    }

    return prices;
  }

  /// Ejecuta validación de conectividad
  Future<ConnectivityStatus> executeConnectivityCheck() async {
    try {
      final isConnected = await _repository.checkConnectivity();
      final statistics = isConnected
          ? await _repository.getMarketStatistics()
          : null;

      return ConnectivityStatus(
        isConnected: isConnected,
        checkedAt: DateTime.now(),
        marketStatistics: statistics,
      );
    } catch (e) {
      debugPrint('Error verificando conectividad: $e');
      return ConnectivityStatus(
        isConnected: false,
        checkedAt: DateTime.now(),
        error: e.toString(),
      );
    }
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
