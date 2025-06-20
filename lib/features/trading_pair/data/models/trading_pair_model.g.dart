// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trading_pair_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TradingPairModel _$TradingPairModelFromJson(Map<String, dynamic> json) =>
    TradingPairModel(
      symbol: json['symbol'] as String,
      baseAsset: json['baseAsset'] as String,
      quoteAsset: json['quoteAsset'] as String,
      currentPrice: (json['currentPrice'] as num).toDouble(),
      priceChange24h: (json['priceChange24h'] as num).toDouble(),
      priceChangePercent24h: (json['priceChangePercent24h'] as num).toDouble(),
      openPrice: (json['openPrice'] as num).toDouble(),
      highPrice24h: (json['highPrice24h'] as num).toDouble(),
      lowPrice24h: (json['lowPrice24h'] as num).toDouble(),
      volume24h: (json['volume24h'] as num).toDouble(),
      quoteVolume24h: (json['quoteVolume24h'] as num).toDouble(),
      lastUpdateTime: DateTime.parse(json['lastUpdateTime'] as String),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$TradingPairModelToJson(TradingPairModel instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'baseAsset': instance.baseAsset,
      'quoteAsset': instance.quoteAsset,
      'currentPrice': instance.currentPrice,
      'priceChange24h': instance.priceChange24h,
      'priceChangePercent24h': instance.priceChangePercent24h,
      'openPrice': instance.openPrice,
      'highPrice24h': instance.highPrice24h,
      'lowPrice24h': instance.lowPrice24h,
      'volume24h': instance.volume24h,
      'quoteVolume24h': instance.quoteVolume24h,
      'lastUpdateTime': instance.lastUpdateTime.toIso8601String(),
      'description': instance.description,
    };
