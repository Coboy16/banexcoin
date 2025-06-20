// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trade_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TradeModel _$TradeModelFromJson(Map<String, dynamic> json) => TradeModel(
  id: (json['id'] as num).toInt(),
  price: (json['price'] as num).toDouble(),
  quantity: (json['quantity'] as num).toDouble(),
  quoteQuantity: (json['quoteQuantity'] as num).toDouble(),
  timestamp: DateTime.parse(json['timestamp'] as String),
  isBuyerMaker: json['isBuyerMaker'] as bool,
);

Map<String, dynamic> _$TradeModelToJson(TradeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'price': instance.price,
      'quantity': instance.quantity,
      'quoteQuantity': instance.quoteQuantity,
      'timestamp': instance.timestamp.toIso8601String(),
      'isBuyerMaker': instance.isBuyerMaker,
    };
