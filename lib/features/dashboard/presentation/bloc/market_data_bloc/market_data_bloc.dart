import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '/features/features.dart';

part 'market_data_event.dart';
part 'market_data_state.dart';

class MarketDataBloc extends Bloc<MarketDataEvent, MarketDataState> {
  final GetTickerStreamUseCase _getTickerStreamUseCase;
  final GetMiniTickerStreamUseCase _getMiniTickerStreamUseCase;
  final GetDepthStreamUseCase _getDepthStreamUseCase;
  final GetInitialMarketDataUseCase _getInitialMarketDataUseCase;
  final MarketDataRepository _repository;

  // Suscripciones activas de streams
  final Map<String, StreamSubscription> _tickerSubscriptions = {};
  final Map<String, StreamSubscription> _miniTickerSubscriptions = {};
  final Map<String, StreamSubscription> _depthSubscriptions = {};

  // Estado interno
  final Map<String, TickerEntity> _tickers = {};
  final Map<String, MiniTickerEntity> _miniTickers = {};
  final Map<String, DepthEntity> _orderBooks = {};
  final List<String> _watchlist = [];
  final Map<String, DateTime> _lastUpdates = {};
  final Map<String, ConnectionStatus> _connectionStatuses = {};

  // Configuración
  bool _streamsEnabled = true;
  Timer? _connectivityTimer;
  Timer? _statisticsTimer;
  MarketStatistics? _currentStatistics;
  ExchangeInfo? _exchangeInfo;
  bool _isConnected = false;

  MarketDataBloc({
    required GetTickerStreamUseCase getTickerStreamUseCase,
    required GetMiniTickerStreamUseCase getMiniTickerStreamUseCase,
    required GetDepthStreamUseCase getDepthStreamUseCase,
    required GetInitialMarketDataUseCase getInitialMarketDataUseCase,
    required MarketDataRepository repository,
  }) : _getTickerStreamUseCase = getTickerStreamUseCase,
       _getMiniTickerStreamUseCase = getMiniTickerStreamUseCase,
       _getDepthStreamUseCase = getDepthStreamUseCase,
       _getInitialMarketDataUseCase = getInitialMarketDataUseCase,
       _repository = repository,
       super(MarketDataInitial()) {
    // Registrar manejadores de eventos
    on<InitializeMarketData>(_onInitializeMarketData);
    on<SubscribeToTicker>(_onSubscribeToTicker);
    on<UnsubscribeFromTicker>(_onUnsubscribeFromTicker);
    on<SubscribeToMiniTickers>(_onSubscribeToMiniTickers);
    on<SubscribeToDepth>(_onSubscribeToDepth);
    on<UpdateStreamConfig>(_onUpdateStreamConfig);
    on<RefreshInitialData>(_onRefreshInitialData);
    on<CheckConnectivity>(_onCheckConnectivity);
    on<LoadMarketStatistics>(_onLoadMarketStatistics);
    on<LoadTopMovers>(_onLoadTopMovers);
    on<SearchSymbol>(_onSearchSymbol);
    on<AddToWatchlist>(_onAddToWatchlist);
    on<RemoveFromWatchlist>(_onRemoveFromWatchlist);
    on<HandleConnectionError>(_onHandleConnectionError);
    on<ClearErrors>(_onClearErrors);
    on<ToggleStreams>(_onToggleStreams);
    on<DisposeMarketData>(_onDisposeMarketData);

    // Evento interno para actualizaciones de streams
    on<_InternalTickerUpdate>(_onInternalTickerUpdate);
    on<_InternalMiniTickerUpdate>(_onInternalMiniTickerUpdate);
    on<_InternalDepthUpdate>(_onInternalDepthUpdate);
    on<_InternalConnectionError>(_onInternalConnectionError);

    // Iniciar timers periódicos
    _startPeriodicTasks();
  }

  /// Inicializa datos de mercado con símbolos específicos
  Future<void> _onInitializeMarketData(
    InitializeMarketData event,
    Emitter<MarketDataState> emit,
  ) async {
    try {
      emit(
        const MarketDataLoading(message: 'Inicializando datos de mercado...'),
      );

      // Obtener datos iniciales
      final initialData = await _getInitialMarketDataUseCase.executeWithConfig(
        symbols: event.symbols,
        includeStatistics: event.loadStatistics,
        checkConnectivity: true,
      );

      // Actualizar estado interno
      for (final ticker in initialData.tickers) {
        _tickers[ticker.symbol] = ticker;
        _lastUpdates[ticker.symbol] = DateTime.now();
        _connectionStatuses[ticker.symbol] = ConnectionStatus.disconnected;
      }

      _currentStatistics = initialData.statistics;
      _isConnected = initialData.isConnected;

      // Emitir estado cargado inicial
      emit(
        MarketDataLoaded(
          tickers: Map.from(_tickers),
          miniTickers: Map.from(_miniTickers),
          orderBooks: Map.from(_orderBooks),
          marketStatistics: _currentStatistics,
          exchangeInfo: _exchangeInfo,
          activeSymbols: event.symbols,
          watchlist: List.from(_watchlist),
          isConnected: _isConnected,
          streamsActive: false,
          lastUpdated: initialData.loadedAt,
          lastTickerUpdates: Map.from(_lastUpdates),
          connectionStatuses: Map.from(_connectionStatuses),
        ),
      );

      // Habilitar streams en tiempo real si está solicitado
      if (event.enableRealTimeStreams && _isConnected) {
        for (final symbol in event.symbols) {
          add(SubscribeToTicker(symbol));
        }
      }
    } catch (e) {
      emit(
        MarketDataError.api(
          message: 'Error inicializando datos de mercado: $e',
          isRetryable: true,
        ),
      );
    }
  }

  /// Suscribe a stream de ticker para un símbolo
  Future<void> _onSubscribeToTicker(
    SubscribeToTicker event,
    Emitter<MarketDataState> emit,
  ) async {
    final symbol = event.symbol.toUpperCase();

    try {
      // Evitar suscripciones duplicadas
      if (_tickerSubscriptions.containsKey(symbol)) {
        return;
      }

      _connectionStatuses[symbol] = ConnectionStatus.connecting;
      _emitCurrentState(emit);

      // Crear suscripción al stream usando eventos internos
      final stream = _getTickerStreamUseCase.execute(symbol);
      final subscription = stream.listen(
        (ticker) {
          // Usar evento interno en lugar de emit directo
          add(_InternalTickerUpdate(ticker));
        },
        onError: (error) {
          add(_InternalConnectionError(error.toString(), symbol));
        },
      );

      _tickerSubscriptions[symbol] = subscription;
    } catch (e) {
      _connectionStatuses[symbol] = ConnectionStatus.error;
      emit(
        MarketDataError.connection(
          message: 'Error suscribiendo a ticker $symbol: $e',
          symbol: symbol,
        ),
      );
    }
  }

  /// Maneja actualizaciones internas de ticker
  Future<void> _onInternalTickerUpdate(
    _InternalTickerUpdate event,
    Emitter<MarketDataState> emit,
  ) async {
    final ticker = event.ticker;
    _tickers[ticker.symbol] = ticker;
    _lastUpdates[ticker.symbol] = DateTime.now();
    _connectionStatuses[ticker.symbol] = ConnectionStatus.connected;

    if (_streamsEnabled) {
      _emitCurrentState(emit);
    }
  }

  /// Maneja actualizaciones internas de mini ticker
  Future<void> _onInternalMiniTickerUpdate(
    _InternalMiniTickerUpdate event,
    Emitter<MarketDataState> emit,
  ) async {
    final miniTicker = event.miniTicker;
    _miniTickers[miniTicker.symbol] = miniTicker;
    _lastUpdates[miniTicker.symbol] = DateTime.now();
    _connectionStatuses[miniTicker.symbol] = ConnectionStatus.connected;

    if (_streamsEnabled) {
      _emitCurrentState(emit);
    }
  }

  /// Maneja actualizaciones internas de depth
  Future<void> _onInternalDepthUpdate(
    _InternalDepthUpdate event,
    Emitter<MarketDataState> emit,
  ) async {
    // final depth = event.depth;
    // _orderBooks[depth.symbol] = depth;
    // _lastUpdates[depth.symbol] = DateTime.now();
    // _connectionStatuses[depth.symbol] = ConnectionStatus.connected;

    if (_streamsEnabled) {
      _emitCurrentState(emit);
    }
  }

  /// Maneja errores internos de conexión
  Future<void> _onInternalConnectionError(
    _InternalConnectionError event,
    Emitter<MarketDataState> emit,
  ) async {
    if (event.symbol != null) {
      _connectionStatuses[event.symbol!] = ConnectionStatus.error;

      // Intentar reconectar después de un delay
      Timer(const Duration(seconds: 5), () {
        if (event.symbol != null) {
          _connectionStatuses[event.symbol!] = ConnectionStatus.reconnecting;
          add(SubscribeToTicker(event.symbol!));
        }
      });
    }

    emit(
      MarketDataError.connection(message: event.error, symbol: event.symbol),
    );
  }

  /// Desuscribe de stream de ticker
  Future<void> _onUnsubscribeFromTicker(
    UnsubscribeFromTicker event,
    Emitter<MarketDataState> emit,
  ) async {
    final symbol = event.symbol.toUpperCase();

    await _tickerSubscriptions[symbol]?.cancel();
    _tickerSubscriptions.remove(symbol);
    _connectionStatuses[symbol] = ConnectionStatus.disconnected;

    _emitCurrentState(emit);
  }

  /// Suscribe a streams de mini ticker para múltiples símbolos
  Future<void> _onSubscribeToMiniTickers(
    SubscribeToMiniTickers event,
    Emitter<MarketDataState> emit,
  ) async {
    try {
      final streams = _getMiniTickerStreamUseCase.executeWithFilter(
        symbols: event.symbols,
        minChangePercent: event.minChangePercent ?? 0.0,
        onlyPositiveChanges: event.onlyPositiveChanges ?? false,
      );

      for (final entry in streams.entries) {
        final symbol = entry.key;
        final stream = entry.value;

        // Evitar suscripciones duplicadas
        if (_miniTickerSubscriptions.containsKey(symbol)) {
          continue;
        }

        _connectionStatuses[symbol] = ConnectionStatus.connecting;

        final subscription = stream.listen(
          (miniTicker) {
            add(_InternalMiniTickerUpdate(miniTicker));
          },
          onError: (error) {
            add(_InternalConnectionError(error.toString(), symbol));
          },
        );

        _miniTickerSubscriptions[symbol] = subscription;
      }

      _emitCurrentState(emit);
    } catch (e) {
      emit(
        MarketDataError.api(
          message: 'Error suscribiendo a mini tickers: $e',
          isRetryable: true,
        ),
      );
    }
  }

  /// Suscribe a stream de depth/order book
  Future<void> _onSubscribeToDepth(
    SubscribeToDepth event,
    Emitter<MarketDataState> emit,
  ) async {
    final symbol = event.symbol.toUpperCase();

    try {
      // Evitar suscripciones duplicadas
      if (_depthSubscriptions.containsKey(symbol)) {
        return;
      }

      _connectionStatuses[symbol] = ConnectionStatus.connecting;
      _emitCurrentState(emit);

      final stream = _getDepthStreamUseCase.execute(symbol);

      final subscription = stream.listen(
        (depth) {
          add(_InternalDepthUpdate(depth));
        },
        onError: (error) {
          add(_InternalConnectionError(error.toString(), symbol));
        },
      );

      _depthSubscriptions[symbol] = subscription;
    } catch (e) {
      _connectionStatuses[symbol] = ConnectionStatus.error;
      emit(
        MarketDataError.connection(
          message: 'Error suscribiendo a depth $symbol: $e',
          symbol: symbol,
        ),
      );
    }
  }

  /// Actualiza configuración de streams
  Future<void> _onUpdateStreamConfig(
    UpdateStreamConfig event,
    Emitter<MarketDataState> emit,
  ) async {
    _emitCurrentState(emit);
  }

  /// Refresca datos iniciales
  Future<void> _onRefreshInitialData(
    RefreshInitialData event,
    Emitter<MarketDataState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! MarketDataLoaded) return;

      emit(const MarketDataLoading(message: 'Actualizando datos...'));

      final symbols = event.symbols ?? currentState.activeSymbols;
      final initialData = await _getInitialMarketDataUseCase.execute(symbols);

      // Actualizar datos sin perder conexiones activas
      for (final ticker in initialData.tickers) {
        _tickers[ticker.symbol] = ticker;
      }

      _currentStatistics = initialData.statistics;
      _isConnected = initialData.isConnected;

      emit(
        currentState.copyWith(
          tickers: Map.from(_tickers),
          marketStatistics: _currentStatistics,
          isConnected: _isConnected,
          lastUpdated: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(
        MarketDataError.api(
          message: 'Error refrescando datos: $e',
          isRetryable: true,
        ),
      );
    }
  }

  /// Verifica conectividad
  Future<void> _onCheckConnectivity(
    CheckConnectivity event,
    Emitter<MarketDataState> emit,
  ) async {
    try {
      final isConnected = await _repository.checkConnectivity();
      _isConnected = isConnected;

      if (state is MarketDataLoaded) {
        final currentState = state as MarketDataLoaded;
        emit(
          currentState.copyWith(
            isConnected: isConnected,
            lastUpdated: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      emit(
        MarketDataError.connection(
          message: 'Error verificando conectividad: $e',
        ),
      );
    }
  }

  /// Carga estadísticas del mercado
  Future<void> _onLoadMarketStatistics(
    LoadMarketStatistics event,
    Emitter<MarketDataState> emit,
  ) async {
    try {
      final statistics = await _repository.getMarketStatistics();
      _currentStatistics = statistics;

      if (state is MarketDataLoaded) {
        final currentState = state as MarketDataLoaded;
        emit(
          currentState.copyWith(
            marketStatistics: statistics,
            lastUpdated: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error cargando estadísticas: $e');
      // No emitir error para estadísticas, es información secundaria
    }
  }

  /// Carga top movers
  Future<void> _onLoadTopMovers(
    LoadTopMovers event,
    Emitter<MarketDataState> emit,
  ) async {
    try {
      if (state is MarketDataLoaded) {
        final currentState = state as MarketDataLoaded;

        // Obtener top movers de los datos actuales
        currentState.getTopGainers(limit: event.topCount);
        currentState.getTopLosers(limit: event.topCount);

        _emitCurrentState(emit);
      }
    } catch (e) {
      debugPrint('Error cargando top movers: $e');
    }
  }

  /// Busca símbolo
  Future<void> _onSearchSymbol(
    SearchSymbol event,
    Emitter<MarketDataState> emit,
  ) async {
    try {
      final query = event.query.trim().toUpperCase();
      if (query.length >= 6) {
        add(AddToWatchlist(query));
      }
    } catch (e) {
      debugPrint('Error buscando símbolo: $e');
    }
  }

  /// Agrega símbolo a watchlist
  Future<void> _onAddToWatchlist(
    AddToWatchlist event,
    Emitter<MarketDataState> emit,
  ) async {
    final symbol = event.symbol.toUpperCase();

    if (!_watchlist.contains(symbol)) {
      _watchlist.add(symbol);

      // Suscribir automáticamente si no está suscrito
      if (!_tickerSubscriptions.containsKey(symbol)) {
        add(SubscribeToTicker(symbol));
      }

      _emitCurrentState(emit);
    }
  }

  /// Remueve símbolo de watchlist
  Future<void> _onRemoveFromWatchlist(
    RemoveFromWatchlist event,
    Emitter<MarketDataState> emit,
  ) async {
    final symbol = event.symbol.toUpperCase();

    _watchlist.remove(symbol);

    // Opcionalmente desuscribir si no está en símbolos activos
    if (state is MarketDataLoaded) {
      final currentState = state as MarketDataLoaded;
      if (!currentState.activeSymbols.contains(symbol)) {
        add(UnsubscribeFromTicker(symbol));
      }
    }

    _emitCurrentState(emit);
  }

  /// Maneja errores de conexión
  Future<void> _onHandleConnectionError(
    HandleConnectionError event,
    Emitter<MarketDataState> emit,
  ) async {
    if (event.symbol != null) {
      _connectionStatuses[event.symbol!] = ConnectionStatus.error;

      // Intentar reconectar después de un delay
      Timer(const Duration(seconds: 5), () {
        if (event.symbol != null) {
          _connectionStatuses[event.symbol!] = ConnectionStatus.reconnecting;
          add(SubscribeToTicker(event.symbol!));
        }
      });
    }

    emit(
      MarketDataError.connection(message: event.error, symbol: event.symbol),
    );
  }

  /// Limpia errores
  Future<void> _onClearErrors(
    ClearErrors event,
    Emitter<MarketDataState> emit,
  ) async {
    if (state is MarketDataError) {
      _emitCurrentState(emit);
    }
  }

  /// Pausa/reanuda streams
  Future<void> _onToggleStreams(
    ToggleStreams event,
    Emitter<MarketDataState> emit,
  ) async {
    _streamsEnabled = !event.pause;

    if (state is MarketDataLoaded) {
      final currentState = state as MarketDataLoaded;
      emit(
        currentState.copyWith(
          streamsActive: _streamsEnabled,
          lastUpdated: DateTime.now(),
        ),
      );
    }
  }

  /// Cierra todas las conexiones
  Future<void> _onDisposeMarketData(
    DisposeMarketData event,
    Emitter<MarketDataState> emit,
  ) async {
    await _disposeAllSubscriptions();
    _stopPeriodicTasks();
    await _repository.dispose();

    emit(MarketDataInitial());
  }

  /// Emite estado actual de forma segura
  void _emitCurrentState(Emitter<MarketDataState> emit) {
    if (state is MarketDataLoaded) {
      final currentState = state as MarketDataLoaded;
      emit(
        currentState.copyWith(
          tickers: Map.from(_tickers),
          miniTickers: Map.from(_miniTickers),
          orderBooks: Map.from(_orderBooks),
          watchlist: List.from(_watchlist),
          lastUpdated: DateTime.now(),
          lastTickerUpdates: Map.from(_lastUpdates),
          connectionStatuses: Map.from(_connectionStatuses),
        ),
      );
    } else {
      // Crear nuevo estado si no existe uno válido
      emit(
        MarketDataLoaded(
          tickers: Map.from(_tickers),
          miniTickers: Map.from(_miniTickers),
          orderBooks: Map.from(_orderBooks),
          marketStatistics: _currentStatistics,
          exchangeInfo: _exchangeInfo,
          activeSymbols: _tickers.keys.toList(),
          watchlist: List.from(_watchlist),
          isConnected: _isConnected,
          streamsActive: _streamsEnabled,
          lastUpdated: DateTime.now(),
          lastTickerUpdates: Map.from(_lastUpdates),
          connectionStatuses: Map.from(_connectionStatuses),
        ),
      );
    }
  }

  /// Inicia tareas periódicas
  void _startPeriodicTasks() {
    // Verificar conectividad cada 30 segundos
    _connectivityTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => add(const CheckConnectivity()),
    );

    // Actualizar estadísticas cada 5 minutos
    _statisticsTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => add(const LoadMarketStatistics()),
    );
  }

  /// Detiene tareas periódicas
  void _stopPeriodicTasks() {
    _connectivityTimer?.cancel();
    _statisticsTimer?.cancel();
  }

  /// Cierra todas las suscripciones activas
  Future<void> _disposeAllSubscriptions() async {
    // Cancelar suscripciones de ticker
    for (final subscription in _tickerSubscriptions.values) {
      await subscription.cancel();
    }
    _tickerSubscriptions.clear();

    // Cancelar suscripciones de mini ticker
    for (final subscription in _miniTickerSubscriptions.values) {
      await subscription.cancel();
    }
    _miniTickerSubscriptions.clear();

    // Cancelar suscripciones de depth
    for (final subscription in _depthSubscriptions.values) {
      await subscription.cancel();
    }
    _depthSubscriptions.clear();
  }

  /// Obtiene estadísticas de rendimiento del BLoC
  Map<String, dynamic> getPerformanceStats() {
    return {
      'activeTickerSubscriptions': _tickerSubscriptions.length,
      'activeMiniTickerSubscriptions': _miniTickerSubscriptions.length,
      'activeDepthSubscriptions': _depthSubscriptions.length,
      'cachedTickers': _tickers.length,
      'cachedMiniTickers': _miniTickers.length,
      'cachedOrderBooks': _orderBooks.length,
      'watchlistSize': _watchlist.length,
      'streamsEnabled': _streamsEnabled,
      'connectedSymbols': _connectionStatuses.values
          .where((status) => status == ConnectionStatus.connected)
          .length,
    };
  }

  /// Reconectar todos los streams
  Future<void> reconnectAllStreams() async {
    final symbols = _tickerSubscriptions.keys.toList();

    // Cerrar conexiones existentes
    await _disposeAllSubscriptions();

    // Limpiar estados de conexión
    for (final symbol in symbols) {
      _connectionStatuses[symbol] = ConnectionStatus.disconnected;
    }

    // Reconectar
    for (final symbol in symbols) {
      add(SubscribeToTicker(symbol));
    }
  }

  /// Obtiene símbolos más activos (por actualizaciones recientes)
  List<String> getMostActiveSymbols({int limit = 10}) {
    final now = DateTime.now();
    final activeSymbols = _lastUpdates.entries
        .where((entry) => now.difference(entry.value).inMinutes < 5)
        .map((entry) => entry.key)
        .toList();

    activeSymbols.sort((a, b) {
      final lastUpdateA = _lastUpdates[a] ?? DateTime(0);
      final lastUpdateB = _lastUpdates[b] ?? DateTime(0);
      return lastUpdateB.compareTo(lastUpdateA);
    });

    return activeSymbols.take(limit).toList();
  }

  @override
  Future<void> close() async {
    await _disposeAllSubscriptions();
    _stopPeriodicTasks();
    await _repository.dispose();
    return super.close();
  }
}

// Eventos internos para manejar actualizaciones de streams
class _InternalTickerUpdate extends MarketDataEvent {
  final TickerEntity ticker;

  const _InternalTickerUpdate(this.ticker);

  @override
  List<Object> get props => [ticker];
}

class _InternalMiniTickerUpdate extends MarketDataEvent {
  final MiniTickerEntity miniTicker;

  const _InternalMiniTickerUpdate(this.miniTicker);

  @override
  List<Object> get props => [miniTicker];
}

class _InternalDepthUpdate extends MarketDataEvent {
  final DepthEntity depth;

  const _InternalDepthUpdate(this.depth);

  @override
  List<Object> get props => [depth];
}

class _InternalConnectionError extends MarketDataEvent {
  final String error;
  final String? symbol;

  const _InternalConnectionError(this.error, this.symbol);

  @override
  List<Object> get props => [error, symbol ?? ''];
}
