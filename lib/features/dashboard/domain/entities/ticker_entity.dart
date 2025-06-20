import 'package:equatable/equatable.dart';

class TickerEntity extends Equatable {
  const TickerEntity({
    required this.symbol,
    required this.priceChange,
    required this.priceChangePercent,
    required this.weightedAvgPrice,
    required this.prevClosePrice,
    required this.lastPrice,
    required this.lastQty,
    required this.bidPrice,
    required this.bidQty,
    required this.askPrice,
    required this.askQty,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.volume,
    required this.quoteVolume,
    required this.openTime,
    required this.closeTime,
    required this.firstId,
    required this.lastId,
    required this.count,
  });

  final String symbol; // Par de trading (ej: BTCUSDT)
  final String priceChange; // Cambio absoluto de precio en 24h
  final String priceChangePercent; // Cambio porcentual de precio en 24h
  final String weightedAvgPrice; // Precio promedio ponderado
  final String prevClosePrice; // Precio de cierre anterior
  final String lastPrice; // Último precio
  final String lastQty; // Cantidad de la última transacción
  final String bidPrice; // Mejor precio de compra
  final String bidQty; // Cantidad del mejor precio de compra
  final String askPrice; // Mejor precio de venta
  final String askQty; // Cantidad del mejor precio de venta
  final String openPrice; // Precio de apertura
  final String highPrice; // Precio más alto en 24h
  final String lowPrice; // Precio más bajo en 24h
  final String volume; // Volumen en moneda base
  final String quoteVolume; // Volumen en moneda cotizada
  final int openTime; // Timestamp de apertura
  final int closeTime; // Timestamp de cierre
  final int firstId; // ID de primera transacción
  final int lastId; // ID de última transacción
  final int count; // Número de transacciones

  /// Convierte el precio a double para cálculos
  double get lastPriceAsDouble => double.tryParse(lastPrice) ?? 0.0;

  /// Convierte el cambio porcentual a double
  double get priceChangePercentAsDouble =>
      double.tryParse(priceChangePercent) ?? 0.0;

  /// Determina si el cambio de precio es positivo
  bool get isPriceChangePositive => priceChangePercentAsDouble >= 0;

  /// Formatea el precio con decimales apropiados
  String get formattedPrice {
    final price = lastPriceAsDouble;
    return price >= 1 ? price.toStringAsFixed(2) : price.toStringAsFixed(4);
  }

  /// Formatea el cambio porcentual con signo
  String get formattedPriceChangePercent {
    final change = priceChangePercentAsDouble;
    return '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%';
  }

  @override
  List<Object?> get props => [
    symbol,
    priceChange,
    priceChangePercent,
    weightedAvgPrice,
    prevClosePrice,
    lastPrice,
    lastQty,
    bidPrice,
    bidQty,
    askPrice,
    askQty,
    openPrice,
    highPrice,
    lowPrice,
    volume,
    quoteVolume,
    openTime,
    closeTime,
    firstId,
    lastId,
    count,
  ];
}
