import '../entities/entities.dart';
import '../repositories/repositories.dart';

class GetTradingPairStreamUseCase {
  final TradingPairRepository _repository;

  GetTradingPairStreamUseCase(this._repository);

  /// Ejecuta el caso de uso para obtener stream del par de trading
  Stream<TradingPairEntity> execute(String symbol) {
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

    return _repository.getTradingPairStream(normalizedSymbol);
  }

  /// Ejecuta con validación de símbolo previa
  Future<Stream<TradingPairEntity>> executeWithValidation(String symbol) async {
    final normalizedSymbol = symbol.trim().toUpperCase();

    // Verificar que el símbolo existe
    final isValid = await _repository.isValidSymbol(normalizedSymbol);
    if (!isValid) {
      throw ArgumentError(
        'El símbolo $normalizedSymbol no existe o no está disponible',
      );
    }

    return execute(normalizedSymbol);
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
