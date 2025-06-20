// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticker_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TickerModel _$TickerModelFromJson(Map<String, dynamic> json) => TickerModel(
  symbol: json['symbol'] as String,
  priceChange: json['priceChange'] as String,
  priceChangePercent: json['priceChangePercent'] as String,
  weightedAvgPrice: json['weightedAvgPrice'] as String,
  prevClosePrice: json['prevClosePrice'] as String,
  lastPrice: json['lastPrice'] as String,
  lastQty: json['lastQty'] as String,
  bidPrice: json['bidPrice'] as String,
  bidQty: json['bidQty'] as String,
  askPrice: json['askPrice'] as String,
  askQty: json['askQty'] as String,
  openPrice: json['openPrice'] as String,
  highPrice: json['highPrice'] as String,
  lowPrice: json['lowPrice'] as String,
  volume: json['volume'] as String,
  quoteVolume: json['quoteVolume'] as String,
  openTime: (json['openTime'] as num).toInt(),
  closeTime: (json['closeTime'] as num).toInt(),
  firstId: (json['firstId'] as num).toInt(),
  lastId: (json['lastId'] as num).toInt(),
  count: (json['count'] as num).toInt(),
);

Map<String, dynamic> _$TickerModelToJson(TickerModel instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'priceChange': instance.priceChange,
      'priceChangePercent': instance.priceChangePercent,
      'weightedAvgPrice': instance.weightedAvgPrice,
      'prevClosePrice': instance.prevClosePrice,
      'lastPrice': instance.lastPrice,
      'lastQty': instance.lastQty,
      'bidPrice': instance.bidPrice,
      'bidQty': instance.bidQty,
      'askPrice': instance.askPrice,
      'askQty': instance.askQty,
      'openPrice': instance.openPrice,
      'highPrice': instance.highPrice,
      'lowPrice': instance.lowPrice,
      'volume': instance.volume,
      'quoteVolume': instance.quoteVolume,
      'openTime': instance.openTime,
      'closeTime': instance.closeTime,
      'firstId': instance.firstId,
      'lastId': instance.lastId,
      'count': instance.count,
    };
