// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mini_ticker_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MiniTickerModel _$MiniTickerModelFromJson(Map<String, dynamic> json) =>
    MiniTickerModel(
      symbol: json['symbol'] as String,
      closePrice: json['closePrice'] as String,
      openPrice: json['openPrice'] as String,
      highPrice: json['highPrice'] as String,
      lowPrice: json['lowPrice'] as String,
      volume: json['volume'] as String,
      quoteVolume: json['quoteVolume'] as String,
    );

Map<String, dynamic> _$MiniTickerModelToJson(MiniTickerModel instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'closePrice': instance.closePrice,
      'openPrice': instance.openPrice,
      'highPrice': instance.highPrice,
      'lowPrice': instance.lowPrice,
      'volume': instance.volume,
      'quoteVolume': instance.quoteVolume,
    };
