part of 'market_data_bloc.dart';

sealed class MarketDataEvent extends Equatable {
  const MarketDataEvent();

  @override
  List<Object> get props => [];
}

/// Inicializar datos de mercado con símbolos específicos
class InitializeMarketData extends MarketDataEvent {
  final List<String> symbols;
  final bool enableRealTimeStreams;
  final bool loadStatistics;

  const InitializeMarketData({
    required this.symbols,
    this.enableRealTimeStreams = true,
    this.loadStatistics = true,
  });

  @override
  List<Object> get props => [symbols, enableRealTimeStreams, loadStatistics];
}

/// Suscribirse a stream de ticker para un símbolo
class SubscribeToTicker extends MarketDataEvent {
  final String symbol;

  const SubscribeToTicker(this.symbol);

  @override
  List<Object> get props => [symbol];
}

/// Desuscribirse de stream de ticker
class UnsubscribeFromTicker extends MarketDataEvent {
  final String symbol;

  const UnsubscribeFromTicker(this.symbol);

  @override
  List<Object> get props => [symbol];
}

/// Suscribirse a stream de mini ticker para múltiples símbolos
class SubscribeToMiniTickers extends MarketDataEvent {
  final List<String> symbols;
  final double? minChangePercent;
  final bool? onlyPositiveChanges;

  const SubscribeToMiniTickers({
    required this.symbols,
    this.minChangePercent,
    this.onlyPositiveChanges,
  });

  @override
  List<Object> get props => [
    symbols,
    minChangePercent ?? 0,
    onlyPositiveChanges ?? false,
  ];
}

/// Suscribirse a stream de depth/order book
class SubscribeToDepth extends MarketDataEvent {
  final String symbol;
  final int maxLevels;
  final bool enableSpreadAlerts;

  const SubscribeToDepth({
    required this.symbol,
    this.maxLevels = 20,
    this.enableSpreadAlerts = false,
  });

  @override
  List<Object> get props => [symbol, maxLevels, enableSpreadAlerts];
}

/// Actualizar configuración de streams
class UpdateStreamConfig extends MarketDataEvent {
  final Duration? throttleInterval;
  final bool? enableCache;
  final Duration? cacheExpiration;

  const UpdateStreamConfig({
    this.throttleInterval,
    this.enableCache,
    this.cacheExpiration,
  });

  @override
  List<Object> get props => [
    throttleInterval ?? Duration(),
    enableCache ?? false,
    cacheExpiration ?? Duration(),
  ];
}

/// Refrescar datos iniciales
class RefreshInitialData extends MarketDataEvent {
  final List<String>? symbols;

  const RefreshInitialData({this.symbols});

  @override
  List<Object> get props => [symbols ?? []];
}

/// Verificar conectividad
class CheckConnectivity extends MarketDataEvent {
  const CheckConnectivity();
}

/// Obtener estadísticas del mercado
class LoadMarketStatistics extends MarketDataEvent {
  const LoadMarketStatistics();
}

/// Obtener top movers (mayores cambios)
class LoadTopMovers extends MarketDataEvent {
  final int topCount;
  final bool ascending; // false = descendente (mayores cambios primero)

  const LoadTopMovers({this.topCount = 10, this.ascending = false});

  @override
  List<Object> get props => [topCount, ascending];
}

/// Buscar símbolo específico
class SearchSymbol extends MarketDataEvent {
  final String query;
  final int maxResults;

  const SearchSymbol({required this.query, this.maxResults = 20});

  @override
  List<Object> get props => [query, maxResults];
}

/// Agregar símbolo a watchlist
class AddToWatchlist extends MarketDataEvent {
  final String symbol;

  const AddToWatchlist(this.symbol);

  @override
  List<Object> get props => [symbol];
}

/// Remover símbolo de watchlist
class RemoveFromWatchlist extends MarketDataEvent {
  final String symbol;

  const RemoveFromWatchlist(this.symbol);

  @override
  List<Object> get props => [symbol];
}

/// Manejar error de conexión
class HandleConnectionError extends MarketDataEvent {
  final String error;
  final String? symbol; // Símbolo específico si aplica

  const HandleConnectionError({required this.error, this.symbol});

  @override
  List<Object> get props => [error, symbol ?? ''];
}

/// Limpiar errores
class ClearErrors extends MarketDataEvent {
  const ClearErrors();
}

/// Pausar/reanudar streams
class ToggleStreams extends MarketDataEvent {
  final bool pause;

  const ToggleStreams(this.pause);

  @override
  List<Object> get props => [pause];
}

/// Cerrar todas las conexiones
class DisposeMarketData extends MarketDataEvent {
  const DisposeMarketData();
}
