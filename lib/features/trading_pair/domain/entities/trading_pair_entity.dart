import 'package:equatable/equatable.dart';

class TradingPairEntity extends Equatable {
  const TradingPairEntity({
    required this.symbol,
    required this.baseAsset,
    required this.quoteAsset,
    required this.currentPrice,
    required this.priceChange24h,
    required this.priceChangePercent24h,
    required this.openPrice,
    required this.highPrice24h,
    required this.lowPrice24h,
    required this.volume24h,
    required this.quoteVolume24h,
    required this.lastUpdateTime,
    this.description,
  });

  final String symbol; // ej: BTCUSDT
  final String baseAsset; // ej: BTC
  final String quoteAsset; // ej: USDT
  final double currentPrice;
  final double priceChange24h;
  final double priceChangePercent24h;
  final double openPrice;
  final double highPrice24h;
  final double lowPrice24h;
  final double volume24h;
  final double quoteVolume24h;
  final DateTime lastUpdateTime;
  final String? description;

  /// Determina si el cambio de precio es positivo
  bool get isPriceChangePositive => priceChange24h >= 0;

  /// Formatea el precio actual
  String get formattedCurrentPrice {
    return currentPrice >= 1
        ? currentPrice.toStringAsFixed(2)
        : currentPrice.toStringAsFixed(4);
  }

  /// Formatea el cambio de precio
  String get formattedPriceChange {
    final change = priceChange24h;
    return '${change >= 0 ? '+' : ''}\$${change.toStringAsFixed(2)}';
  }

  /// Formatea el cambio porcentual
  String get formattedPriceChangePercent {
    final change = priceChangePercent24h;
    return '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%';
  }

  /// Formatea el volumen
  String get formattedVolume {
    if (quoteVolume24h >= 1000000000) {
      return '${(quoteVolume24h / 1000000000).toStringAsFixed(1)}B $quoteAsset';
    } else if (quoteVolume24h >= 1000000) {
      return '${(quoteVolume24h / 1000000).toStringAsFixed(1)}M $quoteAsset';
    } else if (quoteVolume24h >= 1000) {
      return '${(quoteVolume24h / 1000).toStringAsFixed(1)}K $quoteAsset';
    }
    return '${quoteVolume24h.toStringAsFixed(0)} $quoteAsset';
  }

  /// Crea una copia con valores actualizados
  TradingPairEntity copyWith({
    String? symbol,
    String? baseAsset,
    String? quoteAsset,
    double? currentPrice,
    double? priceChange24h,
    double? priceChangePercent24h,
    double? openPrice,
    double? highPrice24h,
    double? lowPrice24h,
    double? volume24h,
    double? quoteVolume24h,
    DateTime? lastUpdateTime,
    String? description,
  }) {
    return TradingPairEntity(
      symbol: symbol ?? this.symbol,
      baseAsset: baseAsset ?? this.baseAsset,
      quoteAsset: quoteAsset ?? this.quoteAsset,
      currentPrice: currentPrice ?? this.currentPrice,
      priceChange24h: priceChange24h ?? this.priceChange24h,
      priceChangePercent24h:
          priceChangePercent24h ?? this.priceChangePercent24h,
      openPrice: openPrice ?? this.openPrice,
      highPrice24h: highPrice24h ?? this.highPrice24h,
      lowPrice24h: lowPrice24h ?? this.lowPrice24h,
      volume24h: volume24h ?? this.volume24h,
      quoteVolume24h: quoteVolume24h ?? this.quoteVolume24h,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [
    symbol,
    baseAsset,
    quoteAsset,
    currentPrice,
    priceChange24h,
    priceChangePercent24h,
    openPrice,
    highPrice24h,
    lowPrice24h,
    volume24h,
    quoteVolume24h,
    lastUpdateTime,
    description,
  ];
}
