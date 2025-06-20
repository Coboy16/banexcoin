import 'package:json_annotation/json_annotation.dart';
import '/features/features.dart';

part 'mini_ticker_model.g.dart';

@JsonSerializable()
class MiniTickerModel extends MiniTickerEntity {
  const MiniTickerModel({
    required super.symbol,
    required super.closePrice,
    required super.openPrice,
    required super.highPrice,
    required super.lowPrice,
    required super.volume,
    required super.quoteVolume,
  });

  /// Crea modelo desde respuesta de WebSocket de Binance
  factory MiniTickerModel.fromWebSocketJson(Map<String, dynamic> json) {
    return MiniTickerModel(
      symbol: json['s'] as String,
      closePrice: json['c'] as String,
      openPrice: json['o'] as String,
      highPrice: json['h'] as String,
      lowPrice: json['l'] as String,
      volume: json['v'] as String,
      quoteVolume: json['q'] as String,
    );
  }

  /// Serialización estándar para almacenamiento local
  factory MiniTickerModel.fromJson(Map<String, dynamic> json) =>
      _$MiniTickerModelFromJson(json);

  Map<String, dynamic> toJson() => _$MiniTickerModelToJson(this);

  /// Convierte entidad de dominio a modelo
  factory MiniTickerModel.fromEntity(MiniTickerEntity entity) {
    return MiniTickerModel(
      symbol: entity.symbol,
      closePrice: entity.closePrice,
      openPrice: entity.openPrice,
      highPrice: entity.highPrice,
      lowPrice: entity.lowPrice,
      volume: entity.volume,
      quoteVolume: entity.quoteVolume,
    );
  }

  /// Convierte a entidad de dominio
  MiniTickerEntity toEntity() => this;

  /// Crea modelo desde ticker completo (para compatibilidad)
  factory MiniTickerModel.fromTicker(TickerModel ticker) {
    return MiniTickerModel(
      symbol: ticker.symbol,
      closePrice: ticker.lastPrice,
      openPrice: ticker.openPrice,
      highPrice: ticker.highPrice,
      lowPrice: ticker.lowPrice,
      volume: ticker.volume,
      quoteVolume: ticker.quoteVolume,
    );
  }
}
