import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/entities.dart';

part 'trade_model.g.dart';

@JsonSerializable()
class TradeModel extends TradeEntity {
  const TradeModel({
    required super.id,
    required super.price,
    required super.quantity,
    required super.quoteQuantity,
    required super.timestamp,
    required super.isBuyerMaker,
  });

  /// Crea modelo desde respuesta de trade de Binance (WebSocket)
  factory TradeModel.fromWebSocket(Map<String, dynamic> json) {
    return TradeModel(
      id: json['t'] as int,
      price: double.parse(json['p'] as String),
      quantity: double.parse(json['q'] as String),
      quoteQuantity:
          double.parse(json['p'] as String) * double.parse(json['q'] as String),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['T'] as int),
      isBuyerMaker: json['m'] as bool,
    );
  }

  /// Crea modelo desde respuesta de trade de Binance (REST)
  factory TradeModel.fromRest(Map<String, dynamic> json) {
    final price = double.parse(json['price'] as String);
    final quantity = double.parse(json['qty'] as String);

    return TradeModel(
      id: json['id'] as int,
      price: price,
      quantity: quantity,
      quoteQuantity: json['quoteQty'] != null
          ? double.parse(json['quoteQty'] as String)
          : price * quantity,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['time'] as int),
      isBuyerMaker: json['isBuyerMaker'] as bool,
    );
  }

  /// Serialización estándar para almacenamiento local
  factory TradeModel.fromJson(Map<String, dynamic> json) =>
      _$TradeModelFromJson(json);

  Map<String, dynamic> toJson() => _$TradeModelToJson(this);

  /// Convierte entidad de dominio a modelo
  factory TradeModel.fromEntity(TradeEntity entity) {
    return TradeModel(
      id: entity.id,
      price: entity.price,
      quantity: entity.quantity,
      quoteQuantity: entity.quoteQuantity,
      timestamp: entity.timestamp,
      isBuyerMaker: entity.isBuyerMaker,
    );
  }

  /// Convierte a entidad de dominio
  TradeEntity toEntity() => this;
}
