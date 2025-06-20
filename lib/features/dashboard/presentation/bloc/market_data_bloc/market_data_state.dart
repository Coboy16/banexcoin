part of 'market_data_bloc.dart';

sealed class MarketDataState extends Equatable {
  const MarketDataState();

  @override
  List<Object> get props => [];
}

final class MarketDataInitial extends MarketDataState {}

/// Cargando datos iniciales
class MarketDataLoading extends MarketDataState {
  final String? message;

  const MarketDataLoading({this.message});

  @override
  List<Object> get props => [message ?? ''];
}

/// Datos cargados y streams activos
class MarketDataLoaded extends MarketDataState {
  final Map<String, TickerEntity> tickers;
  final Map<String, MiniTickerEntity> miniTickers;
  final Map<String, DepthEntity> orderBooks;
  final MarketStatistics? marketStatistics;
  final ExchangeInfo? exchangeInfo;
  final List<String> activeSymbols;
  final List<String> watchlist;
  final bool isConnected;
  final bool streamsActive;
  final DateTime lastUpdated;
  final Map<String, DateTime> lastTickerUpdates;
  final Map<String, ConnectionStatus> connectionStatuses;

  const MarketDataLoaded({
    required this.tickers,
    required this.miniTickers,
    required this.orderBooks,
    this.marketStatistics,
    this.exchangeInfo,
    required this.activeSymbols,
    required this.watchlist,
    required this.isConnected,
    required this.streamsActive,
    required this.lastUpdated,
    required this.lastTickerUpdates,
    required this.connectionStatuses,
  });

  @override
  List<Object> get props => [
    tickers,
    miniTickers,
    orderBooks,
    marketStatistics ?? '',
    exchangeInfo ?? '',
    activeSymbols,
    watchlist,
    isConnected,
    streamsActive,
    lastUpdated,
    lastTickerUpdates,
    connectionStatuses,
  ];

  /// Copia el estado con valores actualizados
  MarketDataLoaded copyWith({
    Map<String, TickerEntity>? tickers,
    Map<String, MiniTickerEntity>? miniTickers,
    Map<String, DepthEntity>? orderBooks,
    MarketStatistics? marketStatistics,
    ExchangeInfo? exchangeInfo,
    List<String>? activeSymbols,
    List<String>? watchlist,
    bool? isConnected,
    bool? streamsActive,
    DateTime? lastUpdated,
    Map<String, DateTime>? lastTickerUpdates,
    Map<String, ConnectionStatus>? connectionStatuses,
  }) {
    return MarketDataLoaded(
      tickers: tickers ?? this.tickers,
      miniTickers: miniTickers ?? this.miniTickers,
      orderBooks: orderBooks ?? this.orderBooks,
      marketStatistics: marketStatistics ?? this.marketStatistics,
      exchangeInfo: exchangeInfo ?? this.exchangeInfo,
      activeSymbols: activeSymbols ?? this.activeSymbols,
      watchlist: watchlist ?? this.watchlist,
      isConnected: isConnected ?? this.isConnected,
      streamsActive: streamsActive ?? this.streamsActive,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      lastTickerUpdates: lastTickerUpdates ?? this.lastTickerUpdates,
      connectionStatuses: connectionStatuses ?? this.connectionStatuses,
    );
  }

  /// Obtiene ticker por símbolo
  TickerEntity? getTickerBySymbol(String symbol) {
    return tickers[symbol.toUpperCase()];
  }

  /// Obtiene mini ticker por símbolo
  MiniTickerEntity? getMiniTickerBySymbol(String symbol) {
    return miniTickers[symbol.toUpperCase()];
  }

  /// Obtiene order book por símbolo
  DepthEntity? getOrderBookBySymbol(String symbol) {
    return orderBooks[symbol.toUpperCase()];
  }

  /// Obtiene top gainers
  List<TickerEntity> getTopGainers({int limit = 10}) {
    final sortedTickers = tickers.values.toList()
      ..sort(
        (a, b) => b.priceChangePercentAsDouble.compareTo(
          a.priceChangePercentAsDouble,
        ),
      );

    return sortedTickers
        .where((ticker) => ticker.isPriceChangePositive)
        .take(limit)
        .toList();
  }

  /// Obtiene top losers
  List<TickerEntity> getTopLosers({int limit = 10}) {
    final sortedTickers = tickers.values.toList()
      ..sort(
        (a, b) => a.priceChangePercentAsDouble.compareTo(
          b.priceChangePercentAsDouble,
        ),
      );

    return sortedTickers
        .where((ticker) => !ticker.isPriceChangePositive)
        .take(limit)
        .toList();
  }

  /// Obtiene símbolos más activos por volumen
  List<TickerEntity> getMostActive({int limit = 10}) {
    final sortedTickers = tickers.values.toList()
      ..sort((a, b) {
        final volumeA = double.tryParse(a.quoteVolume) ?? 0;
        final volumeB = double.tryParse(b.quoteVolume) ?? 0;
        return volumeB.compareTo(volumeA);
      });

    return sortedTickers.take(limit).toList();
  }

  /// Verifica si un símbolo está en watchlist
  bool isInWatchlist(String symbol) {
    return watchlist.contains(symbol.toUpperCase());
  }

  /// Obtiene estado de conexión para un símbolo
  ConnectionStatus getConnectionStatus(String symbol) {
    return connectionStatuses[symbol.toUpperCase()] ??
        ConnectionStatus.disconnected;
  }

  /// Verifica si los datos están frescos
  bool get isDataFresh {
    const freshnessDuration = Duration(minutes: 5);
    return DateTime.now().difference(lastUpdated) < freshnessDuration;
  }

  /// Obtiene cantidad de conexiones activas
  int get activeConnectionsCount {
    return connectionStatuses.values
        .where((status) => status == ConnectionStatus.connected)
        .length;
  }

  /// Obtiene resumen del estado
  String get statusSummary {
    return 'Símbolos: ${activeSymbols.length} | '
        'Conexiones: $activeConnectionsCount | '
        'Watchlist: ${watchlist.length} | '
        'Conectado: ${isConnected ? 'Sí' : 'No'}';
  }
}

/// Error en el BLoC
class MarketDataError extends MarketDataState {
  final String message;
  final String? errorCode;
  final String? symbol; // Símbolo específico si aplica
  final bool isConnectionError;
  final bool isRetryable;
  final DateTime timestamp;

  const MarketDataError({
    required this.message,
    this.errorCode,
    this.symbol,
    this.isConnectionError = false,
    this.isRetryable = true,
    required this.timestamp,
  });

  @override
  List<Object> get props => [
    message,
    errorCode ?? '',
    symbol ?? '',
    isConnectionError,
    isRetryable,
    timestamp,
  ];

  /// Crea error de conexión
  factory MarketDataError.connection({
    required String message,
    String? symbol,
  }) {
    return MarketDataError(
      message: message,
      symbol: symbol,
      isConnectionError: true,
      isRetryable: true,
      timestamp: DateTime.now(),
    );
  }

  /// Crea error de validación
  factory MarketDataError.validation({
    required String message,
    String? symbol,
  }) {
    return MarketDataError(
      message: message,
      symbol: symbol,
      isConnectionError: false,
      isRetryable: false,
      timestamp: DateTime.now(),
    );
  }

  /// Crea error de API
  factory MarketDataError.api({
    required String message,
    String? errorCode,
    String? symbol,
    bool isRetryable = true,
  }) {
    return MarketDataError(
      message: message,
      errorCode: errorCode,
      symbol: symbol,
      isConnectionError: false,
      isRetryable: isRetryable,
      timestamp: DateTime.now(),
    );
  }

  /// Obtiene mensaje de error amigable
  String get friendlyMessage {
    if (isConnectionError) {
      return 'Error de conexión. Verificando conectividad...';
    }

    switch (errorCode) {
      case '429':
        return 'Límite de velocidad excedido. Reintentando...';
      case '404':
        return 'Símbolo no encontrado: ${symbol ?? 'desconocido'}';
      case '500':
        return 'Error del servidor. Reintentando...';
      default:
        return message;
    }
  }
}

/// Estado de actualización en tiempo real
class MarketDataUpdating extends MarketDataState {
  final MarketDataLoaded previousState;
  final String symbol;
  final UpdateType updateType;

  const MarketDataUpdating({
    required this.previousState,
    required this.symbol,
    required this.updateType,
  });

  @override
  List<Object> get props => [previousState, symbol, updateType];
}

/// Enumeraciones auxiliares

/// Estado de conexión de un símbolo
enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error;

  String get displayName {
    switch (this) {
      case ConnectionStatus.disconnected:
        return 'Desconectado';
      case ConnectionStatus.connecting:
        return 'Conectando';
      case ConnectionStatus.connected:
        return 'Conectado';
      case ConnectionStatus.reconnecting:
        return 'Reconectando';
      case ConnectionStatus.error:
        return 'Error';
    }
  }

  bool get isConnected => this == ConnectionStatus.connected;
}

/// Tipo de actualización en tiempo real
enum UpdateType {
  ticker,
  miniTicker,
  depth,
  statistics;

  String get displayName {
    switch (this) {
      case UpdateType.ticker:
        return 'Ticker';
      case UpdateType.miniTicker:
        return 'Mini Ticker';
      case UpdateType.depth:
        return 'Libro de Órdenes';
      case UpdateType.statistics:
        return 'Estadísticas';
    }
  }
}
