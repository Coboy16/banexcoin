// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PriceStatsModel _$PriceStatsModelFromJson(Map<String, dynamic> json) =>
    PriceStatsModel(
      symbol: json['symbol'] as String,
      currentPrice: (json['currentPrice'] as num).toDouble(),
      openPrice: (json['openPrice'] as num).toDouble(),
      highPrice: (json['highPrice'] as num).toDouble(),
      lowPrice: (json['lowPrice'] as num).toDouble(),
      priceChange: (json['priceChange'] as num).toDouble(),
      priceChangePercent: (json['priceChangePercent'] as num).toDouble(),
      volume: (json['volume'] as num).toDouble(),
      quoteVolume: (json['quoteVolume'] as num).toDouble(),
      lastUpdateTime: DateTime.parse(json['lastUpdateTime'] as String),
    );

Map<String, dynamic> _$PriceStatsModelToJson(PriceStatsModel instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'currentPrice': instance.currentPrice,
      'openPrice': instance.openPrice,
      'highPrice': instance.highPrice,
      'lowPrice': instance.lowPrice,
      'priceChange': instance.priceChange,
      'priceChangePercent': instance.priceChangePercent,
      'volume': instance.volume,
      'quoteVolume': instance.quoteVolume,
      'lastUpdateTime': instance.lastUpdateTime.toIso8601String(),
    };
