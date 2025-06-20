import 'package:equatable/equatable.dart';

class MiniTickerEntity extends Equatable {
  const MiniTickerEntity({
    required this.symbol,
    required this.closePrice,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.volume,
    required this.quoteVolume,
  });

  final String symbol; // Par de trading (ej: BTCUSDT)
  final String closePrice; // Precio actual/último
  final String openPrice; // Precio de apertura en 24h
  final String highPrice; // Precio más alto en 24h
  final String lowPrice; // Precio más bajo en 24h
  final String volume; // Volumen en moneda base
  final String quoteVolume; // Volumen en moneda cotizada

  /// Convierte precio actual a double
  double get closePriceAsDouble => double.tryParse(closePrice) ?? 0.0;

  /// Convierte precio de apertura a double
  double get openPriceAsDouble => double.tryParse(openPrice) ?? 0.0;

  /// Calcula el cambio de precio en valor absoluto
  double get priceChange => closePriceAsDouble - openPriceAsDouble;

  /// Calcula el cambio de precio en porcentaje
  double get priceChangePercent {
    if (openPriceAsDouble == 0) return 0.0;
    return ((closePriceAsDouble - openPriceAsDouble) / openPriceAsDouble) * 100;
  }

  /// Determina si el cambio es positivo
  bool get isPriceChangePositive => priceChange >= 0;

  /// Formatea el precio con decimales apropiados
  String get formattedPrice {
    final price = closePriceAsDouble;
    return price >= 1 ? price.toStringAsFixed(2) : price.toStringAsFixed(4);
  }

  /// Formatea el cambio porcentual con signo
  String get formattedPriceChangePercent {
    final change = priceChangePercent;
    return '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%';
  }

  /// Formatea el cambio absoluto con signo
  String get formattedPriceChange {
    final change = priceChange;
    return '${change >= 0 ? '+' : ''}${change.toStringAsFixed(4)}';
  }

  @override
  List<Object?> get props => [
    symbol,
    closePrice,
    openPrice,
    highPrice,
    lowPrice,
    volume,
    quoteVolume,
  ];
}
