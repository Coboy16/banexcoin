import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '/features/features.dart';

final GetIt tpSl = GetIt.instance;

Future<void> initializeTradingPairDependencies() async {
  // ========== EXTERNAL DEPENDENCIES ==========
  await _initExternalDependencies();

  // ========== DATA SOURCES ==========
  await _initDataSources();

  // ========== REPOSITORIES ==========
  await _initRepositories();

  // ========== USE CASES ==========
  await _initUseCases();

  // ========== BLOCS ==========
  await _initBlocs();

  debugPrint('✅ Trading Pair dependency injection initialized successfully');
}

/// Inicializa dependencias externas (Dio específico para Trading Pair)
Future<void> _initExternalDependencies() async {
  // Dio específico para Trading Pair (solo registrar si no existe)
  if (!tpSl.isRegistered<Dio>(instanceName: 'tradingPairDio')) {
    final dio = Dio(
      BaseOptions(
        baseUrl:
            'https://us-central1-banexcoin-6a811.cloudfunctions.net/binanceProxy',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'TradingPair/1.0',
        },
      ),
    );

    // Interceptores específicos para Trading Pair
    dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (object) => debugPrint('[TradingPair API] $object'),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('🔄 [TradingPair ${options.method}] ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            '✅ [TradingPair ${response.statusCode}] ${response.requestOptions.uri}',
          );
          handler.next(response);
        },
        onError: (error, handler) {
          debugPrint(
            '❌ [TradingPair ${error.response?.statusCode}] ${error.requestOptions.uri}',
          );
          debugPrint('TradingPair Error: ${error.message}');

          // Manejar rate limiting específico para Trading Pair
          if (error.response?.statusCode == 429) {
            debugPrint('⚠️ TradingPair Rate limit exceeded');
          }

          handler.next(error);
        },
      ),
    );

    // Registrar Dio específico para Trading Pair
    tpSl.registerLazySingleton<Dio>(() => dio, instanceName: 'tradingPairDio');
  }

  debugPrint('📡 Trading Pair external dependencies registered');
}

/// Inicializa data sources para Trading Pair
Future<void> _initDataSources() async {
  // Remote DataSource para Trading Pair
  if (!tpSl.isRegistered<TradingPairRemoteDataSource>()) {
    tpSl.registerLazySingleton<TradingPairRemoteDataSource>(
      () => TradingPairRemoteDataSourceImpl(
        dio: tpSl<Dio>(instanceName: 'tradingPairDio'),
      ),
    );
  }

  debugPrint('🔌 Trading Pair data sources registered');
}

/// Inicializa repositories para Trading Pair
Future<void> _initRepositories() async {
  // Trading Pair Repository
  if (!tpSl.isRegistered<TradingPairRepository>()) {
    tpSl.registerLazySingleton<TradingPairRepository>(
      () => TradingPairRepositoryImpl(
        remoteDataSource: tpSl<TradingPairRemoteDataSource>(),
      ),
    );
  }

  debugPrint('📚 Trading Pair repositories registered');
}

/// Inicializa use cases para Trading Pair
Future<void> _initUseCases() async {
  // Trading Pair Stream Use Case
  if (!tpSl.isRegistered<GetTradingPairStreamUseCase>()) {
    tpSl.registerLazySingleton<GetTradingPairStreamUseCase>(
      () => GetTradingPairStreamUseCase(tpSl<TradingPairRepository>()),
    );
  }

  // Price Stats Stream Use Case
  if (!tpSl.isRegistered<GetPriceStatsStreamUseCase>()) {
    tpSl.registerLazySingleton<GetPriceStatsStreamUseCase>(
      () => GetPriceStatsStreamUseCase(tpSl<TradingPairRepository>()),
    );
  }

  // Kline Stream Use Case
  if (!tpSl.isRegistered<GetKlineStreamUseCase>()) {
    tpSl.registerLazySingleton<GetKlineStreamUseCase>(
      () => GetKlineStreamUseCase(tpSl<TradingPairRepository>()),
    );
  }

  // Recent Trades Stream Use Case
  if (!tpSl.isRegistered<GetRecentTradesStreamUseCase>()) {
    tpSl.registerLazySingleton<GetRecentTradesStreamUseCase>(
      () => GetRecentTradesStreamUseCase(tpSl<TradingPairRepository>()),
    );
  }

  // Initial Trading Pair Data Use Case
  if (!tpSl.isRegistered<GetInitialTradingPairDataUseCase>()) {
    tpSl.registerLazySingleton<GetInitialTradingPairDataUseCase>(
      () => GetInitialTradingPairDataUseCase(tpSl<TradingPairRepository>()),
    );
  }

  debugPrint('🎯 Trading Pair use cases registered');
}

/// Inicializa BLoCs para Trading Pair
Future<void> _initBlocs() async {
  // Trading Pair BLoC - Factory para poder crear múltiples instancias
  if (!tpSl.isRegistered<TradingPairBloc>()) {
    tpSl.registerFactory<TradingPairBloc>(
      () => TradingPairBloc(
        getTradingPairStreamUseCase: tpSl<GetTradingPairStreamUseCase>(),
        getPriceStatsStreamUseCase: tpSl<GetPriceStatsStreamUseCase>(),
        getKlineStreamUseCase: tpSl<GetKlineStreamUseCase>(),
        getRecentTradesStreamUseCase: tpSl<GetRecentTradesStreamUseCase>(),
        getInitialTradingPairDataUseCase:
            tpSl<GetInitialTradingPairDataUseCase>(),
        repository: tpSl<TradingPairRepository>(),
      ),
    );
  }

  debugPrint('🧠 Trading Pair BLoCs registered');
}

/// Limpia todas las dependencias de Trading Pair
Future<void> disposeTradingPairDependencies() async {
  try {
    // Cerrar repository si existe
    if (tpSl.isRegistered<TradingPairRepository>()) {
      final repository = tpSl<TradingPairRepository>();
      await repository.dispose();
    }

    // Cerrar Dio específico
    if (tpSl.isRegistered<Dio>(instanceName: 'tradingPairDio')) {
      final dio = tpSl<Dio>(instanceName: 'tradingPairDio');
      dio.close();
    }

    // Resetear GetIt específico para Trading Pair
    await tpSl.reset();

    debugPrint('🧹 Trading Pair dependencies disposed successfully');
  } catch (e) {
    debugPrint('❌ Error disposing Trading Pair dependencies: $e');
  }
}

/// Verifica que todas las dependencias de Trading Pair estén registradas
void validateTradingPairDependencies() {
  final dependencies = {
    'TradingPairDio': tpSl.isRegistered<Dio>(instanceName: 'tradingPairDio'),
    'TradingPairRemoteDataSource': tpSl
        .isRegistered<TradingPairRemoteDataSource>(),
    'TradingPairRepository': tpSl.isRegistered<TradingPairRepository>(),
    'GetTradingPairStreamUseCase': tpSl
        .isRegistered<GetTradingPairStreamUseCase>(),
    'GetPriceStatsStreamUseCase': tpSl
        .isRegistered<GetPriceStatsStreamUseCase>(),
    'GetKlineStreamUseCase': tpSl.isRegistered<GetKlineStreamUseCase>(),
    'GetRecentTradesStreamUseCase': tpSl
        .isRegistered<GetRecentTradesStreamUseCase>(),
    'GetInitialTradingPairDataUseCase': tpSl
        .isRegistered<GetInitialTradingPairDataUseCase>(),
    'TradingPairBloc': tpSl.isRegistered<TradingPairBloc>(),
  };

  debugPrint('🔍 Trading Pair dependency validation:');
  dependencies.forEach((key, value) {
    debugPrint('  $key: ${value ? '✅' : '❌'}');
  });

  final allValid = dependencies.values.every((v) => v);
  if (!allValid) {
    throw Exception('❌ Some Trading Pair dependencies are not registered');
  }

  debugPrint('✅ All Trading Pair dependencies validated successfully');
}

/// Obtiene estadísticas de las dependencias de Trading Pair
Map<String, dynamic> getTradingPairDependencyStats() {
  final registeredTypes = <String>[];

  try {
    if (tpSl.isRegistered<Dio>(instanceName: 'tradingPairDio')) {
      registeredTypes.add('TradingPairDio');
    }
    if (tpSl.isRegistered<TradingPairRemoteDataSource>()) {
      registeredTypes.add('TradingPairRemoteDataSource');
    }
    if (tpSl.isRegistered<TradingPairRepository>()) {
      registeredTypes.add('TradingPairRepository');
    }
    if (tpSl.isRegistered<GetTradingPairStreamUseCase>()) {
      registeredTypes.add('GetTradingPairStreamUseCase');
    }
    if (tpSl.isRegistered<GetPriceStatsStreamUseCase>()) {
      registeredTypes.add('GetPriceStatsStreamUseCase');
    }
    if (tpSl.isRegistered<GetKlineStreamUseCase>()) {
      registeredTypes.add('GetKlineStreamUseCase');
    }
    if (tpSl.isRegistered<GetRecentTradesStreamUseCase>()) {
      registeredTypes.add('GetRecentTradesStreamUseCase');
    }
    if (tpSl.isRegistered<GetInitialTradingPairDataUseCase>()) {
      registeredTypes.add('GetInitialTradingPairDataUseCase');
    }
    if (tpSl.isRegistered<TradingPairBloc>()) {
      registeredTypes.add('TradingPairBloc');
    }
  } catch (e) {
    debugPrint('Error getting Trading Pair dependency stats: $e');
  }

  return {
    'totalRegistered': registeredTypes.length,
    'readyDependencies': registeredTypes,
    'factoryDependencies': _getTradingPairFactoryDependencies(),
    'singletonDependencies': _getTradingPairSingletonDependencies(),
  };
}

List<String> _getTradingPairFactoryDependencies() {
  // Dependencias registradas como factory (se crean nuevas instancias)
  return ['TradingPairBloc'];
}

List<String> _getTradingPairSingletonDependencies() {
  // Dependencias registradas como singleton (instancia única)
  return [
    'TradingPairDio',
    'TradingPairRemoteDataSource',
    'TradingPairRepository',
    'GetTradingPairStreamUseCase',
    'GetPriceStatsStreamUseCase',
    'GetKlineStreamUseCase',
    'GetRecentTradesStreamUseCase',
    'GetInitialTradingPairDataUseCase',
  ];
}

/// Extensiones para facilitar el acceso a Trading Pair desde cualquier parte de la app
extension TradingPairDependencyInjectionExtensions on GetIt {
  // Data Sources
  TradingPairRemoteDataSource get tradingPairRemoteDataSource =>
      get<TradingPairRemoteDataSource>();

  // Repository
  TradingPairRepository get tradingPairRepository =>
      get<TradingPairRepository>();

  // Use Cases
  GetTradingPairStreamUseCase get getTradingPairStreamUseCase =>
      get<GetTradingPairStreamUseCase>();
  GetPriceStatsStreamUseCase get getPriceStatsStreamUseCase =>
      get<GetPriceStatsStreamUseCase>();
  GetKlineStreamUseCase get getKlineStreamUseCase =>
      get<GetKlineStreamUseCase>();
  GetRecentTradesStreamUseCase get getRecentTradesStreamUseCase =>
      get<GetRecentTradesStreamUseCase>();
  GetInitialTradingPairDataUseCase get getInitialTradingPairDataUseCase =>
      get<GetInitialTradingPairDataUseCase>();

  // BLoCs
  TradingPairBloc get tradingPairBloc => get<TradingPairBloc>();

  // Dio específico
  Dio get tradingPairDio => get<Dio>(instanceName: 'tradingPairDio');
}

/// Configuración de ambiente específica para Trading Pair
enum TradingPairEnvironment { development, staging, production }

class TradingPairEnvironmentConfig {
  static TradingPairEnvironment _currentEnvironment =
      TradingPairEnvironment.development;

  static TradingPairEnvironment get currentEnvironment => _currentEnvironment;

  static void setEnvironment(TradingPairEnvironment env) {
    _currentEnvironment = env;
  }

  static String get binanceBaseUrl {
    switch (_currentEnvironment) {
      case TradingPairEnvironment.development:
        return 'https://testnet.binance.vision/api/v3'; // Testnet para desarrollo
      case TradingPairEnvironment.staging:
        return 'https://data-api.binance.vision/api/v3'; // Data API para staging
      case TradingPairEnvironment.production:
        return 'https://data-api.binance.vision/api/v3'; // Data API para producción
    }
  }

  static String get binanceWebSocketUrl {
    switch (_currentEnvironment) {
      case TradingPairEnvironment.development:
        return 'wss://testnet.binance.vision/ws'; // WebSocket testnet
      case TradingPairEnvironment.staging:
      case TradingPairEnvironment.production:
        return 'wss://stream.binance.com:9443/ws'; // WebSocket real
    }
  }

  static bool get enableLogging =>
      _currentEnvironment != TradingPairEnvironment.production;

  static Duration get connectionTimeout {
    switch (_currentEnvironment) {
      case TradingPairEnvironment.development:
        return const Duration(seconds: 30); // Más tiempo para debugging
      case TradingPairEnvironment.staging:
      case TradingPairEnvironment.production:
        return const Duration(seconds: 15);
    }
  }
}

/// Inicialización con configuración de ambiente específica para Trading Pair
Future<void> initializeTradingPairDependenciesWithEnvironment(
  TradingPairEnvironment environment,
) async {
  TradingPairEnvironmentConfig.setEnvironment(environment);
  await initializeTradingPairDependencies();

  debugPrint('🌍 Trading Pair Environment: ${environment.name}');
  debugPrint(
    '🔗 Trading Pair Binance API: ${TradingPairEnvironmentConfig.binanceBaseUrl}',
  );
  debugPrint(
    '🔌 Trading Pair WebSocket: ${TradingPairEnvironmentConfig.binanceWebSocketUrl}',
  );
}

/// Utilidades para debugging específicas de Trading Pair
class TradingPairDependencyDebugUtils {
  /// Imprime todas las dependencias de Trading Pair registradas
  static void debugPrintAllTradingPairDependencies() {
    debugPrint('=== TRADING PAIR REGISTERED DEPENDENCIES ===');
    final stats = getTradingPairDependencyStats();
    debugPrint('Total: ${stats['totalRegistered']}');
    debugPrint('Singletons: ${stats['singletonDependencies']}');
    debugPrint('Factories: ${stats['factoryDependencies']}');
    debugPrint('============================================');
  }

  /// Verifica la salud de las dependencias de Trading Pair
  static Future<Map<String, bool>> checkTradingPairDependencyHealth() async {
    final healthStatus = <String, bool>{};

    try {
      // Verificar trading pair repository
      final tradingPairRepository = tpSl<TradingPairRepository>();
      healthStatus['tradingPairRepository'] = await tradingPairRepository
          .isValidSymbol('BTCUSDT');
    } catch (e) {
      healthStatus['tradingPairRepository'] = false;
    }

    try {
      // Verificar remote data source
      final remoteDataSource = tpSl<TradingPairRemoteDataSource>();
      healthStatus['remoteDataSource'] = await remoteDataSource.isValidSymbol(
        'BTCUSDT',
      );
    } catch (e) {
      healthStatus['remoteDataSource'] = false;
    }

    try {
      // Verificar que se puede crear Trading Pair BLoC
      final tradingPairBloc = tpSl<TradingPairBloc>();
      healthStatus['tradingPairBloc'] =
          tradingPairBloc.state is TradingPairInitial;
      tradingPairBloc
          .close(); // Cerrar inmediatamente para no dejar recursos abiertos
    } catch (e) {
      healthStatus['tradingPairBloc'] = false;
    }

    return healthStatus;
  }

  /// Obtiene métricas de rendimiento del repositorio de Trading Pair
  static Map<String, dynamic> getTradingPairRepositoryMetrics() {
    final metrics = <String, dynamic>{};

    try {
      if (tpSl.isRegistered<TradingPairRepository>()) {
        final repo = tpSl<TradingPairRepository>();
        if (repo is TradingPairRepositoryImpl) {
          metrics['tradingPair'] = repo.getPerformanceStats();
        }
      }
    } catch (e) {
      metrics['tradingPairError'] = e.toString();
    }

    return metrics;
  }

  /// Obtiene información de debug del BLoC activo
  static Map<String, dynamic>? getActiveTradingPairBlocDebugInfo() {
    try {
      if (tpSl.isRegistered<TradingPairBloc>()) {
        final bloc = tpSl<TradingPairBloc>();
        return bloc.getDebugInfo();
      }
    } catch (e) {
      debugPrint('Error getting TradingPair BLoC debug info: $e');
    }
    return null;
  }
}
