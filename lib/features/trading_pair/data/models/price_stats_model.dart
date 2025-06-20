import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/entities.dart';

part 'price_stats_model.g.dart';

@JsonSerializable()
class PriceStatsModel extends PriceStatsEntity {
  const PriceStatsModel({
    required super.symbol,
    required super.currentPrice,
    required super.openPrice,
    required super.highPrice,
    required super.lowPrice,
    required super.priceChange,
    required super.priceChangePercent,
    required super.volume,
    required super.quoteVolume,
    required super.lastUpdateTime,
  });

  /// Crea modelo desde ticker de Binance para estadísticas de precio
  factory PriceStatsModel.fromTicker(
    Map<String, dynamic> json, {
    bool isWebSocket = false,
  }) {
    if (isWebSocket) {
      return PriceStatsModel(
        symbol: json['s'] as String,
        currentPrice: double.parse(json['c'] as String),
        openPrice: double.parse(json['o'] as String),
        highPrice: double.parse(json['h'] as String),
        lowPrice: double.parse(json['l'] as String),
        priceChange: double.parse(json['P'] as String),
        priceChangePercent: double.parse(json['P'] as String),
        volume: double.parse(json['v'] as String),
        quoteVolume: double.parse(json['q'] as String),
        lastUpdateTime: DateTime.fromMillisecondsSinceEpoch(json['E'] as int),
      );
    } else {
      return PriceStatsModel(
        symbol: json['symbol'] as String,
        currentPrice: double.parse(json['lastPrice'] as String),
        openPrice: double.parse(json['openPrice'] as String),
        highPrice: double.parse(json['highPrice'] as String),
        lowPrice: double.parse(json['lowPrice'] as String),
        priceChange: double.parse(json['priceChange'] as String),
        priceChangePercent: double.parse(json['priceChangePercent'] as String),
        volume: double.parse(json['volume'] as String),
        quoteVolume: double.parse(json['quoteVolume'] as String),
        lastUpdateTime: DateTime.fromMillisecondsSinceEpoch(
          json['closeTime'] as int,
        ),
      );
    }
  }

  /// Serialización estándar para almacenamiento local
  factory PriceStatsModel.fromJson(Map<String, dynamic> json) =>
      _$PriceStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$PriceStatsModelToJson(this);

  /// Convierte entidad de dominio a modelo
  factory PriceStatsModel.fromEntity(PriceStatsEntity entity) {
    return PriceStatsModel(
      symbol: entity.symbol,
      currentPrice: entity.currentPrice,
      openPrice: entity.openPrice,
      highPrice: entity.highPrice,
      lowPrice: entity.lowPrice,
      priceChange: entity.priceChange,
      priceChangePercent: entity.priceChangePercent,
      volume: entity.volume,
      quoteVolume: entity.quoteVolume,
      lastUpdateTime: entity.lastUpdateTime,
    );
  }

  /// Convierte a entidad de dominio
  PriceStatsEntity toEntity() => this;
}
