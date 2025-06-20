import 'package:flutter/foundation.dart';

import '../entities/entities.dart';
import '../repositories/repositories.dart';

class GetTickerStreamUseCase {
  final MarketDataRepository _repository;

  GetTickerStreamUseCase(this._repository);

  /// Ejecuta el caso de uso para obtener ticker stream
  Stream<TickerEntity> execute(String symbol) {
    // Validar símbolo
    if (symbol.isEmpty) {
      throw ArgumentError('El símbolo no puede estar vacío');
    }

    // Normalizar símbolo (convertir a mayúsculas y remover espacios)
    final normalizedSymbol = symbol.trim().toUpperCase();

    // Validar formato básico del símbolo
    if (!_isValidSymbolFormat(normalizedSymbol)) {
      throw ArgumentError('Formato de símbolo inválido: $normalizedSymbol');
    }

    return _repository.getTickerStream(normalizedSymbol);
  }

  /// Ejecuta para múltiples símbolos simultáneamente
  Map<String, Stream<TickerEntity>> executeMultiple(List<String> symbols) {
    if (symbols.isEmpty) {
      throw ArgumentError('La lista de símbolos no puede estar vacía');
    }

    final Map<String, Stream<TickerEntity>> streams = {};

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
