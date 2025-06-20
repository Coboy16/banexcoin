// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kline_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KlineModel _$KlineModelFromJson(Map<String, dynamic> json) => KlineModel(
  openTime: DateTime.parse(json['openTime'] as String),
  closeTime: DateTime.parse(json['closeTime'] as String),
  openPrice: (json['openPrice'] as num).toDouble(),
  highPrice: (json['highPrice'] as num).toDouble(),
  lowPrice: (json['lowPrice'] as num).toDouble(),
  closePrice: (json['closePrice'] as num).toDouble(),
  volume: (json['volume'] as num).toDouble(),
  quoteVolume: (json['quoteVolume'] as num).toDouble(),
  tradesCount: (json['tradesCount'] as num).toInt(),
);

Map<String, dynamic> _$KlineModelToJson(KlineModel instance) =>
    <String, dynamic>{
      'openTime': instance.openTime.toIso8601String(),
      'closeTime': instance.closeTime.toIso8601String(),
      'openPrice': instance.openPrice,
      'highPrice': instance.highPrice,
      'lowPrice': instance.lowPrice,
      'closePrice': instance.closePrice,
      'volume': instance.volume,
      'quoteVolume': instance.quoteVolume,
      'tradesCount': instance.tradesCount,
    };
