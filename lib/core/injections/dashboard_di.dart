import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '/features/features.dart';

final GetIt sl = GetIt.instance;

Future<void> initializeDependencies() async {
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

  debugPrint('✅ Dependency injection initialized successfully');
}

/// Inicializa dependencias externas (Dio, etc.)
Future<void> _initExternalDependencies() async {
  // Solo registrar si no está registrado ya
  if (!sl.isRegistered<Dio>()) {
    // Configurar Dio para HTTP requests
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.binance.com/api/v3',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'TradingDashboard/1.0',
        },
      ),
    );

    // Agregar interceptores para logging y manejo de errores
    dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (object) => debugPrint('[API] $object'),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('🌐 [${options.method}] ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            '✅ [${response.statusCode}] ${response.requestOptions.uri}',
          );
          handler.next(response);
        },
        onError: (error, handler) {
          debugPrint(
            '❌ [${error.response?.statusCode}] ${error.requestOptions.uri}',
          );
          debugPrint('Error: ${error.message}');

          // Manejar rate limiting
          if (error.response?.statusCode == 429) {
            debugPrint('⚠️ Rate limit exceeded, implementing backoff strategy');
          }

          handler.next(error);
        },
      ),
    );

    // Registrar Dio como singleton
    sl.registerLazySingleton<Dio>(() => dio);
  }

  debugPrint('📡 External dependencies registered');
}

/// Inicializa data sources
Future<void> _initDataSources() async {
  // WebSocket DataSource
  if (!sl.isRegistered<BinanceWebSocketDataSource>()) {
    sl.registerLazySingleton<BinanceWebSocketDataSource>(
      () => BinanceWebSocketDataSourceImpl(),
    );
  }

  // REST API DataSource
  if (!sl.isRegistered<BinanceRestDataSource>()) {
    sl.registerLazySingleton<BinanceRestDataSource>(
      () => BinanceRestDataSourceImpl(dio: sl<Dio>()),
    );
  }

  debugPrint('🔌 Data sources registered');
}

/// Inicializa repositories
Future<void> _initRepositories() async {
  // Market Data Repository
  if (!sl.isRegistered<MarketDataRepository>()) {
    sl.registerLazySingleton<MarketDataRepository>(
      () => MarketDataRepositoryImpl(
        webSocketDataSource: sl<BinanceWebSocketDataSource>(),
        restDataSource: sl<BinanceRestDataSource>(),
      ),
    );
  }

  debugPrint('📚 Repositories registered');
}

/// Inicializa use cases
Future<void> _initUseCases() async {
  // Ticker Stream Use Case
  if (!sl.isRegistered<GetTickerStreamUseCase>()) {
    sl.registerLazySingleton<GetTickerStreamUseCase>(
      () => GetTickerStreamUseCase(sl<MarketDataRepository>()),
    );
  }

  // Mini Ticker Stream Use Case
  if (!sl.isRegistered<GetMiniTickerStreamUseCase>()) {
    sl.registerLazySingleton<GetMiniTickerStreamUseCase>(
      () => GetMiniTickerStreamUseCase(sl<MarketDataRepository>()),
    );
  }

  // Depth Stream Use Case
  if (!sl.isRegistered<GetDepthStreamUseCase>()) {
    sl.registerLazySingleton<GetDepthStreamUseCase>(
      () => GetDepthStreamUseCase(sl<MarketDataRepository>()),
    );
  }

  // Initial Market Data Use Case
  if (!sl.isRegistered<GetInitialMarketDataUseCase>()) {
    sl.registerLazySingleton<GetInitialMarketDataUseCase>(
      () => GetInitialMarketDataUseCase(sl<MarketDataRepository>()),
    );
  }

  debugPrint('🎯 Use cases registered');
}

/// Inicializa BLoCs
Future<void> _initBlocs() async {
  // Market Data BLoC - Factory para poder crear múltiples instancias
  if (!sl.isRegistered<MarketDataBloc>()) {
    sl.registerFactory<MarketDataBloc>(
      () => MarketDataBloc(
        getTickerStreamUseCase: sl<GetTickerStreamUseCase>(),
        getMiniTickerStreamUseCase: sl<GetMiniTickerStreamUseCase>(),
        getDepthStreamUseCase: sl<GetDepthStreamUseCase>(),
        getInitialMarketDataUseCase: sl<GetInitialMarketDataUseCase>(),
        repository: sl<MarketDataRepository>(),
      ),
    );
  }

  debugPrint('🧠 BLoCs registered');
}

/// Limpia todas las dependencias registradas
Future<void> disposeDependencies() async {
  try {
    // Cerrar repository si existe
    if (sl.isRegistered<MarketDataRepository>()) {
      final repository = sl<MarketDataRepository>();
      await repository.dispose();
    }

    // Cerrar Dio
    if (sl.isRegistered<Dio>()) {
      final dio = sl<Dio>();
      dio.close();
    }

    // Resetear GetIt
    await sl.reset();

    debugPrint('🧹 Dependencies disposed successfully');
  } catch (e) {
    debugPrint('❌ Error disposing dependencies: $e');
  }
}

/// Verifica que todas las dependencias estén registradas correctamente
void validateDependencies() {
  final dependencies = {
    'Dio': sl.isRegistered<Dio>(),
    'BinanceWebSocketDataSource': sl.isRegistered<BinanceWebSocketDataSource>(),
    'BinanceRestDataSource': sl.isRegistered<BinanceRestDataSource>(),
    'MarketDataRepository': sl.isRegistered<MarketDataRepository>(),
    'GetTickerStreamUseCase': sl.isRegistered<GetTickerStreamUseCase>(),
    'GetMiniTickerStreamUseCase': sl.isRegistered<GetMiniTickerStreamUseCase>(),
    'GetDepthStreamUseCase': sl.isRegistered<GetDepthStreamUseCase>(),
    'GetInitialMarketDataUseCase': sl
        .isRegistered<GetInitialMarketDataUseCase>(),
    'MarketDataBloc': sl.isRegistered<MarketDataBloc>(),
  };

  debugPrint('🔍 Dependency validation:');
  dependencies.forEach((key, value) {
    debugPrint('  $key: ${value ? '✅' : '❌'}');
  });

  final allValid = dependencies.values.every((v) => v);
  if (!allValid) {
    throw Exception('❌ Some dependencies are not registered');
  }

  debugPrint('✅ All dependencies validated successfully');
}

/// Obtiene estadísticas de las dependencias registradas
Map<String, dynamic> getDependencyStats() {
  final registeredTypes = <String>[];

  // Obtener tipos registrados manualmente ya que allReady() retorna Future<void>
  try {
    if (sl.isRegistered<Dio>()) registeredTypes.add('Dio');
    if (sl.isRegistered<BinanceWebSocketDataSource>()) {
      registeredTypes.add('BinanceWebSocketDataSource');
    }
    if (sl.isRegistered<BinanceRestDataSource>()) {
      registeredTypes.add('BinanceRestDataSource');
    }
    if (sl.isRegistered<MarketDataRepository>()) {
      registeredTypes.add('MarketDataRepository');
    }
    if (sl.isRegistered<GetTickerStreamUseCase>()) {
      registeredTypes.add('GetTickerStreamUseCase');
    }
    if (sl.isRegistered<GetMiniTickerStreamUseCase>()) {
      registeredTypes.add('GetMiniTickerStreamUseCase');
    }
    if (sl.isRegistered<GetDepthStreamUseCase>()) {
      registeredTypes.add('GetDepthStreamUseCase');
    }
    if (sl.isRegistered<GetInitialMarketDataUseCase>()) {
      registeredTypes.add('GetInitialMarketDataUseCase');
    }
    if (sl.isRegistered<MarketDataBloc>()) {
      registeredTypes.add('MarketDataBloc');
    }
  } catch (e) {
    debugPrint('Error getting dependency stats: $e');
  }

  return {
    'totalRegistered': registeredTypes.length,
    'readyDependencies': registeredTypes,
    'factoryDependencies': _getFactoryDependencies(),
    'singletonDependencies': _getSingletonDependencies(),
  };
}

List<String> _getFactoryDependencies() {
  // Dependencias registradas como factory (se crean nuevas instancias)
  return ['MarketDataBloc'];
}

List<String> _getSingletonDependencies() {
  // Dependencias registradas como singleton (instancia única)
  return [
    'Dio',
    'BinanceWebSocketDataSource',
    'BinanceRestDataSource',
    'MarketDataRepository',
    'GetTickerStreamUseCase',
    'GetMiniTickerStreamUseCase',
    'GetDepthStreamUseCase',
    'GetInitialMarketDataUseCase',
  ];
}

/// Extensiones para facilitar el acceso desde cualquier parte de la app
extension DependencyInjectionExtensions on GetIt {
  // Data Sources
  BinanceWebSocketDataSource get webSocketDataSource =>
      get<BinanceWebSocketDataSource>();
  BinanceRestDataSource get restDataSource => get<BinanceRestDataSource>();

  // Repository
  MarketDataRepository get marketDataRepository => get<MarketDataRepository>();

  // Use Cases
  GetTickerStreamUseCase get getTickerStreamUseCase =>
      get<GetTickerStreamUseCase>();
  GetMiniTickerStreamUseCase get getMiniTickerStreamUseCase =>
      get<GetMiniTickerStreamUseCase>();
  GetDepthStreamUseCase get getDepthStreamUseCase =>
      get<GetDepthStreamUseCase>();
  GetInitialMarketDataUseCase get getInitialMarketDataUseCase =>
      get<GetInitialMarketDataUseCase>();

  // BLoCs
  MarketDataBloc get marketDataBloc => get<MarketDataBloc>();
}

/// Configuración de ambiente (development, staging, production)
enum Environment { development, staging, production }

class EnvironmentConfig {
  static Environment _currentEnvironment = Environment.development;

  static Environment get currentEnvironment => _currentEnvironment;

  static void setEnvironment(Environment env) {
    _currentEnvironment = env;
  }

  static String get binanceBaseUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'https://testnet.binance.vision/api/v3'; // Testnet para desarrollo
      case Environment.staging:
        return 'https://api.binance.com/api/v3'; // API real para staging
      case Environment.production:
        return 'https://api.binance.com/api/v3'; // API real para producción
    }
  }

  static String get binanceWebSocketUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'wss://testnet.binance.vision/ws'; // WebSocket testnet
      case Environment.staging:
      case Environment.production:
        return 'wss://stream.binance.com:9443/ws'; // WebSocket real
    }
  }

  static bool get enableLogging =>
      _currentEnvironment != Environment.production;

  static Duration get connectionTimeout {
    switch (_currentEnvironment) {
      case Environment.development:
        return const Duration(seconds: 30); // Más tiempo para debugging
      case Environment.staging:
      case Environment.production:
        return const Duration(seconds: 10);
    }
  }
}

/// Inicialización con configuración de ambiente
Future<void> initializeDependenciesWithEnvironment(
  Environment environment,
) async {
  EnvironmentConfig.setEnvironment(environment);
  await initializeDependencies();

  debugPrint('🌍 Environment: ${environment.name}');
  debugPrint('🔗 Binance API: ${EnvironmentConfig.binanceBaseUrl}');
  debugPrint('🔌 WebSocket: ${EnvironmentConfig.binanceWebSocketUrl}');
}

/// Utilidades para debugging
class DependencyDebugUtils {
  /// Imprime todas las dependencias registradas
  static void debugPrintAllDependencies() {
    debugPrint('=== REGISTERED DEPENDENCIES ===');
    final stats = getDependencyStats();
    debugPrint('Total: ${stats['totalRegistered']}');
    debugPrint('Singletons: ${stats['singletonDependencies']}');
    debugPrint('Factories: ${stats['factoryDependencies']}');
    debugPrint('==============================');
  }

  /// Verifica la salud de las dependencias críticas
  static Future<Map<String, bool>> checkDependencyHealth() async {
    final healthStatus = <String, bool>{};

    try {
      // Verificar repository
      final repository = sl<MarketDataRepository>();
      healthStatus['repository'] = await repository.checkConnectivity();
    } catch (e) {
      healthStatus['repository'] = false;
    }

    try {
      // Verificar REST API
      final restDataSource = sl<BinanceRestDataSource>();
      healthStatus['restApi'] = await restDataSource.checkConnectivity();
    } catch (e) {
      healthStatus['restApi'] = false;
    }

    try {
      // Verificar que se puede crear BLoC
      final bloc = sl<MarketDataBloc>();
      healthStatus['bloc'] = bloc.state is MarketDataInitial;
      bloc.close(); // Cerrar inmediatamente para no dejar recursos abiertos
    } catch (e) {
      healthStatus['bloc'] = false;
    }

    return healthStatus;
  }
}
