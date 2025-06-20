import 'package:equatable/equatable.dart';

class KlineEntity extends Equatable {
  const KlineEntity({
    required this.openTime,
    required this.closeTime,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.closePrice,
    required this.volume,
    required this.quoteVolume,
    required this.tradesCount,
  });

  final DateTime openTime;
  final DateTime closeTime;
  final double openPrice;
  final double highPrice;
  final double lowPrice;
  final double closePrice;
  final double volume;
  final double quoteVolume;
  final int tradesCount;

  /// Determina si es una vela verde (precio subió)
  bool get isGreen => closePrice > openPrice;

  /// Determina si es una vela roja (precio bajó)
  bool get isRed => closePrice < openPrice;

  /// Calcula el cambio de precio
  double get priceChange => closePrice - openPrice;

  /// Calcula el cambio porcentual
  double get priceChangePercent {
    if (openPrice == 0) return 0.0;
    return ((closePrice - openPrice) / openPrice) * 100;
  }

  /// Calcula el rango de precio (high - low)
  double get priceRange => highPrice - lowPrice;

  /// Calcula el cuerpo de la vela
  double get bodySize => (closePrice - openPrice).abs();

  /// Calcula la mecha superior
  double get upperWick => highPrice - (isGreen ? closePrice : openPrice);

  /// Calcula la mecha inferior
  double get lowerWick => (isGreen ? openPrice : closePrice) - lowPrice;

  @override
  List<Object?> get props => [
    openTime,
    closeTime,
    openPrice,
    highPrice,
    lowPrice,
    closePrice,
    volume,
    quoteVolume,
    tradesCount,
  ];
}
