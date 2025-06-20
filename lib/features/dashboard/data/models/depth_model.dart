import 'package:json_annotation/json_annotation.dart';

import '/features/features.dart';

part 'depth_model.g.dart';

@JsonSerializable()
class DepthModel {
  const DepthModel({
    required this.lastUpdateId,
    required this.bids,
    required this.asks,
  });

  final int lastUpdateId;
  final List<OrderLevelModel> bids;
  final List<OrderLevelModel> asks;

  /// Crea modelo desde respuesta de WebSocket de Binance
  factory DepthModel.fromWebSocketJson(Map<String, dynamic> json) {
    return DepthModel(
      lastUpdateId: json['lastUpdateId'] as int,
      bids: (json['bids'] as List)
          .map((bid) => OrderLevelModel.fromList(bid as List))
          .toList(),
      asks: (json['asks'] as List)
          .map((ask) => OrderLevelModel.fromList(ask as List))
          .toList(),
    );
  }

  /// Serialización estándar para almacenamiento local
  factory DepthModel.fromJson(Map<String, dynamic> json) =>
      _$DepthModelFromJson(json);

  Map<String, dynamic> toJson() => _$DepthModelToJson(this);

  /// Convierte entidad de dominio a modelo
  factory DepthModel.fromEntity(DepthEntity entity) {
    return DepthModel(
      lastUpdateId: entity.lastUpdateId,
      bids: entity.bids.map((bid) => OrderLevelModel.fromEntity(bid)).toList(),
      asks: entity.asks.map((ask) => OrderLevelModel.fromEntity(ask)).toList(),
    );
  }

  /// Convierte a entidad de dominio
  DepthEntity toEntity() {
    return DepthEntity(
      lastUpdateId: lastUpdateId,
      bids: bids.map((bid) => bid.toEntity()).toList(),
      asks: asks.map((ask) => ask.toEntity()).toList(),
    );
  }
}

/// Modelo para nivel de orden en el libro
@JsonSerializable()
class OrderLevelModel {
  const OrderLevelModel({required this.price, required this.quantity});

  final double price;
  final double quantity;

  /// Crea desde array de Binance [precio, cantidad]
  factory OrderLevelModel.fromList(List<dynamic> list) {
    return OrderLevelModel(
      price: double.parse(list[0] as String),
      quantity: double.parse(list[1] as String),
    );
  }

  /// Serialización estándar
  factory OrderLevelModel.fromJson(Map<String, dynamic> json) =>
      _$OrderLevelModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderLevelModelToJson(this);

  /// Convierte entidad de dominio a modelo
  factory OrderLevelModel.fromEntity(OrderLevel entity) {
    return OrderLevelModel(price: entity.price, quantity: entity.quantity);
  }

  /// Convierte a entidad de dominio
  OrderLevel toEntity() {
    return OrderLevel(price: price, quantity: quantity);
  }

  /// Convierte a array para envío a API
  List<String> toList() => [price.toString(), quantity.toString()];
}
