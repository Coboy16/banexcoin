import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

abstract class BinanceRestDataSource {
  /// Obtiene ticker de 24 horas para un símbolo
  Future<TickerModel> getTicker24hr(String symbol);

  /// Obtiene tickers de 24 horas para múltiples símbolos
  Future<List<TickerModel>> getAllTickers24hr();

  /// Obtiene información del exchange
  Future<ExchangeInfoModel> getExchangeInfo();

  /// Obtiene precio actual de un símbolo
  Future<double> getCurrentPrice(String symbol);

  /// Obtiene libro de órdenes
  Future<DepthModel> getOrderBook(String symbol, {int limit = 20});

  /// Verifica conectividad con la API
  Future<bool> checkConnectivity();
}

class BinanceRestDataSourceImpl implements BinanceRestDataSource {
  static const String _baseUrl = 'https://api.binance.com/api/v3';

  final Dio _dio;

  BinanceRestDataSourceImpl({Dio? dio}) : _dio = dio ?? _createDio();

  /// Crea cliente Dio con configuración optimizada
  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'DashboardApp/1.0',
        },
      ),
    );

    // Interceptor para logging en desarrollo
    dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (object) => debugPrint('[API] $object'),
      ),
    );

    // Interceptor para manejo de errores
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          debugPrint('Error en API: ${error.message}');
          if (error.response?.statusCode == 429) {
            debugPrint('Rate limit excedido, implementar retry con backoff');
          }
          handler.next(error);
        },
      ),
    );

    return dio;
  }

  @override
  Future<TickerModel> getTicker24hr(String symbol) async {
    try {
      final response = await _dio.get(
        '/ticker/24hr',
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
      final response = await _dio.get('/ticker/24hr');

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
      final response = await _dio.get('/exchangeInfo');

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
      final response = await _dio.get(
        '/ticker/price',
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
      final response = await _dio.get(
        '/depth',
        queryParameters: {'symbol': symbol.toUpperCase(), 'limit': limit},
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

  /// Maneja excepciones de Dio y las convierte en excepciones de dominio
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
        return BinanceApiException('Error de conexión');
      default:
        return BinanceApiException('Error de red desconocido: ${e.message}');
    }
  }

  /// Verifica la conectividad de la API
  @override
  Future<bool> checkConnectivity() async {
    try {
      final response = await _dio.get('/ping');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene el tiempo del servidor
  Future<int> getServerTime() async {
    try {
      final response = await _dio.get('/time');
      return response.data['serverTime'] as int;
    } catch (e) {
      return DateTime.now().millisecondsSinceEpoch;
    }
  }

  /// Obtiene estadísticas del exchange
  Future<Map<String, dynamic>> getExchangeStatistics() async {
    try {
      final response = await _dio.get('/ticker/24hr');
      final tickers = response.data as List;

      // Calcular estadísticas básicas
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

/// Excepción personalizada para errores de la API de Binance
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

  /// Determina si el error es recuperable (reintentos automáticos)
  bool get isRetryable {
    if (isNetworkError) return true;
    if (statusCode == null) return false;

    // Errores temporales del servidor
    return statusCode! >= 500 || statusCode == 429;
  }

  /// Obtiene el delay sugerido para reintentos
  Duration get retryDelay {
    if (statusCode == 429) {
      return const Duration(minutes: 1); // Rate limit
    }
    return const Duration(seconds: 5); // Otros errores
  }
}
