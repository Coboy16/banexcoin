import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import '../datasources/datasources.dart';

class MarketDataRepositoryImpl implements MarketDataRepository {
  final BinanceWebSocketDataSource _webSocketDataSource;
  final BinanceRestDataSource _restDataSource;

  // Cache local para datos más recientes
  final Map<String, TickerEntity> _tickerCache = {};
  final Map<String, MiniTickerEntity> _miniTickerCache = {};
  final Map<String, DepthEntity> _depthCache = {};

  // Timestamps de última actualización
  final Map<String, DateTime> _lastTickerUpdate = {};
  final Map<String, DateTime> _lastMiniTickerUpdate = {};
  final Map<String, DateTime> _lastDepthUpdate = {};

  // Configuración de cache
  static const Duration _cacheExpiration = Duration(minutes: 5);
  static const Duration _throttleInterval = Duration(milliseconds: 100);

  // Controladores para throttling
  final Map<String, Timer> _throttleTimers = {};
  final Map<String, StreamController<TickerEntity>>
  _throttledTickerControllers = {};
  final Map<String, StreamController<MiniTickerEntity>>
  _throttledMiniTickerControllers = {};
  final Map<String, StreamController<DepthEntity>> _throttledDepthControllers =
      {};

  MarketDataRepositoryImpl({
    required BinanceWebSocketDataSource webSocketDataSource,
    required BinanceRestDataSource restDataSource,
  }) : _webSocketDataSource = webSocketDataSource,
       _restDataSource = restDataSource;

  @override
  Stream<TickerEntity> getTickerStream(String symbol) {
    final streamKey = symbol.toLowerCase();

    if (!_throttledTickerControllers.containsKey(streamKey)) {
      _throttledTickerControllers[streamKey] =
          StreamController<TickerEntity>.broadcast();

      // Obtener datos iniciales desde REST API
      _loadInitialTickerData(symbol);

      // Configurar stream de WebSocket con throttling
      _webSocketDataSource
          .getTickerStream(symbol)
          .listen(
            (tickerModel) {
              final entity = tickerModel.toEntity();
              _updateTickerCache(symbol, entity);
              _throttleTickerUpdate(streamKey, entity);
            },
            onError: (error) {
              debugPrint('Error en ticker stream para $symbol: $error');
              _handleStreamError(symbol, _StreamType.ticker);
            },
          );
    }

    return _throttledTickerControllers[streamKey]!.stream;
  }

  @override
  Stream<MiniTickerEntity> getMiniTickerStream(String symbol) {
    final streamKey = symbol.toLowerCase();

    if (!_throttledMiniTickerControllers.containsKey(streamKey)) {
      _throttledMiniTickerControllers[streamKey] =
          StreamController<MiniTickerEntity>.broadcast();

      // Configurar stream de WebSocket con throttling
      _webSocketDataSource
          .getMiniTickerStream(symbol)
          .listen(
            (miniTickerModel) {
              final entity = miniTickerModel.toEntity();
              _updateMiniTickerCache(symbol, entity);
              _throttleMiniTickerUpdate(streamKey, entity);
            },
            onError: (error) {
              debugPrint('Error en mini ticker stream para $symbol: $error');
              _handleStreamError(symbol, _StreamType.miniTicker);
            },
          );
    }

    return _throttledMiniTickerControllers[streamKey]!.stream;
  }

  @override
  Stream<DepthEntity> getDepthStream(String symbol) {
    final streamKey = symbol.toLowerCase();

    if (!_throttledDepthControllers.containsKey(streamKey)) {
      _throttledDepthControllers[streamKey] =
          StreamController<DepthEntity>.broadcast();

      // Obtener datos iniciales desde REST API
      _loadInitialDepthData(symbol);

      // Configurar stream de WebSocket con throttling
      _webSocketDataSource
          .getDepthStream(symbol)
          .listen(
            (depthModel) {
              final entity = depthModel.toEntity();
              _updateDepthCache(symbol, entity);
              _throttleDepthUpdate(streamKey, entity);
            },
            onError: (error) {
              debugPrint('Error en depth stream para $symbol: $error');
              _handleStreamError(symbol, _StreamType.depth);
            },
          );
    }

    return _throttledDepthControllers[streamKey]!.stream;
  }

  @override
  Future<TickerEntity> getInitialTickerData(String symbol) async {
    try {
      // Verificar cache primero
      final cached = _getCachedTicker(symbol);
      if (cached != null) return cached;

      // Obtener desde REST API
      final tickerModel = await _restDataSource.getTicker24hr(symbol);
      final entity = tickerModel.toEntity();

      _updateTickerCache(symbol, entity);
      return entity;
    } catch (e) {
      debugPrint('Error obteniendo datos iniciales de ticker para $symbol: $e');
      rethrow;
    }
  }

  @override
  Future<List<TickerEntity>> getInitialMarketData(List<String> symbols) async {
    try {
      final List<TickerEntity> results = [];

      // Obtener todos los tickers de una vez
      final allTickers = await _restDataSource.getAllTickers24hr();

      // Filtrar los símbolos solicitados
      for (final symbol in symbols) {
        final ticker = allTickers.firstWhere(
          (t) => t.symbol.toUpperCase() == symbol.toUpperCase(),
          orElse: () => throw Exception('Símbolo $symbol no encontrado'),
        );

        final entity = ticker.toEntity();
        _updateTickerCache(symbol, entity);
        results.add(entity);
      }

      return results;
    } catch (e) {
      debugPrint('Error obteniendo datos iniciales del mercado: $e');
      rethrow;
    }
  }

  @override
  Future<ExchangeInfo> getExchangeInfo() async {
    try {
      final exchangeInfoModel = await _restDataSource.getExchangeInfo();

      return ExchangeInfo(
        timezone: exchangeInfoModel.timezone,
        serverTime: DateTime.fromMillisecondsSinceEpoch(
          exchangeInfoModel.serverTime,
        ),
        symbols: exchangeInfoModel.symbols.map((symbolModel) {
          return SymbolInfo(
            symbol: symbolModel.symbol,
            baseAsset: symbolModel.baseAsset,
            quoteAsset: symbolModel.quoteAsset,
            isActive: symbolModel.isTrading,
            priceDecimalPlaces: symbolModel.priceDecimalPlaces,
            quantityDecimalPlaces: symbolModel.baseAssetPrecision,
          );
        }).toList(),
      );
    } catch (e) {
      debugPrint('Error obteniendo información del exchange: $e');
      rethrow;
    }
  }

  @override
  Future<double> getCurrentPrice(String symbol) async {
    try {
      // Verificar cache primero
      final cached = _getCachedTicker(symbol);
      if (cached != null) {
        return cached.lastPriceAsDouble;
      }

      // Obtener desde REST API
      return await _restDataSource.getCurrentPrice(symbol);
    } catch (e) {
      debugPrint('Error obteniendo precio actual para $symbol: $e');
      rethrow;
    }
  }

  @override
  Future<DepthEntity> getOrderBook(String symbol) async {
    try {
      // Verificar cache primero
      final cached = _getCachedDepth(symbol);
      if (cached != null) return cached;

      // Obtener desde REST API
      final depthModel = await _restDataSource.getOrderBook(symbol);
      final entity = depthModel.toEntity();

      _updateDepthCache(symbol, entity);
      return entity;
    } catch (e) {
      debugPrint('Error obteniendo libro de órdenes para $symbol: $e');
      rethrow;
    }
  }

  @override
  Future<bool> checkConnectivity() async {
    try {
      return await _restDataSource.checkConnectivity();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<MarketStatistics> getMarketStatistics() async {
    try {
      final allTickers = await _restDataSource.getAllTickers24hr();

      double totalVolume = 0;
      int gainers = 0;
      int losers = 0;
      int stable = 0;

      for (final ticker in allTickers) {
        final volume = double.tryParse(ticker.quoteVolume) ?? 0;
        final changePercent = double.tryParse(ticker.priceChangePercent) ?? 0;

        totalVolume += volume;

        if (changePercent > 0) {
          gainers++;
        } else if (changePercent < 0) {
          losers++;
        } else {
          stable++;
        }
      }

      return MarketStatistics(
        totalMarketCap: 0, // Binance no proporciona market cap total
        total24hVolume: totalVolume,
        totalTradingPairs: allTickers.length,
        gainersCount: gainers,
        losersCount: losers,
        stableCount: stable,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error obteniendo estadísticas del mercado: $e');
      rethrow;
    }
  }

  /// Maneja throttling para actualizaciones de ticker
  void _throttleTickerUpdate(String streamKey, TickerEntity entity) {
    _throttleTimers[streamKey]?.cancel();
    _throttleTimers[streamKey] = Timer(_throttleInterval, () {
      if (!_throttledTickerControllers[streamKey]!.isClosed) {
        _throttledTickerControllers[streamKey]!.add(entity);
      }
    });
  }

  /// Maneja throttling para actualizaciones de mini ticker
  void _throttleMiniTickerUpdate(String streamKey, MiniTickerEntity entity) {
    final throttleKey = '${streamKey}_mini';
    _throttleTimers[throttleKey]?.cancel();
    _throttleTimers[throttleKey] = Timer(_throttleInterval, () {
      if (!_throttledMiniTickerControllers[streamKey]!.isClosed) {
        _throttledMiniTickerControllers[streamKey]!.add(entity);
      }
    });
  }

  /// Maneja throttling para actualizaciones de depth
  void _throttleDepthUpdate(String streamKey, DepthEntity entity) {
    final throttleKey = '${streamKey}_depth';
    _throttleTimers[throttleKey]?.cancel();
    _throttleTimers[throttleKey] = Timer(_throttleInterval, () {
      if (!_throttledDepthControllers[streamKey]!.isClosed) {
        _throttledDepthControllers[streamKey]!.add(entity);
      }
    });
  }

  /// Carga datos iniciales de ticker desde REST API
  Future<void> _loadInitialTickerData(String symbol) async {
    try {
      final entity = await getInitialTickerData(symbol);
      final streamKey = symbol.toLowerCase();

      if (!_throttledTickerControllers[streamKey]!.isClosed) {
        _throttledTickerControllers[streamKey]!.add(entity);
      }
    } catch (e) {
      debugPrint('Error cargando datos iniciales de ticker para $symbol: $e');
    }
  }

  /// Carga datos iniciales de depth desde REST API
  Future<void> _loadInitialDepthData(String symbol) async {
    try {
      final entity = await getOrderBook(symbol);
      final streamKey = symbol.toLowerCase();

      if (!_throttledDepthControllers[streamKey]!.isClosed) {
        _throttledDepthControllers[streamKey]!.add(entity);
      }
    } catch (e) {
      debugPrint('Error cargando datos iniciales de depth para $symbol: $e');
    }
  }

  /// Actualiza cache de ticker
  void _updateTickerCache(String symbol, TickerEntity entity) {
    _tickerCache[symbol.toLowerCase()] = entity;
    _lastTickerUpdate[symbol.toLowerCase()] = DateTime.now();
  }

  /// Actualiza cache de mini ticker
  void _updateMiniTickerCache(String symbol, MiniTickerEntity entity) {
    _miniTickerCache[symbol.toLowerCase()] = entity;
    _lastMiniTickerUpdate[symbol.toLowerCase()] = DateTime.now();
  }

  /// Actualiza cache de depth
  void _updateDepthCache(String symbol, DepthEntity entity) {
    _depthCache[symbol.toLowerCase()] = entity;
    _lastDepthUpdate[symbol.toLowerCase()] = DateTime.now();
  }

  /// Obtiene ticker desde cache si está vigente
  TickerEntity? _getCachedTicker(String symbol) {
    final key = symbol.toLowerCase();
    final lastUpdate = _lastTickerUpdate[key];

    if (lastUpdate != null &&
        DateTime.now().difference(lastUpdate) < _cacheExpiration) {
      return _tickerCache[key];
    }

    return null;
  }

  /// Obtiene mini ticker desde cache si está vigente
  MiniTickerEntity? _getCachedMiniTicker(String symbol) {
    final key = symbol.toLowerCase();
    final lastUpdate = _lastMiniTickerUpdate[key];

    if (lastUpdate != null &&
        DateTime.now().difference(lastUpdate) < _cacheExpiration) {
      return _miniTickerCache[key];
    }

    return null;
  }

  /// Obtiene depth desde cache si está vigente
  DepthEntity? _getCachedDepth(String symbol) {
    final key = symbol.toLowerCase();
    final lastUpdate = _lastDepthUpdate[key];

    if (lastUpdate != null &&
        DateTime.now().difference(lastUpdate) < _cacheExpiration) {
      return _depthCache[key];
    }

    return null;
  }

  /// Maneja errores de stream y implementa fallback
  void _handleStreamError(String symbol, _StreamType streamType) {
    debugPrint('Manejando error de stream $streamType para $symbol');

    // Intentar obtener datos desde REST API como fallback
    Timer(const Duration(seconds: 5), () async {
      try {
        switch (streamType) {
          case _StreamType.ticker:
            final entity = await getInitialTickerData(symbol);
            final streamKey = symbol.toLowerCase();
            if (!_throttledTickerControllers[streamKey]!.isClosed) {
              _throttledTickerControllers[streamKey]!.add(entity);
            }
            break;
          case _StreamType.miniTicker:
            // Usar datos de ticker como fallback para mini ticker
            final ticker = await getInitialTickerData(symbol);
            final miniTicker = MiniTickerEntity(
              symbol: ticker.symbol,
              closePrice: ticker.lastPrice,
              openPrice: ticker.openPrice,
              highPrice: ticker.highPrice,
              lowPrice: ticker.lowPrice,
              volume: ticker.volume,
              quoteVolume: ticker.quoteVolume,
            );
            final streamKey = symbol.toLowerCase();
            if (!_throttledMiniTickerControllers[streamKey]!.isClosed) {
              _throttledMiniTickerControllers[streamKey]!.add(miniTicker);
            }
            break;
          case _StreamType.depth:
            final entity = await getOrderBook(symbol);
            final streamKey = symbol.toLowerCase();
            if (!_throttledDepthControllers[streamKey]!.isClosed) {
              _throttledDepthControllers[streamKey]!.add(entity);
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
    for (final controller in _throttledTickerControllers.values) {
      if (!controller.isClosed) {
        await controller.close();
      }
    }
    _throttledTickerControllers.clear();

    for (final controller in _throttledMiniTickerControllers.values) {
      if (!controller.isClosed) {
        await controller.close();
      }
    }
    _throttledMiniTickerControllers.clear();

    for (final controller in _throttledDepthControllers.values) {
      if (!controller.isClosed) {
        await controller.close();
      }
    }
    _throttledDepthControllers.clear();

    // Limpiar caches
    _tickerCache.clear();
    _miniTickerCache.clear();
    _depthCache.clear();
    _lastTickerUpdate.clear();
    _lastMiniTickerUpdate.clear();
    _lastDepthUpdate.clear();

    // Cerrar WebSocket datasource
    await _webSocketDataSource.dispose();

    debugPrint('MarketDataRepository cerrado completamente');
  }

  /// Obtiene estadísticas de rendimiento del repositorio
  Map<String, dynamic> getPerformanceStats() {
    return {
      'tickerCacheSize': _tickerCache.length,
      'miniTickerCacheSize': _miniTickerCache.length,
      'depthCacheSize': _depthCache.length,
      'activeTickerStreams': _throttledTickerControllers.length,
      'activeMiniTickerStreams': _throttledMiniTickerControllers.length,
      'activeDepthStreams': _throttledDepthControllers.length,
      'activeThrottleTimers': _throttleTimers.length,
    };
  }
}

enum _StreamType { ticker, miniTicker, depth }
