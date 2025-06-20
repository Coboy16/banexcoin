import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '/features/features.dart';

part 'trading_pair_event.dart';
part 'trading_pair_state.dart';

enum TradingPairDataType { tradingPair, priceStats, klines, recentTrades }

class TradingPairBloc extends Bloc<TradingPairEvent, TradingPairState> {
  final GetTradingPairStreamUseCase _getTradingPairStreamUseCase;
  final GetPriceStatsStreamUseCase _getPriceStatsStreamUseCase;
  final GetKlineStreamUseCase _getKlineStreamUseCase;
  final GetRecentTradesStreamUseCase _getRecentTradesStreamUseCase;
  final GetInitialTradingPairDataUseCase _getInitialTradingPairDataUseCase;
  final TradingPairRepository _repository;

  // Subscripciones a streams
  StreamSubscription<TradingPairEntity>? _tradingPairSubscription;
  StreamSubscription<PriceStatsEntity>? _priceStatsSubscription;
  StreamSubscription<List<KlineEntity>>? _klineSubscription;
  StreamSubscription<List<TradeEntity>>? _tradesSubscription;

  // Estado interno
  String? _currentSymbol;
  String _currentInterval = '1h';
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  TradingPairBloc({
    required GetTradingPairStreamUseCase getTradingPairStreamUseCase,
    required GetPriceStatsStreamUseCase getPriceStatsStreamUseCase,
    required GetKlineStreamUseCase getKlineStreamUseCase,
    required GetRecentTradesStreamUseCase getRecentTradesStreamUseCase,
    required GetInitialTradingPairDataUseCase getInitialTradingPairDataUseCase,
    required TradingPairRepository repository,
  }) : _getTradingPairStreamUseCase = getTradingPairStreamUseCase,
       _getPriceStatsStreamUseCase = getPriceStatsStreamUseCase,
       _getKlineStreamUseCase = getKlineStreamUseCase,
       _getRecentTradesStreamUseCase = getRecentTradesStreamUseCase,
       _getInitialTradingPairDataUseCase = getInitialTradingPairDataUseCase,
       _repository = repository,
       super(TradingPairInitial()) {
    on<LoadTradingPairData>(_onLoadTradingPairData);
    on<StartTradingPairStreams>(_onStartTradingPairStreams);
    on<StopTradingPairStreams>(_onStopTradingPairStreams);
    on<ChangeKlineInterval>(_onChangeKlineInterval);
    on<RefreshTradingPairData>(_onRefreshTradingPairData);
    on<TradingPairErrorOccurred>(_onTradingPairErrorOccurred);
    on<_TradingPairDataUpdated>(_onTradingPairDataUpdated);
    on<_PriceStatsUpdated>(_onPriceStatsUpdated);
    on<_KlinesUpdated>(_onKlinesUpdated);
    on<_RecentTradesUpdated>(_onRecentTradesUpdated);
  }

  /// Maneja la carga de datos iniciales
  Future<void> _onLoadTradingPairData(
    LoadTradingPairData event,
    Emitter<TradingPairState> emit,
  ) async {
    try {
      emit(TradingPairLoading(symbol: event.symbol));

      _currentSymbol = event.symbol;

      debugPrint('🔄 Cargando datos iniciales para ${event.symbol}');

      // Obtener datos iniciales
      final initialData = await _getInitialTradingPairDataUseCase.execute(
        event.symbol,
      );

      // Emitir estado con datos cargados
      emit(
        TradingPairLoaded(
          tradingPair: initialData.tradingPair,
          priceStats: initialData.priceStats,
          klines: initialData.klines,
          recentTrades: initialData.recentTrades,
          symbolInfo: initialData.symbolInfo,
          currentInterval: _currentInterval,
          isStreaming: false,
          lastUpdated: DateTime.now(),
        ),
      );

      debugPrint('✅ Datos iniciales cargados para ${event.symbol}');

      // Iniciar streams automáticamente
      add(StartTradingPairStreams(symbol: event.symbol));
    } catch (e) {
      debugPrint('❌ Error cargando datos para ${event.symbol}: $e');

      TradingPairErrorType errorType = TradingPairErrorType.unknown;
      if (e.toString().contains('symbol')) {
        errorType = TradingPairErrorType.symbolNotFound;
      } else if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        errorType = TradingPairErrorType.networkError;
      } else {
        errorType = TradingPairErrorType.dataLoadError;
      }

      emit(
        TradingPairError(
          message: e.toString(),
          symbol: event.symbol,
          type: errorType,
        ),
      );
    }
  }

  /// Maneja el inicio de streams en tiempo real
  Future<void> _onStartTradingPairStreams(
    StartTradingPairStreams event,
    Emitter<TradingPairState> emit,
  ) async {
    if (state is! TradingPairLoaded) return;

    try {
      _currentSymbol = event.symbol;
      _reconnectAttempts = 0;

      debugPrint('🚀 Iniciando streams para ${event.symbol}');

      // Detener streams anteriores si existen
      await _stopAllStreams();

      // Iniciar stream de trading pair
      _tradingPairSubscription = _getTradingPairStreamUseCase
          .execute(event.symbol)
          .listen(
            (tradingPair) {
              add(
                _TradingPairDataUpdated(
                  data: tradingPair,
                  type: TradingPairDataType.tradingPair,
                ),
              );
            },
            onError: (error) {
              debugPrint('❌ Error en trading pair stream: $error');
              _handleStreamError(error);
            },
          );

      // Iniciar stream de price stats
      _priceStatsSubscription = _getPriceStatsStreamUseCase
          .execute(event.symbol)
          .listen(
            (priceStats) {
              add(_PriceStatsUpdated(priceStats: priceStats));
            },
            onError: (error) {
              debugPrint('❌ Error en price stats stream: $error');
              _handleStreamError(error);
            },
          );

      // Iniciar stream de klines
      _klineSubscription = _getKlineStreamUseCase
          .execute(symbol: event.symbol, interval: _currentInterval)
          .listen(
            (klines) {
              add(_KlinesUpdated(klines: klines));
            },
            onError: (error) {
              debugPrint('❌ Error en klines stream: $error');
              _handleStreamError(error);
            },
          );

      // Iniciar stream de trades recientes
      _tradesSubscription = _getRecentTradesStreamUseCase
          .execute(event.symbol)
          .listen(
            (trades) {
              add(_RecentTradesUpdated(trades: trades));
            },
            onError: (error) {
              debugPrint('❌ Error en trades stream: $error');
              _handleStreamError(error);
            },
          );

      // Actualizar estado para indicar que los streams están activos
      final currentState = state as TradingPairLoaded;
      emit(
        currentState.copyWith(isStreaming: true, lastUpdated: DateTime.now()),
      );

      debugPrint('✅ Streams iniciados para ${event.symbol}');
    } catch (e) {
      debugPrint('❌ Error iniciando streams: $e');
      emit(
        TradingPairError(
          message: 'Error iniciando streams: $e',
          symbol: event.symbol,
          type: TradingPairErrorType.streamError,
        ),
      );
    }
  }

  /// Maneja la detención de streams
  Future<void> _onStopTradingPairStreams(
    StopTradingPairStreams event,
    Emitter<TradingPairState> emit,
  ) async {
    debugPrint('🛑 Deteniendo streams');

    await _stopAllStreams();
    _reconnectTimer?.cancel();
    _reconnectAttempts = 0;

    if (state is TradingPairLoaded) {
      final currentState = state as TradingPairLoaded;
      emit(
        currentState.copyWith(isStreaming: false, lastUpdated: DateTime.now()),
      );
    }

    debugPrint('✅ Streams detenidos');
  }

  /// Maneja el cambio de intervalo de klines
  Future<void> _onChangeKlineInterval(
    ChangeKlineInterval event,
    Emitter<TradingPairState> emit,
  ) async {
    if (state is! TradingPairLoaded) return;

    _currentInterval = event.interval;

    debugPrint('🔄 Cambiando intervalo de klines a ${event.interval}');

    // Detener stream de klines actual
    await _klineSubscription?.cancel();

    if (_currentSymbol != null) {
      // Iniciar nuevo stream con el nuevo intervalo
      _klineSubscription = _getKlineStreamUseCase
          .execute(symbol: _currentSymbol!, interval: _currentInterval)
          .listen(
            (klines) {
              add(_KlinesUpdated(klines: klines));
            },
            onError: (error) {
              debugPrint('❌ Error en klines stream: $error');
              _handleStreamError(error);
            },
          );

      // Actualizar estado
      final currentState = state as TradingPairLoaded;
      emit(
        currentState.copyWith(
          currentInterval: _currentInterval,
          lastUpdated: DateTime.now(),
        ),
      );
    }
  }

  /// Maneja el refresco de datos
  Future<void> _onRefreshTradingPairData(
    RefreshTradingPairData event,
    Emitter<TradingPairState> emit,
  ) async {
    if (state is TradingPairLoaded) {
      // Recargar datos sin detener streams
      add(LoadTradingPairData(symbol: event.symbol));
    }
  }

  /// Maneja errores generales
  Future<void> _onTradingPairErrorOccurred(
    TradingPairErrorOccurred event,
    Emitter<TradingPairState> emit,
  ) async {
    emit(
      TradingPairError(
        message: event.error,
        symbol: _currentSymbol,
        type: TradingPairErrorType.unknown,
      ),
    );
  }

  /// Maneja actualizaciones de datos del trading pair
  void _onTradingPairDataUpdated(
    _TradingPairDataUpdated event,
    Emitter<TradingPairState> emit,
  ) {
    if (state is TradingPairLoaded) {
      final currentState = state as TradingPairLoaded;
      emit(
        currentState.copyWith(
          tradingPair: event.data as TradingPairEntity,
          lastUpdated: DateTime.now(),
        ),
      );
    }
  }

  /// Maneja actualizaciones de estadísticas de precio
  void _onPriceStatsUpdated(
    _PriceStatsUpdated event,
    Emitter<TradingPairState> emit,
  ) {
    if (state is TradingPairLoaded) {
      final currentState = state as TradingPairLoaded;
      emit(
        currentState.copyWith(
          priceStats: event.priceStats as PriceStatsEntity,
          lastUpdated: DateTime.now(),
        ),
      );
    }
  }

  /// Maneja actualizaciones de klines
  void _onKlinesUpdated(_KlinesUpdated event, Emitter<TradingPairState> emit) {
    if (state is TradingPairLoaded) {
      final currentState = state as TradingPairLoaded;
      emit(
        currentState.copyWith(
          klines: event.klines.cast<KlineEntity>(),
          lastUpdated: DateTime.now(),
        ),
      );
    }
  }

  /// Maneja actualizaciones de trades recientes
  void _onRecentTradesUpdated(
    _RecentTradesUpdated event,
    Emitter<TradingPairState> emit,
  ) {
    if (state is TradingPairLoaded) {
      final currentState = state as TradingPairLoaded;
      emit(
        currentState.copyWith(
          recentTrades: event.trades.cast<TradeEntity>(),
          lastUpdated: DateTime.now(),
        ),
      );
    }
  }

  /// Maneja errores de streams con reconexión automática
  void _handleStreamError(dynamic error) {
    if (_reconnectAttempts < _maxReconnectAttempts && _currentSymbol != null) {
      _reconnectAttempts++;

      add(
        const TradingPairErrorOccurred(error: 'Stream error, reconnecting...'),
      );

      _reconnectTimer = Timer(
        Duration(seconds: _reconnectAttempts * 2), // Backoff exponencial
        () {
          if (_currentSymbol != null) {
            add(StartTradingPairStreams(symbol: _currentSymbol!));
          }
        },
      );
    } else {
      add(TradingPairErrorOccurred(error: 'Stream error: $error'));
    }
  }

  /// Detiene todos los streams activos
  Future<void> _stopAllStreams() async {
    await _tradingPairSubscription?.cancel();
    await _priceStatsSubscription?.cancel();
    await _klineSubscription?.cancel();
    await _tradesSubscription?.cancel();

    _tradingPairSubscription = null;
    _priceStatsSubscription = null;
    _klineSubscription = null;
    _tradesSubscription = null;
  }

  @override
  Future<void> close() async {
    await _stopAllStreams();
    _reconnectTimer?.cancel();
    await _repository.dispose();
    return super.close();
  }

  /// Obtiene estadísticas del BLoC para debugging
  Map<String, dynamic> getDebugInfo() {
    return {
      'currentSymbol': _currentSymbol,
      'currentInterval': _currentInterval,
      'reconnectAttempts': _reconnectAttempts,
      'isStreaming': state is TradingPairLoaded
          ? (state as TradingPairLoaded).isStreaming
          : false,
      'activeStreams': {
        'tradingPair': _tradingPairSubscription != null,
        'priceStats': _priceStatsSubscription != null,
        'klines': _klineSubscription != null,
        'trades': _tradesSubscription != null,
      },
      'state': state.runtimeType.toString(),
    };
  }
}
