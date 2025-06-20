// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exchange_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExchangeInfoModel _$ExchangeInfoModelFromJson(Map<String, dynamic> json) =>
    ExchangeInfoModel(
      timezone: json['timezone'] as String,
      serverTime: (json['serverTime'] as num).toInt(),
      symbols: (json['symbols'] as List<dynamic>)
          .map((e) => SymbolInfoModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ExchangeInfoModelToJson(ExchangeInfoModel instance) =>
    <String, dynamic>{
      'timezone': instance.timezone,
      'serverTime': instance.serverTime,
      'symbols': instance.symbols,
    };

SymbolInfoModel _$SymbolInfoModelFromJson(Map<String, dynamic> json) =>
    SymbolInfoModel(
      symbol: json['symbol'] as String,
      status: json['status'] as String,
      baseAsset: json['baseAsset'] as String,
      baseAssetPrecision: (json['baseAssetPrecision'] as num).toInt(),
      quoteAsset: json['quoteAsset'] as String,
      quotePrecision: (json['quotePrecision'] as num).toInt(),
      quoteAssetPrecision: (json['quoteAssetPrecision'] as num).toInt(),
      filters: (json['filters'] as List<dynamic>)
          .map((e) => FilterModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SymbolInfoModelToJson(SymbolInfoModel instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'status': instance.status,
      'baseAsset': instance.baseAsset,
      'baseAssetPrecision': instance.baseAssetPrecision,
      'quoteAsset': instance.quoteAsset,
      'quotePrecision': instance.quotePrecision,
      'quoteAssetPrecision': instance.quoteAssetPrecision,
      'filters': instance.filters,
    };

FilterModel _$FilterModelFromJson(Map<String, dynamic> json) => FilterModel(
  filterType: json['filterType'] as String,
  minPrice: json['minPrice'] as String?,
  maxPrice: json['maxPrice'] as String?,
  tickSize: json['tickSize'] as String?,
  minQty: json['minQty'] as String?,
  maxQty: json['maxQty'] as String?,
  stepSize: json['stepSize'] as String?,
);

Map<String, dynamic> _$FilterModelToJson(FilterModel instance) =>
    <String, dynamic>{
      'filterType': instance.filterType,
      'minPrice': instance.minPrice,
      'maxPrice': instance.maxPrice,
      'tickSize': instance.tickSize,
      'minQty': instance.minQty,
      'maxQty': instance.maxQty,
      'stepSize': instance.stepSize,
    };
