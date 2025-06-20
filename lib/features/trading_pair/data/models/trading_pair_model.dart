import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/entities.dart';

part 'trading_pair_model.g.dart';

@JsonSerializable()
class TradingPairModel extends TradingPairEntity {
  const TradingPairModel({
    required super.symbol,
    required super.baseAsset,
    required super.quoteAsset,
    required super.currentPrice,
    required super.priceChange24h,
    required super.priceChangePercent24h,
    required super.openPrice,
    required super.highPrice24h,
    required super.lowPrice24h,
    required super.volume24h,
    required super.quoteVolume24h,
    required super.lastUpdateTime,
    super.description,
  });

  factory TradingPairModel.fromTickerWebSocket(Map<String, dynamic> json) {
    final symbol = json['s'] as String;
    final baseAsset = _extractBaseAsset(symbol);
    final quoteAsset = _extractQuoteAsset(symbol);

    return TradingPairModel(
      symbol: symbol,
      baseAsset: baseAsset,
      quoteAsset: quoteAsset,
      currentPrice: double.parse(json['c'] as String),
      priceChange24h: double.parse(json['P'] as String),
      priceChangePercent24h: double.parse(json['P'] as String),
      openPrice: double.parse(json['o'] as String),
      highPrice24h: double.parse(json['h'] as String),
      lowPrice24h: double.parse(json['l'] as String),
      volume24h: double.parse(json['v'] as String),
      quoteVolume24h: double.parse(json['q'] as String),
      lastUpdateTime: DateTime.fromMillisecondsSinceEpoch(json['E'] as int),
      description: '$baseAsset / $quoteAsset',
    );
  }

  /// Crea modelo desde respuesta de ticker de Binance (REST)
  factory TradingPairModel.fromTickerRest(Map<String, dynamic> json) {
    final symbol = json['symbol'] as String;
    final baseAsset = _extractBaseAsset(symbol);
    final quoteAsset = _extractQuoteAsset(symbol);

    return TradingPairModel(
      symbol: symbol,
      baseAsset: baseAsset,
      quoteAsset: quoteAsset,
      currentPrice: double.parse(json['lastPrice'] as String),
      priceChange24h: double.parse(json['priceChange'] as String),
      priceChangePercent24h: double.parse(json['priceChangePercent'] as String),
      openPrice: double.parse(json['openPrice'] as String),
      highPrice24h: double.parse(json['highPrice'] as String),
      lowPrice24h: double.parse(json['lowPrice'] as String),
      volume24h: double.parse(json['volume'] as String),
      quoteVolume24h: double.parse(json['quoteVolume'] as String),
      lastUpdateTime: DateTime.fromMillisecondsSinceEpoch(
        json['closeTime'] as int,
      ),
      description: '$baseAsset / $quoteAsset',
    );
  }

  /// Serialización estándar para almacenamiento local
  factory TradingPairModel.fromJson(Map<String, dynamic> json) =>
      _$TradingPairModelFromJson(json);

  Map<String, dynamic> toJson() => _$TradingPairModelToJson(this);

  /// Convierte entidad de dominio a modelo
  factory TradingPairModel.fromEntity(TradingPairEntity entity) {
    return TradingPairModel(
      symbol: entity.symbol,
      baseAsset: entity.baseAsset,
      quoteAsset: entity.quoteAsset,
      currentPrice: entity.currentPrice,
      priceChange24h: entity.priceChange24h,
      priceChangePercent24h: entity.priceChangePercent24h,
      openPrice: entity.openPrice,
      highPrice24h: entity.highPrice24h,
      lowPrice24h: entity.lowPrice24h,
      volume24h: entity.volume24h,
      quoteVolume24h: entity.quoteVolume24h,
      lastUpdateTime: entity.lastUpdateTime,
      description: entity.description,
    );
  }

  /// Convierte a entidad de dominio
  TradingPairEntity toEntity() => this;

  /// Extrae el activo base del símbolo
  static String _extractBaseAsset(String symbol) {
    const quoteAssets = ['USDT', 'BUSD', 'BTC', 'ETH', 'BNB', 'USDC'];

    for (final quote in quoteAssets) {
      if (symbol.endsWith(quote)) {
        return symbol.substring(0, symbol.length - quote.length);
      }
    }

    // Fallback - asumir que los últimos 4 caracteres son el quote asset
    return symbol.substring(0, symbol.length - 4);
  }

  /// Extrae el activo cotizado del símbolo
  static String _extractQuoteAsset(String symbol) {
    const quoteAssets = ['USDT', 'BUSD', 'BTC', 'ETH', 'BNB', 'USDC'];

    for (final quote in quoteAssets) {
      if (symbol.endsWith(quote)) {
        return quote;
      }
    }

    // Fallback - asumir que los últimos 4 caracteres son el quote asset
    return symbol.substring(symbol.length - 4);
  }
}
