import 'package:flutter/foundation.dart';

import '/features/features.dart';

class GetDepthStreamUseCase {
  final MarketDataRepository _repository;

  GetDepthStreamUseCase(this._repository);

  /// Ejecuta el caso de uso para obtener depth stream
  Stream<DepthEntity> execute(String symbol) {
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

    return _repository.getDepthStream(normalizedSymbol);
  }

  /// Ejecuta con análisis de spread incluido
  Stream<DepthAnalysis> executeWithAnalysis(String symbol) {
    return execute(symbol).map((depth) => DepthAnalysis.fromDepth(depth));
  }

  /// Ejecuta para múltiples símbolos
  Map<String, Stream<DepthEntity>> executeMultiple(List<String> symbols) {
    if (symbols.isEmpty) {
      throw ArgumentError('La lista de símbolos no puede estar vacía');
    }

    final Map<String, Stream<DepthEntity>> streams = {};

    for (final symbol in symbols) {
      try {
        final normalizedSymbol = symbol.trim().toUpperCase();
        if (_isValidSymbolFormat(normalizedSymbol)) {
          streams[normalizedSymbol] = execute(normalizedSymbol);
        }
      } catch (e) {
        debugPrint('Error configurando stream de depth para $symbol: $e');
      }
    }

    return streams;
  }

  /// Ejecuta con filtro de niveles de precio específicos
  Stream<DepthEntity> executeWithPriceLevels({
    required String symbol,
    double? minPrice,
    double? maxPrice,
    int maxLevels = 20,
  }) {
    return execute(symbol).map((depth) {
      // Filtrar bids (órdenes de compra)
      List<OrderLevel> filteredBids = depth.bids;
      if (minPrice != null) {
        filteredBids = filteredBids
            .where((bid) => bid.price >= minPrice)
            .toList();
      }
      if (maxPrice != null) {
        filteredBids = filteredBids
            .where((bid) => bid.price <= maxPrice)
            .toList();
      }
      filteredBids = filteredBids.take(maxLevels).toList();

      // Filtrar asks (órdenes de venta)
      List<OrderLevel> filteredAsks = depth.asks;
      if (minPrice != null) {
        filteredAsks = filteredAsks
            .where((ask) => ask.price >= minPrice)
            .toList();
      }
      if (maxPrice != null) {
        filteredAsks = filteredAsks
            .where((ask) => ask.price <= maxPrice)
            .toList();
      }
      filteredAsks = filteredAsks.take(maxLevels).toList();

      return DepthEntity(
        lastUpdateId: depth.lastUpdateId,
        bids: filteredBids,
        asks: filteredAsks,
      );
    });
  }

  /// Ejecuta con alertas de spread anormal
  Stream<SpreadAlert> executeWithSpreadAlerts({
    required String symbol,
    double maxSpreadPercent = 1.0, // 1% de spread máximo
    Duration alertCooldown = const Duration(minutes: 5),
  }) {
    DateTime? lastAlertTime;

    return execute(symbol)
        .where((depth) => depth.spread != null && depth.spreadPercent != null)
        .where((depth) {
          final now = DateTime.now();
          final spreadPercent = depth.spreadPercent!;

          // Verificar si el spread excede el límite
          final hasHighSpread = spreadPercent > maxSpreadPercent;

          // Verificar cooldown
          if (lastAlertTime != null &&
              now.difference(lastAlertTime!) < alertCooldown) {
            return false;
          }

          if (hasHighSpread) {
            lastAlertTime = now;
            return true;
          }

          return false;
        })
        .map(
          (depth) => SpreadAlert(
            symbol: symbol,
            spread: depth.spread!,
            spreadPercent: depth.spreadPercent!,
            bestBid: depth.bestBidPrice!,
            bestAsk: depth.bestAskPrice!,
            timestamp: DateTime.now(),
          ),
        );
  }

  /// Ejecuta con cálculo de liquidez agregada
  Stream<LiquidityInfo> executeWithLiquidity(String symbol) {
    return execute(symbol).map((depth) => LiquidityInfo.fromDepth(depth));
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
