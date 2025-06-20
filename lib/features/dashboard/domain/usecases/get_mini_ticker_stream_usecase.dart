import 'dart:async';

import 'package:flutter/foundation.dart';

import '../entities/entities.dart';
import '../repositories/repositories.dart';

class GetMiniTickerStreamUseCase {
  final MarketDataRepository _repository;

  GetMiniTickerStreamUseCase(this._repository);

  /// Ejecuta el caso de uso para obtener mini ticker stream
  Stream<MiniTickerEntity> execute(String symbol) {
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

    return _repository.getMiniTickerStream(normalizedSymbol);
  }

  /// Ejecuta para múltiples símbolos con filtros de cambio mínimo
  Map<String, Stream<MiniTickerEntity>> executeWithFilter({
    required List<String> symbols,
    double minChangePercent = 0.0,
    bool onlyPositiveChanges = false,
  }) {
    if (symbols.isEmpty) {
      throw ArgumentError('La lista de símbolos no puede estar vacía');
    }

    final Map<String, Stream<MiniTickerEntity>> streams = {};

    for (final symbol in symbols) {
      try {
        final normalizedSymbol = symbol.trim().toUpperCase();
        if (_isValidSymbolFormat(normalizedSymbol)) {
          // Aplicar filtros al stream
          final baseStream = _repository.getMiniTickerStream(normalizedSymbol);
          final filteredStream = baseStream.where((ticker) {
            final changePercent = ticker.priceChangePercent.abs();

            // Filtro por cambio mínimo
            if (changePercent < minChangePercent) {
              return false;
            }

            // Filtro solo cambios positivos
            if (onlyPositiveChanges && !ticker.isPriceChangePositive) {
              return false;
            }

            return true;
          });

          streams[normalizedSymbol] = filteredStream;
        }
      } catch (e) {
        debugPrint('Error configurando stream filtrado para $symbol: $e');
      }
    }

    return streams;
  }

  /// Ejecuta para obtener los top movers (mayores cambios)
  Stream<List<MiniTickerEntity>> executeTopMovers({
    required List<String> symbols,
    int topCount = 10,
    bool ascending = false, // false = descendente (mayores cambios primero)
  }) {
    if (symbols.isEmpty) {
      throw ArgumentError('La lista de símbolos no puede estar vacía');
    }

    // Crear streams para todos los símbolos
    final streams = executeMultiple(symbols);

    // Combinar todos los streams en uno solo
    return _combineStreamsToTopMovers(streams, topCount, ascending);
  }

  /// Ejecuta para múltiples símbolos sin filtros
  Map<String, Stream<MiniTickerEntity>> executeMultiple(List<String> symbols) {
    if (symbols.isEmpty) {
      throw ArgumentError('La lista de símbolos no puede estar vacía');
    }

    final Map<String, Stream<MiniTickerEntity>> streams = {};

    for (final symbol in symbols) {
      try {
        final normalizedSymbol = symbol.trim().toUpperCase();
        if (_isValidSymbolFormat(normalizedSymbol)) {
          streams[normalizedSymbol] = execute(normalizedSymbol);
        }
      } catch (e) {
        debugPrint('Error configurando stream para $symbol: $e');
      }
    }

    return streams;
  }

  /// Combina múltiples streams en un stream de top movers
  Stream<List<MiniTickerEntity>> _combineStreamsToTopMovers(
    Map<String, Stream<MiniTickerEntity>> streams,
    int topCount,
    bool ascending,
  ) async* {
    final latestTickers = <String, MiniTickerEntity>{};

    // Crear un stream controller para manejar las actualizaciones combinadas
    final controller = StreamController<List<MiniTickerEntity>>();

    // Suscribirse a todos los streams
    for (final entry in streams.entries) {
      final symbol = entry.key;
      final stream = entry.value;

      stream.listen(
        (ticker) {
          latestTickers[symbol] = ticker;

          // Ordenar y emitir top movers
          final sortedTickers = latestTickers.values.toList()
            ..sort((a, b) {
              final changeA = a.priceChangePercent.abs();
              final changeB = b.priceChangePercent.abs();
              return ascending
                  ? changeA.compareTo(changeB)
                  : changeB.compareTo(changeA);
            });

          final topMovers = sortedTickers.take(topCount).toList();
          controller.add(topMovers);
        },
        onError: (error) {
          debugPrint('Error en stream de $symbol: $error');
        },
      );
    }

    yield* controller.stream;
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
