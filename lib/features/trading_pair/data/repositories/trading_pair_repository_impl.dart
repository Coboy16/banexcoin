import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import '../datasources/datasources.dart';
import '../models/models.dart';

class TradingPairRepositoryImpl implements TradingPairRepository {
  final TradingPairRemoteDataSource _remoteDataSource;

  // Cache local para datos más recientes
  final Map<String, TradingPairEntity> _tradingPairCache = {};
  final Map<String, PriceStatsEntity> _priceStatsCache = {};
  final Map<String, List<KlineEntity>> _klineCache = {};
  final Map<String, List<TradeEntity>> _tradesCache = {};

  // Timestamps de última actualización
  final Map<String, DateTime> _lastTradingPairUpdate = {};
  final Map<String, DateTime> _lastPriceStatsUpdate = {};
  final Map<String, DateTime> _lastKlineUpdate = {};
  final Map<String, DateTime> _lastTradesUpdate = {};

  // Configuración de cache
  static const Duration _cacheExpiration = Duration(minutes: 5);
  static const Duration _throttleInterval = Duration(milliseconds: 100);

  // Controladores para throttling
  final Map<String, Timer> _throttleTimers = {};
  final Map<String, StreamController<TradingPairEntity>>
  _throttledTradingPairControllers = {};
  final Map<String, StreamController<PriceStatsEntity>>
  _throttledPriceStatsControllers = {};
  final Map<String, StreamController<List<KlineEntity>>>
  _throttledKlineControllers = {};
  final Map<String, StreamController<List<TradeEntity>>>
  _throttledTradesControllers = {};

  TradingPairRepositoryImpl({
    required TradingPairRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Stream<TradingPairEntity> getTradingPairStream(String symbol) {
    final streamKey = symbol.toLowerCase();

    if (!_throttledTradingPairControllers.containsKey(streamKey)) {
      _throttledTradingPairControllers[streamKey] =
          StreamController<TradingPairEntity>.broadcast();

      // Obtener datos iniciales
      _loadInitialTradingPairData(symbol);

      // Configurar stream de WebSocket con throttling
      _remoteDataSource
          .getTradingPairStream(symbol)
          .listen(
            (tradingPairModel) {
              final entity = tradingPairModel.toEntity();
              _updateTradingPairCache(symbol, entity);
              _throttleTradingPairUpdate(streamKey, entity);
            },
            onError: (error) {
              debugPrint('Error en trading pair stream para $symbol: $error');
              _handleStreamError(symbol, _StreamType.tradingPair);
            },
          );
    }

    return _throttledTradingPairControllers[streamKey]!.stream;
  }

  @override
  Stream<PriceStatsEntity> getPriceStatsStream(String symbol) {
    final streamKey = symbol.toLowerCase();

    if (!_throttledPriceStatsControllers.containsKey(streamKey)) {
      _throttledPriceStatsControllers[streamKey] =
          StreamController<PriceStatsEntity>.broadcast();

      // Obtener datos iniciales
      _loadInitialPriceStatsData(symbol);

      // Configurar stream de WebSocket con throttling
      _remoteDataSource
          .getPriceStatsStream(symbol)
          .listen(
            (priceStatsModel) {
              final entity = priceStatsModel.toEntity();
              _updatePriceStatsCache(symbol, entity);
              _throttlePriceStatsUpdate(streamKey, entity);
            },
            onError: (error) {
              debugPrint('Error en price stats stream para $symbol: $error');
              _handleStreamError(symbol, _StreamType.priceStats);
            },
          );
    }

    return _throttledPriceStatsControllers[streamKey]!.stream;
  }

  @override
  Stream<List<KlineEntity>> getKlineStream({
    required String symbol,
    required String interval,
    int? limit,
  }) {
    final streamKey = '${symbol.toLowerCase()}_$interval';

    if (!_throttledKlineControllers.containsKey(streamKey)) {
      _throttledKlineControllers[streamKey] =
          StreamController<List<KlineEntity>>.broadcast();

      // Obtener datos iniciales
      _loadInitialKlineData(symbol, interval, limit);

      // Configurar stream de WebSocket con throttling
      _remoteDataSource
          .getKlineStream(symbol: symbol, interval: interval, limit: limit)
          .listen(
            (klineModels) {
              final entities = klineModels
                  .map((model) => model.toEntity())
                  .toList();
              _updateKlineCache(symbol, interval, entities);
              _throttleKlineUpdate(streamKey, entities);
            },
            onError: (error) {
              debugPrint('Error en kline stream para $symbol: $error');
              _handleStreamError(symbol, _StreamType.kline);
            },
          );
    }

    return _throttledKlineControllers[streamKey]!.stream;
  }

  @override
  Stream<List<TradeEntity>> getRecentTradesStream(String symbol) {
    final streamKey = symbol.toLowerCase();

    if (!_throttledTradesControllers.containsKey(streamKey)) {
      _throttledTradesControllers[streamKey] =
          StreamController<List<TradeEntity>>.broadcast();

      // Obtener datos iniciales
      _loadInitialTradesData(symbol);

      // Configurar stream de WebSocket con throttling
      _remoteDataSource
          .getRecentTradesStream(symbol)
          .listen(
            (tradeModels) {
              final entities = tradeModels
                  .map((model) => model.toEntity())
                  .toList();
              _updateTradesCache(symbol, entities);
              _throttleTradesUpdate(streamKey, entities);
            },
            onError: (error) {
              debugPrint('Error en trades stream para $symbol: $error');
              _handleStreamError(symbol, _StreamType.trades);
            },
          );
    }

    return _throttledTradesControllers[streamKey]!.stream;
  }

  @override
  Future<TradingPairEntity> getInitialTradingPairData(String symbol) async {
    try {
      // Verificar cache primero
      final cached = _getCachedTradingPair(symbol);
      if (cached != null) return cached;

      // Obtener desde API
      final tradingPairModel = await _remoteDataSource
          .getInitialTradingPairData(symbol);
      final entity = tradingPairModel.toEntity();

      _updateTradingPairCache(symbol, entity);
      return entity;
    } catch (e) {
      debugPrint(
        'Error obteniendo datos iniciales de trading pair para $symbol: $e',
      );
      rethrow;
    }
  }

  @override
  Future<PriceStatsEntity> getInitialPriceStats(String symbol) async {
    try {
      // Verificar cache primero
      final cached = _getCachedPriceStats(symbol);
      if (cached != null) return cached;

      // Obtener desde API
      final priceStatsModel = await _remoteDataSource.getInitialPriceStats(
        symbol,
      );
      final entity = priceStatsModel.toEntity();

      _updatePriceStatsCache(symbol, entity);
      return entity;
    } catch (e) {
      debugPrint(
        'Error obteniendo estadísticas iniciales de precio para $symbol: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<KlineEntity>> getHistoricalKlines({
    required String symbol,
    required String interval,
    int? limit,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
      // Verificar cache primero
      final cached = _getCachedKlines(symbol, interval);
      if (cached != null && cached.isNotEmpty) return cached;

      // Obtener desde API
      final klineModels = await _remoteDataSource.getHistoricalKlines(
        symbol: symbol,
        interval: interval,
        limit: limit,
        startTime: startTime,
        endTime: endTime,
      );

      final entities = klineModels.map((model) => model.toEntity()).toList();
      _updateKlineCache(symbol, interval, entities);
      return entities;
    } catch (e) {
      debugPrint('Error obteniendo klines históricos para $symbol: $e');
      rethrow;
    }
  }

  @override
  Future<List<TradeEntity>> getInitialRecentTrades({
    required String symbol,
    int limit = 50,
  }) async {
    try {
      // Verificar cache primero
      final cached = _getCachedTrades(symbol);
      if (cached != null && cached.isNotEmpty) return cached;

      // Obtener desde API
      final tradeModels = await _remoteDataSource.getInitialRecentTrades(
        symbol: symbol,
        limit: limit,
      );

      final entities = tradeModels.map((model) => model.toEntity()).toList();
      _updateTradesCache(symbol, entities);
      return entities;
    } catch (e) {
      debugPrint('Error obteniendo trades iniciales para $symbol: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isValidSymbol(String symbol) async {
    try {
      return await _remoteDataSource.isValidSymbol(symbol);
    } catch (e) {
      debugPrint('Error validando símbolo $symbol: $e');
      return false;
    }
  }

  @override
  Future<SymbolInfoTraiding> getSymbolInfo(String symbol) async {
    try {
      final symbolInfoData = await _remoteDataSource.getSymbolInfo(symbol);

      return SymbolInfoTraiding(
        symbol: symbolInfoData['symbol'] as String,
        baseAsset: symbolInfoData['baseAsset'] as String,
        quoteAsset: symbolInfoData['quoteAsset'] as String,
        status: symbolInfoData['status'] as String,
        baseAssetPrecision: symbolInfoData['baseAssetPrecision'] as int,
        quoteAssetPrecision: symbolInfoData['quoteAssetPrecision'] as int,
        isActive: symbolInfoData['status'] == 'TRADING',
      );
    } catch (e) {
      debugPrint('Error obteniendo información del símbolo $symbol: $e');
      rethrow;
    }
  }

  /// Maneja throttling para actualizaciones de trading pair
  void _throttleTradingPairUpdate(String streamKey, TradingPairEntity entity) {
    final throttleKey = '${streamKey}_trading_pair';
    _throttleTimers[throttleKey]?.cancel();
    _throttleTimers[throttleKey] = Timer(_throttleInterval, () {
      if (!_throttledTradingPairControllers[streamKey]!.isClosed) {
        _throttledTradingPairControllers[streamKey]!.add(entity);
      }
    });
  }

  /// Maneja throttling para actualizaciones de price stats
  void _throttlePriceStatsUpdate(String streamKey, PriceStatsEntity entity) {
    final throttleKey = '${streamKey}_price_stats';
    _throttleTimers[throttleKey]?.cancel();
    _throttleTimers[throttleKey] = Timer(_throttleInterval, () {
      if (!_throttledPriceStatsControllers[streamKey]!.isClosed) {
        _throttledPriceStatsControllers[streamKey]!.add(entity);
      }
    });
  }

  /// Maneja throttling para actualizaciones de klines
  void _throttleKlineUpdate(String streamKey, List<KlineEntity> entities) {
    final throttleKey = '${streamKey}_kline';
    _throttleTimers[throttleKey]?.cancel();
    _throttleTimers[throttleKey] = Timer(_throttleInterval, () {
      if (!_throttledKlineControllers[streamKey]!.isClosed) {
        _throttledKlineControllers[streamKey]!.add(entities);
      }
    });
  }

  /// Maneja throttling para actualizaciones de trades
  void _throttleTradesUpdate(String streamKey, List<TradeEntity> entities) {
    final throttleKey = '${streamKey}_trades';
    _throttleTimers[throttleKey]?.cancel();
    _throttleTimers[throttleKey] = Timer(_throttleInterval, () {
      if (!_throttledTradesControllers[streamKey]!.isClosed) {
        _throttledTradesControllers[streamKey]!.add(entities);
      }
    });
  }

  /// Carga datos iniciales de trading pair desde API
  Future<void> _loadInitialTradingPairData(String symbol) async {
    try {
      final entity = await getInitialTradingPairData(symbol);
      final streamKey = symbol.toLowerCase();

      if (!_throttledTradingPairControllers[streamKey]!.isClosed) {
        _throttledTradingPairControllers[streamKey]!.add(entity);
      }
    } catch (e) {
      debugPrint(
        'Error cargando datos iniciales de trading pair para $symbol: $e',
      );
    }
  }

  /// Carga datos iniciales de price stats desde API
  Future<void> _loadInitialPriceStatsData(String symbol) async {
    try {
      final entity = await getInitialPriceStats(symbol);
      final streamKey = symbol.toLowerCase();

      if (!_throttledPriceStatsControllers[streamKey]!.isClosed) {
        _throttledPriceStatsControllers[streamKey]!.add(entity);
      }
    } catch (e) {
      debugPrint(
        'Error cargando datos iniciales de price stats para $symbol: $e',
      );
    }
  }

  /// Carga datos iniciales de klines desde API
  Future<void> _loadInitialKlineData(
    String symbol,
    String interval,
    int? limit,
  ) async {
    try {
      final entities = await getHistoricalKlines(
        symbol: symbol,
        interval: interval,
        limit: limit ?? 100,
      );
      final streamKey = '${symbol.toLowerCase()}_$interval';

      if (!_throttledKlineControllers[streamKey]!.isClosed) {
        _throttledKlineControllers[streamKey]!.add(entities);
      }
    } catch (e) {
      debugPrint('Error cargando datos iniciales de klines para $symbol: $e');
    }
  }

  /// Carga datos iniciales de trades desde API
  Future<void> _loadInitialTradesData(String symbol) async {
    try {
      final entities = await getInitialRecentTrades(symbol: symbol);
      final streamKey = symbol.toLowerCase();

      if (!_throttledTradesControllers[streamKey]!.isClosed) {
        _throttledTradesControllers[streamKey]!.add(entities);
      }
    } catch (e) {
      debugPrint('Error cargando datos iniciales de trades para $symbol: $e');
    }
  }

  /// Actualiza cache de trading pair
  void _updateTradingPairCache(String symbol, TradingPairEntity entity) {
    _tradingPairCache[symbol.toLowerCase()] = entity;
    _lastTradingPairUpdate[symbol.toLowerCase()] = DateTime.now();
  }

  /// Actualiza cache de price stats
  void _updatePriceStatsCache(String symbol, PriceStatsEntity entity) {
    _priceStatsCache[symbol.toLowerCase()] = entity;
    _lastPriceStatsUpdate[symbol.toLowerCase()] = DateTime.now();
  }

  /// Actualiza cache de klines
  void _updateKlineCache(
    String symbol,
    String interval,
    List<KlineEntity> entities,
  ) {
    final key = '${symbol.toLowerCase()}_$interval';
    _klineCache[key] = entities;
    _lastKlineUpdate[key] = DateTime.now();
  }

  /// Actualiza cache de trades
  void _updateTradesCache(String symbol, List<TradeEntity> entities) {
    _tradesCache[symbol.toLowerCase()] = entities;
    _lastTradesUpdate[symbol.toLowerCase()] = DateTime.now();
  }

  /// Obtiene trading pair desde cache si está vigente
  TradingPairEntity? _getCachedTradingPair(String symbol) {
    final key = symbol.toLowerCase();
    final lastUpdate = _lastTradingPairUpdate[key];

    if (lastUpdate != null &&
        DateTime.now().difference(lastUpdate) < _cacheExpiration) {
      return _tradingPairCache[key];
    }

    return null;
  }

  /// Obtiene price stats desde cache si está vigente
  PriceStatsEntity? _getCachedPriceStats(String symbol) {
    final key = symbol.toLowerCase();
    final lastUpdate = _lastPriceStatsUpdate[key];

    if (lastUpdate != null &&
        DateTime.now().difference(lastUpdate) < _cacheExpiration) {
      return _priceStatsCache[key];
    }

    return null;
  }

  /// Obtiene klines desde cache si está vigente
  List<KlineEntity>? _getCachedKlines(String symbol, String interval) {
    final key = '${symbol.toLowerCase()}_$interval';
    final lastUpdate = _lastKlineUpdate[key];

    if (lastUpdate != null &&
        DateTime.now().difference(lastUpdate) < _cacheExpiration) {
      return _klineCache[key];
    }

    return null;
  }

  /// Obtiene trades desde cache si está vigente
  List<TradeEntity>? _getCachedTrades(String symbol) {
    final key = symbol.toLowerCase();
    final lastUpdate = _lastTradesUpdate[key];

    if (lastUpdate != null &&
        DateTime.now().difference(lastUpdate) < _cacheExpiration) {
      return _tradesCache[key];
    }

    return null;
  }

  /// Maneja errores de stream y implementa fallback
  void _handleStreamError(String symbol, _StreamType streamType) {
    debugPrint('Manejando error de stream $streamType para $symbol');

    // Intentar obtener datos desde API como fallback
    Timer(const Duration(seconds: 5), () async {
      try {
        switch (streamType) {
          case _StreamType.tradingPair:
            final entity = await getInitialTradingPairData(symbol);
            final streamKey = symbol.toLowerCase();
            if (!_throttledTradingPairControllers[streamKey]!.isClosed) {
              _throttledTradingPairControllers[streamKey]!.add(entity);
            }
            break;
          case _StreamType.priceStats:
            final entity = await getInitialPriceStats(symbol);
            final streamKey = symbol.toLowerCase();
            if (!_throttledPriceStatsControllers[streamKey]!.isClosed) {
              _throttledPriceStatsControllers[streamKey]!.add(entity);
            }
            break;
          case _StreamType.kline:
            final entities = await getHistoricalKlines(
              symbol: symbol,
              interval: '1h',
              limit: 100,
            );
            final streamKey = '${symbol.toLowerCase()}_1h';
            if (!_throttledKlineControllers[streamKey]!.isClosed) {
              _throttledKlineControllers[streamKey]!.add(entities);
            }
            break;
          case _StreamType.trades:
            final entities = await getInitialRecentTrades(symbol: symbol);
            final streamKey = symbol.toLowerCase();
            if (!_throttledTradesControllers[streamKey]!.isClosed) {
              _throttledTradesControllers[streamKey]!.add(entities);
            }
            break;
        }
      } catch (e) {
        debugPrint('Error en fallback para $symbol: $e');
      }
    });
  }

  @override
  Future<void> dispose() async {
    // Cancelar todos los timers de throttle
    for (final timer in _throttleTimers.values) {
      timer.cancel();
    }
    _throttleTimers.clear();

    // Cerrar controladores de stream
    for (final controller in _throttledTradingPairControllers.values) {
      if (!controller.isClosed) {
        await controller.close();
      }
    }
    _throttledTradingPairControllers.clear();

    for (final controller in _throttledPriceStatsControllers.values) {
      if (!controller.isClosed) {
        await controller.close();
      }
    }
    _throttledPriceStatsControllers.clear();

    for (final controller in _throttledKlineControllers.values) {
      if (!controller.isClosed) {
        await controller.close();
      }
    }
    _throttledKlineControllers.clear();

    for (final controller in _throttledTradesControllers.values) {
      if (!controller.isClosed) {
        await controller.close();
      }
    }
    _throttledTradesControllers.clear();

    // Limpiar caches
    _tradingPairCache.clear();
    _priceStatsCache.clear();
    _klineCache.clear();
    _tradesCache.clear();
    _lastTradingPairUpdate.clear();
    _lastPriceStatsUpdate.clear();
    _lastKlineUpdate.clear();
    _lastTradesUpdate.clear();

    // Cerrar datasource remoto
    await _remoteDataSource.dispose();

    debugPrint('TradingPairRepository cerrado completamente');
  }

  /// Obtiene estadísticas de rendimiento del repositorio
  Map<String, dynamic> getPerformanceStats() {
    return {
      'tradingPairCacheSize': _tradingPairCache.length,
      'priceStatsCacheSize': _priceStatsCache.length,
      'klineCacheSize': _klineCache.length,
      'tradesCacheSize': _tradesCache.length,
      'activeTradingPairStreams': _throttledTradingPairControllers.length,
      'activePriceStatsStreams': _throttledPriceStatsControllers.length,
      'activeKlineStreams': _throttledKlineControllers.length,
      'activeTradesStreams': _throttledTradesControllers.length,
      'activeThrottleTimers': _throttleTimers.length,
    };
  }
}

enum _StreamType { tradingPair, priceStats, kline, trades }
