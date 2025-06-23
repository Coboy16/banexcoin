import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/models.dart';

abstract class TradingPairRemoteDataSource {
  /// Stream de ticker en tiempo real
  Stream<TradingPairModel> getTradingPairStream(String symbol);

  /// Stream de estadísticas de precio en tiempo real
  Stream<PriceStatsModel> getPriceStatsStream(String symbol);

  /// Stream de klines en tiempo real
  Stream<List<KlineModel>> getKlineStream({
    required String symbol,
    required String interval,
    int? limit,
  });

  /// Stream de trades recientes en tiempo real
  Stream<List<TradeModel>> getRecentTradesStream(String symbol);

  /// Obtiene datos iniciales del par de trading
  Future<TradingPairModel> getInitialTradingPairData(String symbol);

  /// Obtiene estadísticas iniciales de precio
  Future<PriceStatsModel> getInitialPriceStats(String symbol);

  /// Obtiene klines históricos
  Future<List<KlineModel>> getHistoricalKlines({
    required String symbol,
    required String interval,
    int? limit,
    DateTime? startTime,
    DateTime? endTime,
  });

  /// Obtiene trades recientes iniciales
  Future<List<TradeModel>> getInitialRecentTrades({
    required String symbol,
    int limit = 50,
  });

  /// Verifica si el símbolo existe
  Future<bool> isValidSymbol(String symbol);

  /// Obtiene información del símbolo
  Future<Map<String, dynamic>> getSymbolInfo(String symbol);

  /// Libera recursos
  Future<void> dispose();
}

class TradingPairRemoteDataSourceImpl implements TradingPairRemoteDataSource {
  final Dio _dio;
  static const String _baseWsUrl = 'wss://stream.binance.com:9443/ws';
  static const String _baseApiUrl =
      'https://us-central1-banexcoin-6a811.cloudfunctions.net/binanceProxy';

  // Controladores de stream para cada tipo de conexión
  final Map<String, StreamController<TradingPairModel>> _tickerControllers = {};
  final Map<String, StreamController<PriceStatsModel>> _priceStatsControllers =
      {};
  final Map<String, StreamController<List<KlineModel>>> _klineControllers = {};
  final Map<String, StreamController<List<TradeModel>>> _tradesControllers = {};

  // Canales de WebSocket activos
  final Map<String, WebSocketChannel> _channels = {};

  // Timers para reconexión automática
  final Map<String, Timer> _reconnectTimers = {};

  // Estados de conexión
  final Map<String, bool> _isConnected = {};

  // Configuración de reconexión
  static const Duration _reconnectDelay = Duration(seconds: 5);
  static const int _maxReconnectAttempts = 10;
  final Map<String, int> _reconnectAttempts = {};

  TradingPairRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'TradingPair/1.0',
        },
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (object) => debugPrint('[TradingPair API] $object'),
      ),
    );

    return dio;
  }

  @override
  Stream<TradingPairModel> getTradingPairStream(String symbol) {
    final streamKey = '${symbol.toLowerCase()}@ticker';

    if (!_tickerControllers.containsKey(streamKey)) {
      _tickerControllers[streamKey] =
          StreamController<TradingPairModel>.broadcast();
      _connectTickerStream(symbol, streamKey);
    }

    return _tickerControllers[streamKey]!.stream;
  }

  @override
  Stream<PriceStatsModel> getPriceStatsStream(String symbol) {
    final streamKey = '${symbol.toLowerCase()}@ticker_stats';

    if (!_priceStatsControllers.containsKey(streamKey)) {
      _priceStatsControllers[streamKey] =
          StreamController<PriceStatsModel>.broadcast();
      _connectPriceStatsStream(symbol, streamKey);
    }

    return _priceStatsControllers[streamKey]!.stream;
  }

  @override
  Stream<List<KlineModel>> getKlineStream({
    required String symbol,
    required String interval,
    int? limit,
  }) {
    final streamKey = '${symbol.toLowerCase()}@kline_$interval';

    if (!_klineControllers.containsKey(streamKey)) {
      _klineControllers[streamKey] =
          StreamController<List<KlineModel>>.broadcast();
      _connectKlineStream(symbol, interval, streamKey);
    }

    return _klineControllers[streamKey]!.stream;
  }

  @override
  Stream<List<TradeModel>> getRecentTradesStream(String symbol) {
    final streamKey = '${symbol.toLowerCase()}@trade';

    if (!_tradesControllers.containsKey(streamKey)) {
      _tradesControllers[streamKey] =
          StreamController<List<TradeModel>>.broadcast();
      _connectTradesStream(symbol, streamKey);
    }

    return _tradesControllers[streamKey]!.stream;
  }

  @override
  Future<TradingPairModel> getInitialTradingPairData(String symbol) async {
    try {
      debugPrint('🌐 Requesting trading pair data for: $symbol');

      final response = await _dio.get(
        '$_baseApiUrl/ticker/24hr',
        queryParameters: {'symbol': symbol.toUpperCase()},
      );

      if (response.statusCode == 200) {
        return TradingPairModel.fromTickerRest(response.data);
      } else {
        throw TradingPairApiException(
          'Error obteniendo datos del par de trading: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw TradingPairApiException('Error inesperado: $e');
    }
  }

  @override
  Future<PriceStatsModel> getInitialPriceStats(String symbol) async {
    try {
      debugPrint('🌐 Requesting price stats for: $symbol');

      final response = await _dio.get(
        '$_baseApiUrl/ticker/24hr',
        queryParameters: {'symbol': symbol.toUpperCase()},
      );

      if (response.statusCode == 200) {
        return PriceStatsModel.fromTicker(response.data, isWebSocket: false);
      } else {
        throw TradingPairApiException(
          'Error obteniendo estadísticas de precio: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw TradingPairApiException('Error inesperado: $e');
    }
  }

  @override
  Future<List<KlineModel>> getHistoricalKlines({
    required String symbol,
    required String interval,
    int? limit,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
      debugPrint('🌐 Requesting historical klines for: $symbol');

      final queryParameters = <String, dynamic>{
        'symbol': symbol.toUpperCase(),
        'interval': interval,
      };

      if (limit != null) queryParameters['limit'] = limit.toString();
      if (startTime != null) {
        queryParameters['startTime'] = startTime.millisecondsSinceEpoch
            .toString();
      }
      if (endTime != null) {
        queryParameters['endTime'] = endTime.millisecondsSinceEpoch.toString();
      }

      final response = await _dio.get(
        '$_baseApiUrl/klines',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data
            .map((klineArray) => KlineModel.fromRestList(klineArray))
            .toList();
      } else {
        throw TradingPairApiException(
          'Error obteniendo klines históricos: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw TradingPairApiException('Error inesperado: $e');
    }
  }

  @override
  Future<List<TradeModel>> getInitialRecentTrades({
    required String symbol,
    int limit = 50,
  }) async {
    try {
      debugPrint('🌐 Requesting recent trades for: $symbol');

      final response = await _dio.get(
        '$_baseApiUrl/trades',
        queryParameters: {
          'symbol': symbol.toUpperCase(),
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((tradeJson) => TradeModel.fromRest(tradeJson)).toList();
      } else {
        throw TradingPairApiException(
          'Error obteniendo trades recientes: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw TradingPairApiException('Error inesperado: $e');
    }
  }

  @override
  Future<bool> isValidSymbol(String symbol) async {
    try {
      debugPrint('🌐 Validating symbol: $symbol');

      final response = await _dio.get(
        '$_baseApiUrl/exchangeInfo',
        queryParameters: {'symbol': symbol.toUpperCase()},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> getSymbolInfo(String symbol) async {
    try {
      debugPrint('🌐 Requesting symbol info for: $symbol');

      final response = await _dio.get('$_baseApiUrl/exchangeInfo');

      if (response.statusCode == 200) {
        final exchangeInfo = response.data;
        final symbols = exchangeInfo['symbols'] as List<dynamic>;

        final symbolInfo = symbols.firstWhere(
          (s) => s['symbol'] == symbol.toUpperCase(),
          orElse: () =>
              throw TradingPairApiException('Símbolo no encontrado: $symbol'),
        );

        return symbolInfo as Map<String, dynamic>;
      } else {
        throw TradingPairApiException(
          'Error obteniendo información del símbolo: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw TradingPairApiException('Error inesperado: $e');
    }
  }

  /// Conecta stream de ticker
  void _connectTickerStream(String symbol, String streamKey) {
    final url = '$_baseWsUrl/${symbol.toLowerCase()}@ticker';
    _createConnection(
      url: url,
      streamKey: streamKey,
      onData: (data) {
        try {
          final tickerData = TradingPairModel.fromTickerWebSocket(data);
          _tickerControllers[streamKey]?.add(tickerData);
        } catch (e) {
          debugPrint('Error parsing ticker data for $symbol: $e');
        }
      },
      onReconnect: () => _connectTickerStream(symbol, streamKey),
    );
  }

  /// Conecta stream de estadísticas de precio
  void _connectPriceStatsStream(String symbol, String streamKey) {
    final url = '$_baseWsUrl/${symbol.toLowerCase()}@ticker';
    _createConnection(
      url: url,
      streamKey: streamKey,
      onData: (data) {
        try {
          final priceStatsData = PriceStatsModel.fromTicker(
            data,
            isWebSocket: true,
          );
          _priceStatsControllers[streamKey]?.add(priceStatsData);
        } catch (e) {
          debugPrint('Error parsing price stats data for $symbol: $e');
        }
      },
      onReconnect: () => _connectPriceStatsStream(symbol, streamKey),
    );
  }

  /// Conecta stream de klines
  void _connectKlineStream(String symbol, String interval, String streamKey) {
    final url = '$_baseWsUrl/${symbol.toLowerCase()}@kline_$interval';
    _createConnection(
      url: url,
      streamKey: streamKey,
      onData: (data) {
        try {
          final klineData = KlineModel.fromWebSocket(data);
          // Para streams de kline, mantenemos una lista de las últimas klines
          _klineControllers[streamKey]?.add([klineData]);
        } catch (e) {
          debugPrint('Error parsing kline data for $symbol: $e');
        }
      },
      onReconnect: () => _connectKlineStream(symbol, interval, streamKey),
    );
  }

  /// Conecta stream de trades
  void _connectTradesStream(String symbol, String streamKey) {
    final url = '$_baseWsUrl/${symbol.toLowerCase()}@trade';
    final List<TradeModel> recentTrades = [];

    _createConnection(
      url: url,
      streamKey: streamKey,
      onData: (data) {
        try {
          final tradeData = TradeModel.fromWebSocket(data);

          // Mantener solo los últimos 50 trades
          recentTrades.insert(0, tradeData);
          if (recentTrades.length > 50) {
            recentTrades.removeLast();
          }

          _tradesControllers[streamKey]?.add(List.from(recentTrades));
        } catch (e) {
          debugPrint('Error parsing trade data for $symbol: $e');
        }
      },
      onReconnect: () => _connectTradesStream(symbol, streamKey),
    );
  }

  /// Crea una conexión WebSocket genérica con manejo de errores
  void _createConnection({
    required String url,
    required String streamKey,
    required Function(Map<String, dynamic>) onData,
    required VoidCallback onReconnect,
  }) {
    try {
      // Cancelar timer de reconexión anterior si existe
      _reconnectTimers[streamKey]?.cancel();

      // Cerrar canal anterior si existe
      _channels[streamKey]?.sink.close();

      // Crear nueva conexión
      final channel = WebSocketChannel.connect(Uri.parse(url));
      _channels[streamKey] = channel;
      _isConnected[streamKey] = true;
      _reconnectAttempts[streamKey] = 0;

      debugPrint('Conectado a WebSocket: $url');

      // Escuchar mensajes
      channel.stream.listen(
        (message) {
          try {
            final data = json.decode(message as String) as Map<String, dynamic>;
            onData(data);
          } catch (e) {
            debugPrint('Error decodificando mensaje de $streamKey: $e');
          }
        },
        onError: (error) {
          debugPrint('Error en WebSocket $streamKey: $error');
          _handleConnectionError(streamKey, onReconnect);
        },
        onDone: () {
          debugPrint('WebSocket cerrado: $streamKey');
          _handleConnectionError(streamKey, onReconnect);
        },
      );
    } catch (e) {
      debugPrint('Error creando conexión WebSocket para $streamKey: $e');
      _handleConnectionError(streamKey, onReconnect);
    }
  }

  /// Maneja errores de conexión y reconexión automática
  void _handleConnectionError(String streamKey, VoidCallback onReconnect) {
    _isConnected[streamKey] = false;

    final attempts = _reconnectAttempts[streamKey] ?? 0;
    if (attempts < _maxReconnectAttempts) {
      _reconnectAttempts[streamKey] = attempts + 1;

      debugPrint(
        'Reintentando conexión para $streamKey (intento ${attempts + 1}/$_maxReconnectAttempts)',
      );

      _reconnectTimers[streamKey] = Timer(_reconnectDelay, () {
        if (!(_isConnected[streamKey] ?? false)) {
          onReconnect();
        }
      });
    } else {
      debugPrint('Máximo número de reintentos alcanzado para $streamKey');
      _closeStream(streamKey);
    }
  }

  /// Cierra un stream específico
  void _closeStream(String streamKey) {
    _channels[streamKey]?.sink.close();
    _channels.remove(streamKey);
    _reconnectTimers[streamKey]?.cancel();
    _reconnectTimers.remove(streamKey);
    _isConnected.remove(streamKey);
    _reconnectAttempts.remove(streamKey);

    // Cerrar controladores apropiados
    if (streamKey.contains('@ticker') && !streamKey.contains('_stats')) {
      _tickerControllers[streamKey]?.close();
      _tickerControllers.remove(streamKey);
    } else if (streamKey.contains('_stats')) {
      _priceStatsControllers[streamKey]?.close();
      _priceStatsControllers.remove(streamKey);
    } else if (streamKey.contains('@kline')) {
      _klineControllers[streamKey]?.close();
      _klineControllers.remove(streamKey);
    } else if (streamKey.contains('@trade')) {
      _tradesControllers[streamKey]?.close();
      _tradesControllers.remove(streamKey);
    }
  }

  /// Maneja excepciones de Dio
  TradingPairApiException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return TradingPairApiException('Timeout de conexión', 408);
      case DioExceptionType.sendTimeout:
        return TradingPairApiException('Timeout de envío', 408);
      case DioExceptionType.receiveTimeout:
        return TradingPairApiException('Timeout de recepción', 408);
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 500;
        String message = 'Error del servidor';

        if (statusCode == 429) {
          message = 'Límite de velocidad excedido';
        } else if (statusCode >= 500) {
          message = 'Error interno del servidor';
        } else if (statusCode == 404) {
          message = 'Símbolo no encontrado';
        }

        return TradingPairApiException(message, statusCode);
      case DioExceptionType.cancel:
        return TradingPairApiException('Solicitud cancelada');
      case DioExceptionType.connectionError:
        if (kIsWeb) {
          return TradingPairApiException(
            'Error de CORS - Ejecuta con: flutter run -d chrome --web-browser-flag "--disable-web-security"',
          );
        }
        return TradingPairApiException(
          'Error de conexión - Verifica tu internet',
        );
      default:
        return TradingPairApiException(
          'Error de red desconocido: ${e.message}',
        );
    }
  }

  @override
  Future<void> dispose() async {
    // Cancelar todos los timers
    for (final timer in _reconnectTimers.values) {
      timer.cancel();
    }
    _reconnectTimers.clear();

    // Cerrar todos los canales
    for (final channel in _channels.values) {
      await channel.sink.close();
    }
    _channels.clear();

    // Cerrar todos los controladores
    for (final controller in _tickerControllers.values) {
      await controller.close();
    }
    _tickerControllers.clear();

    for (final controller in _priceStatsControllers.values) {
      await controller.close();
    }
    _priceStatsControllers.clear();

    for (final controller in _klineControllers.values) {
      await controller.close();
    }
    _klineControllers.clear();

    for (final controller in _tradesControllers.values) {
      await controller.close();
    }
    _tradesControllers.clear();

    _isConnected.clear();
    _reconnectAttempts.clear();

    debugPrint('TradingPairRemoteDataSource cerrado completamente');
  }
}

/// Excepción personalizada para errores de la API
class TradingPairApiException implements Exception {
  final String message;
  final int? statusCode;
  final bool isNetworkError;

  TradingPairApiException(
    this.message, [
    this.statusCode,
    this.isNetworkError = false,
  ]);

  @override
  String toString() => 'TradingPairApiException: $message';

  bool get isRetryable {
    if (isNetworkError) return true;
    if (statusCode == null) return false;
    return statusCode! >= 500 || statusCode == 429;
  }

  Duration get retryDelay {
    if (statusCode == 429) {
      return const Duration(minutes: 1);
    }
    return const Duration(seconds: 5);
  }
}
