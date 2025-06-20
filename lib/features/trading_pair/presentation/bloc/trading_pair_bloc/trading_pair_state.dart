part of 'trading_pair_bloc.dart';

sealed class TradingPairState extends Equatable {
  const TradingPairState();

  @override
  List<Object> get props => [];
}

final class TradingPairInitial extends TradingPairState {}

/// Estado de carga de datos iniciales
class TradingPairLoading extends TradingPairState {
  final String symbol;
  final double? progress;

  const TradingPairLoading({required this.symbol, this.progress});

  @override
  List<Object> get props => [symbol, progress ?? 0];
}

/// Estado con datos cargados y streams activos
class TradingPairLoaded extends TradingPairState {
  final TradingPairEntity tradingPair;
  final PriceStatsEntity priceStats;
  final List<KlineEntity> klines;
  final List<TradeEntity> recentTrades;
  final SymbolInfoTraiding symbolInfo;
  final String currentInterval;
  final bool isStreaming;
  final DateTime lastUpdated;

  const TradingPairLoaded({
    required this.tradingPair,
    required this.priceStats,
    required this.klines,
    required this.recentTrades,
    required this.symbolInfo,
    required this.currentInterval,
    required this.isStreaming,
    required this.lastUpdated,
  });

  /// Crea una copia del estado con algunos valores actualizados
  TradingPairLoaded copyWith({
    TradingPairEntity? tradingPair,
    PriceStatsEntity? priceStats,
    List<KlineEntity>? klines,
    List<TradeEntity>? recentTrades,
    SymbolInfoTraiding? symbolInfo,
    String? currentInterval,
    bool? isStreaming,
    DateTime? lastUpdated,
  }) {
    return TradingPairLoaded(
      tradingPair: tradingPair ?? this.tradingPair,
      priceStats: priceStats ?? this.priceStats,
      klines: klines ?? this.klines,
      recentTrades: recentTrades ?? this.recentTrades,
      symbolInfo: symbolInfo ?? this.symbolInfo,
      currentInterval: currentInterval ?? this.currentInterval,
      isStreaming: isStreaming ?? this.isStreaming,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Obtiene el precio actual del par
  double get currentPrice => tradingPair.currentPrice;

  /// Obtiene el cambio de precio en 24h
  double get priceChange24h => tradingPair.priceChange24h;

  /// Obtiene el cambio porcentual en 24h
  double get priceChangePercent24h => tradingPair.priceChangePercent24h;

  /// Determina si el cambio es positivo
  bool get isPriceChangePositive => tradingPair.isPriceChangePositive;

  /// Obtiene la tendencia general
  PriceTrend get overallTrend => priceStats.trend;

  /// Verifica si los datos están actualizados
  bool get isDataFresh {
    const freshnessDuration = Duration(minutes: 5);
    return DateTime.now().difference(lastUpdated) < freshnessDuration;
  }

  /// Obtiene las últimas klines ordenadas
  List<KlineEntity> get sortedKlines {
    final sorted = List<KlineEntity>.from(klines);
    sorted.sort((a, b) => a.openTime.compareTo(b.openTime));
    return sorted;
  }

  /// Obtiene los trades más recientes ordenados
  List<TradeEntity> get sortedRecentTrades {
    final sorted = List<TradeEntity>.from(recentTrades);
    sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted;
  }

  @override
  List<Object> get props => [
    tradingPair,
    priceStats,
    klines,
    recentTrades,
    symbolInfo,
    currentInterval,
    isStreaming,
    lastUpdated,
  ];
}

/// Estado de error
class TradingPairError extends TradingPairState {
  final String message;
  final String? symbol;
  final TradingPairErrorType type;

  const TradingPairError({
    required this.message,
    this.symbol,
    required this.type,
  });

  @override
  List<Object> get props => [message, symbol ?? '', type];
}

/// Estado de reconexión
class TradingPairReconnecting extends TradingPairState {
  final String symbol;
  final int attempt;
  final int maxAttempts;

  const TradingPairReconnecting({
    required this.symbol,
    required this.attempt,
    required this.maxAttempts,
  });

  @override
  List<Object> get props => [symbol, attempt, maxAttempts];
}

/// Tipos de errores
enum TradingPairErrorType {
  networkError,
  symbolNotFound,
  dataLoadError,
  streamError,
  validationError,
  unknown,
}
