import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/entities.dart';

part 'ticker_model.g.dart';

@JsonSerializable()
class TickerModel extends TickerEntity {
  const TickerModel({
    required super.symbol,
    required super.priceChange,
    required super.priceChangePercent,
    required super.weightedAvgPrice,
    required super.prevClosePrice,
    required super.lastPrice,
    required super.lastQty,
    required super.bidPrice,
    required super.bidQty,
    required super.askPrice,
    required super.askQty,
    required super.openPrice,
    required super.highPrice,
    required super.lowPrice,
    required super.volume,
    required super.quoteVolume,
    required super.openTime,
    required super.closeTime,
    required super.firstId,
    required super.lastId,
    required super.count,
  });

  /// Crea modelo desde respuesta de WebSocket de Binance
  factory TickerModel.fromWebSocketJson(Map<String, dynamic> json) {
    return TickerModel(
      symbol: json['s'] as String,
      priceChange: json['P'] as String,
      priceChangePercent: json['P'] as String,
      weightedAvgPrice: json['w'] as String,
      prevClosePrice: json['x'] as String,
      lastPrice: json['c'] as String,
      lastQty: json['Q'] as String,
      bidPrice: json['b'] as String,
      bidQty: json['B'] as String,
      askPrice: json['a'] as String,
      askQty: json['A'] as String,
      openPrice: json['o'] as String,
      highPrice: json['h'] as String,
      lowPrice: json['l'] as String,
      volume: json['v'] as String,
      quoteVolume: json['q'] as String,
      openTime: json['O'] as int,
      closeTime: json['C'] as int,
      firstId: json['F'] as int,
      lastId: json['L'] as int,
      count: json['n'] as int,
    );
  }

  /// Crea modelo desde respuesta de REST API de Binance
  factory TickerModel.fromRestJson(Map<String, dynamic> json) {
    return TickerModel(
      symbol: json['symbol'] as String,
      priceChange: json['priceChange'] as String,
      priceChangePercent: json['priceChangePercent'] as String,
      weightedAvgPrice: json['weightedAvgPrice'] as String,
      prevClosePrice: json['prevClosePrice'] as String,
      lastPrice: json['lastPrice'] as String,
      lastQty: json['lastQty'] as String,
      bidPrice: json['bidPrice'] as String,
      bidQty: json['bidQty'] as String,
      askPrice: json['askPrice'] as String,
      askQty: json['askQty'] as String,
      openPrice: json['openPrice'] as String,
      highPrice: json['highPrice'] as String,
      lowPrice: json['lowPrice'] as String,
      volume: json['volume'] as String,
      quoteVolume: json['quoteVolume'] as String,
      openTime: json['openTime'] as int,
      closeTime: json['closeTime'] as int,
      firstId: json['firstId'] as int,
      lastId: json['lastId'] as int,
      count: json['count'] as int,
    );
  }

  /// Serialización estándar para almacenamiento local
  factory TickerModel.fromJson(Map<String, dynamic> json) =>
      _$TickerModelFromJson(json);

  Map<String, dynamic> toJson() => _$TickerModelToJson(this);

  /// Convierte entidad de dominio a modelo
  factory TickerModel.fromEntity(TickerEntity entity) {
    return TickerModel(
      symbol: entity.symbol,
      priceChange: entity.priceChange,
      priceChangePercent: entity.priceChangePercent,
      weightedAvgPrice: entity.weightedAvgPrice,
      prevClosePrice: entity.prevClosePrice,
      lastPrice: entity.lastPrice,
      lastQty: entity.lastQty,
      bidPrice: entity.bidPrice,
      bidQty: entity.bidQty,
      askPrice: entity.askPrice,
      askQty: entity.askQty,
      openPrice: entity.openPrice,
      highPrice: entity.highPrice,
      lowPrice: entity.lowPrice,
      volume: entity.volume,
      quoteVolume: entity.quoteVolume,
      openTime: entity.openTime,
      closeTime: entity.closeTime,
      firstId: entity.firstId,
      lastId: entity.lastId,
      count: entity.count,
    );
  }

  /// Convierte a entidad de dominio
  TickerEntity toEntity() => this;
}
