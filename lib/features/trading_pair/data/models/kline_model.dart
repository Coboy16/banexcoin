import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/entities.dart';

part 'kline_model.g.dart';

@JsonSerializable()
class KlineModel extends KlineEntity {
  const KlineModel({
    required super.openTime,
    required super.closeTime,
    required super.openPrice,
    required super.highPrice,
    required super.lowPrice,
    required super.closePrice,
    required super.volume,
    required super.quoteVolume,
    required super.tradesCount,
  });

  factory KlineModel.fromWebSocket(Map<String, dynamic> json) {
    final klineData = json['k'] as Map<String, dynamic>;

    return KlineModel(
      openTime: DateTime.fromMillisecondsSinceEpoch(klineData['t'] as int),
      closeTime: DateTime.fromMillisecondsSinceEpoch(klineData['T'] as int),
      openPrice: double.parse(klineData['o'] as String),
      highPrice: double.parse(klineData['h'] as String),
      lowPrice: double.parse(klineData['l'] as String),
      closePrice: double.parse(klineData['c'] as String),
      volume: double.parse(klineData['v'] as String),
      quoteVolume: double.parse(klineData['q'] as String),
      tradesCount: klineData['n'] as int,
    );
  }

  /// Crea modelo desde respuesta de kline de Binance (REST)
  factory KlineModel.fromRestList(List<dynamic> klineArray) {
    return KlineModel(
      openTime: DateTime.fromMillisecondsSinceEpoch(klineArray[0] as int),
      closeTime: DateTime.fromMillisecondsSinceEpoch(klineArray[6] as int),
      openPrice: double.parse(klineArray[1] as String),
      highPrice: double.parse(klineArray[2] as String),
      lowPrice: double.parse(klineArray[3] as String),
      closePrice: double.parse(klineArray[4] as String),
      volume: double.parse(klineArray[5] as String),
      quoteVolume: double.parse(klineArray[7] as String),
      tradesCount: klineArray[8] as int,
    );
  }

  /// Serialización estándar para almacenamiento local
  factory KlineModel.fromJson(Map<String, dynamic> json) =>
      _$KlineModelFromJson(json);

  Map<String, dynamic> toJson() => _$KlineModelToJson(this);

  /// Convierte entidad de dominio a modelo
  factory KlineModel.fromEntity(KlineEntity entity) {
    return KlineModel(
      openTime: entity.openTime,
      closeTime: entity.closeTime,
      openPrice: entity.openPrice,
      highPrice: entity.highPrice,
      lowPrice: entity.lowPrice,
      closePrice: entity.closePrice,
      volume: entity.volume,
      quoteVolume: entity.quoteVolume,
      tradesCount: entity.tradesCount,
    );
  }

  /// Convierte a entidad de dominio
  KlineEntity toEntity() => this;
}
