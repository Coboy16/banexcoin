part of 'trading_pair_bloc.dart';

sealed class TradingPairEvent extends Equatable {
  const TradingPairEvent();

  @override
  List<Object> get props => [];
}

/// Evento para cargar datos iniciales del par de trading
class LoadTradingPairData extends TradingPairEvent {
  final String symbol;

  const LoadTradingPairData({required this.symbol});

  @override
  List<Object> get props => [symbol];
}

/// Evento para iniciar streams en tiempo real
class StartTradingPairStreams extends TradingPairEvent {
  final String symbol;

  const StartTradingPairStreams({required this.symbol});

  @override
  List<Object> get props => [symbol];
}

/// Evento para detener streams en tiempo real
class StopTradingPairStreams extends TradingPairEvent {
  const StopTradingPairStreams();
}

/// Evento para cambiar el intervalo de klines
class ChangeKlineInterval extends TradingPairEvent {
  final String interval;

  const ChangeKlineInterval({required this.interval});

  @override
  List<Object> get props => [interval];
}

/// Evento para refrescar datos
class RefreshTradingPairData extends TradingPairEvent {
  final String symbol;

  const RefreshTradingPairData({required this.symbol});

  @override
  List<Object> get props => [symbol];
}

/// Evento para manejar errores
class TradingPairErrorOccurred extends TradingPairEvent {
  final String error;

  const TradingPairErrorOccurred({required this.error});

  @override
  List<Object> get props => [error];
}

/// Evento interno para actualizar datos del par de trading
class _TradingPairDataUpdated extends TradingPairEvent {
  final dynamic data;
  final TradingPairDataType type;

  const _TradingPairDataUpdated({required this.data, required this.type});

  @override
  List<Object> get props => [data, type];
}

/// Evento interno para actualizar estadísticas de precio
class _PriceStatsUpdated extends TradingPairEvent {
  final dynamic priceStats;

  const _PriceStatsUpdated({required this.priceStats});

  @override
  List<Object> get props => [priceStats];
}

/// Evento interno para actualizar klines
class _KlinesUpdated extends TradingPairEvent {
  final List<dynamic> klines;

  const _KlinesUpdated({required this.klines});

  @override
  List<Object> get props => [klines];
}

/// Evento interno para actualizar trades recientes
class _RecentTradesUpdated extends TradingPairEvent {
  final List<dynamic> trades;

  const _RecentTradesUpdated({required this.trades});

  @override
  List<Object> get props => [trades];
}
