// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'depth_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DepthModel _$DepthModelFromJson(Map<String, dynamic> json) => DepthModel(
  lastUpdateId: (json['lastUpdateId'] as num).toInt(),
  bids: (json['bids'] as List<dynamic>)
      .map((e) => OrderLevelModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  asks: (json['asks'] as List<dynamic>)
      .map((e) => OrderLevelModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DepthModelToJson(DepthModel instance) =>
    <String, dynamic>{
      'lastUpdateId': instance.lastUpdateId,
      'bids': instance.bids,
      'asks': instance.asks,
    };

OrderLevelModel _$OrderLevelModelFromJson(Map<String, dynamic> json) =>
    OrderLevelModel(
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toDouble(),
    );

Map<String, dynamic> _$OrderLevelModelToJson(OrderLevelModel instance) =>
    <String, dynamic>{'price': instance.price, 'quantity': instance.quantity};
