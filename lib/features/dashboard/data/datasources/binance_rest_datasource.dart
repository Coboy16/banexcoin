import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

abstract class BinanceRestDataSource {
  Future<TickerModel> getTicker24hr(String symbol);
  Future<List<TickerModel>> getAllTickers24hr();
  Future<ExchangeInfoModel> getExchangeInfo();
  Future<double> getCurrentPrice(String symbol);
  Future<DepthModel> getOrderBook(String symbol, {int limit = 20});
  Future<bool> checkConnectivity();
}

class BinanceRestDataSourceImpl implements BinanceRestDataSource {
  final Dio _dio;

  BinanceRestDataSourceImpl({Dio? dio}) : _dio = dio ?? _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'TradingDashboard/1.0',
        },
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (object) => debugPrint('[API] $object'),
      ),
    );

    return dio;
  }

  // URL base - usar directamente la API de Binance
  String get _baseUrl => 'https://data-api.binance.vision/api/v3';

  @override
  Future<TickerModel> getTicker24hr(String symbol) async {
    try {
      debugPrint('🌐 Requesting ticker for: $symbol');

      final response = await _dio.get(
        '$_baseUrl/ticker/24hr',
        queryParameters: {'symbol': symbol.toUpperCase()},
      );

      if (response.statusCode == 200) {
        return TickerModel.fromRestJson(response.data);
      } else {
        throw BinanceApiException(
          'Error obteniendo ticker: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw BinanceApiException('Error inesperado: $e');
    }
  }

  @override
  Future<List<TickerModel>> getAllTickers24hr() async {
    try {
      debugPrint('🌐 Requesting all tickers');

      final response = await _dio.get('$_baseUrl/ticker/24hr');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => TickerModel.fromRestJson(json)).toList();
      } else {
        throw BinanceApiException(
          'Error obteniendo todos los tickers: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw BinanceApiException('Error inesperado: $e');
    }
  }

  @override
  Future<ExchangeInfoModel> getExchangeInfo() async {
    try {
      debugPrint('🌐 Requesting exchange info');

      final response = await _dio.get('$_baseUrl/exchangeInfo');

      if (response.statusCode == 200) {
        return ExchangeInfoModel.fromJson(response.data);
      } else {
        throw BinanceApiException(
          'Error obteniendo información del exchange: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw BinanceApiException('Error inesperado: $e');
    }
  }

  @override
  Future<double> getCurrentPrice(String symbol) async {
    try {
      debugPrint('🌐 Requesting current price for: $symbol');

      final response = await _dio.get(
        '$_baseUrl/ticker/price',
        queryParameters: {'symbol': symbol.toUpperCase()},
      );

      if (response.statusCode == 200) {
        final price = response.data['price'] as String;
        return double.parse(price);
      } else {
        throw BinanceApiException(
          'Error obteniendo precio actual: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw BinanceApiException('Error inesperado: $e');
    }
  }

  @override
  Future<DepthModel> getOrderBook(String symbol, {int limit = 20}) async {
    try {
      debugPrint('🌐 Requesting order book for: $symbol');

      final response = await _dio.get(
        '$_baseUrl/depth',
        queryParameters: {
          'symbol': symbol.toUpperCase(),
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        return DepthModel.fromWebSocketJson(response.data);
      } else {
        throw BinanceApiException(
          'Error obteniendo libro de órdenes: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw BinanceApiException('Error inesperado: $e');
    }
  }

  @override
  Future<bool> checkConnectivity() async {
    try {
      debugPrint('🌐 Checking connectivity');

      final response = await _dio.get('$_baseUrl/ping');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  BinanceApiException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return BinanceApiException('Timeout de conexión', 408);
      case DioExceptionType.sendTimeout:
        return BinanceApiException('Timeout de envío', 408);
      case DioExceptionType.receiveTimeout:
        return BinanceApiException('Timeout de recepción', 408);
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

        return BinanceApiException(message, statusCode);
      case DioExceptionType.cancel:
        return BinanceApiException('Solicitud cancelada');
      case DioExceptionType.connectionError:
        if (kIsWeb) {
          return BinanceApiException(
            'Error de CORS - Ejecuta con: flutter run -d chrome --web-browser-flag "--disable-web-security"',
          );
        }
        return BinanceApiException('Error de conexión - Verifica tu internet');
      default:
        return BinanceApiException('Error de red desconocido: ${e.message}');
    }
  }

  Future<int> getServerTime() async {
    try {
      final response = await _dio.get('$_baseUrl/time');
      return response.data['serverTime'] as int;
    } catch (e) {
      return DateTime.now().millisecondsSinceEpoch;
    }
  }

  Future<Map<String, dynamic>> getExchangeStatistics() async {
    try {
      final response = await _dio.get('$_baseUrl/ticker/24hr');
      final tickers = response.data as List;

      double totalVolume = 0;
      int tradingPairs = 0;
      int gainers = 0;
      int losers = 0;

      for (final ticker in tickers) {
        final changePercent =
            double.tryParse(ticker['priceChangePercent'] ?? '0') ?? 0;
        final volume = double.tryParse(ticker['quoteVolume'] ?? '0') ?? 0;

        totalVolume += volume;
        tradingPairs++;

        if (changePercent > 0) {
          gainers++;
        } else if (changePercent < 0) {
          losers++;
        }
      }

      return {
        'totalVolume': totalVolume,
        'tradingPairs': tradingPairs,
        'gainers': gainers,
        'losers': losers,
        'stable': tradingPairs - gainers - losers,
      };
    } catch (e) {
      return {};
    }
  }
}

class BinanceApiException implements Exception {
  final String message;
  final int? statusCode;
  final bool isNetworkError;

  BinanceApiException(
    this.message, [
    this.statusCode,
    this.isNetworkError = false,
  ]);

  @override
  String toString() => 'BinanceApiException: $message';

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
