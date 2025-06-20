import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

// ignore: depend_on_referenced_packages
import 'package:provider/single_child_widget.dart';

import '/core/bloc/blocs.dart';

List<SingleChildWidget> getListBloc() {
  return [
    BlocProvider(
      create: (context) => ThemeBloc()..add(const InitializeThemeEvent()),
    ),
    BlocProvider(create: (context) => NavigationBloc()),
    BlocProvider<MarketDataBloc>(
      create: (context) {
        final bloc = GetIt.instance<MarketDataBloc>();

        // Inicializar con símbolos por defecto
        bloc.add(
          const InitializeMarketData(
            symbols: ['BTCUSDT', 'ETHUSDT', 'BNBUSDT', 'ADAUSDT'],
            enableRealTimeStreams: true,
            loadStatistics: true,
          ),
        );

        return bloc;
      },
    ),
  ];
}

/// Configuración de símbolos por defecto para el mercado
class DefaultMarketSymbols {
  static const List<String> popular = [
    'BTCUSDT',
    'ETHUSDT',
    'BNBUSDT',
    'ADAUSDT',
    'SOLUSDT',
    'DOTUSDT',
    'LINKUSDT',
    'MATICUSDT',
  ];

  static const List<String> major = ['BTCUSDT', 'ETHUSDT', 'BNBUSDT'];

  static const List<String> altcoins = [
    'ADAUSDT',
    'SOLUSDT',
    'DOTUSDT',
    'LINKUSDT',
    'MATICUSDT',
    'AVAXUSDT',
    'UNIUSDT',
    'ATOMUSDT',
  ];
}

/// Extension para facilitar el acceso desde cualquier BuildContext
extension MarketDataBlocAccess on BuildContext {
  /// Obtiene el MarketDataBloc desde el contexto
  MarketDataBloc get marketDataBloc => read<MarketDataBloc>();

  /// Obtiene directamente desde GetIt (útil para casos especiales)
  MarketDataBloc get marketDataBlocFromDI => GetIt.instance<MarketDataBloc>();
}

/// Utilidades para gestión del MarketDataBloc
class MarketDataBlocUtils {
  static final GetIt _sl = GetIt.instance;

  /// Verifica si el BLoC está disponible
  static bool get isAvailable => _sl.isRegistered<MarketDataBloc>();

  /// Obtiene una nueva instancia del BLoC
  static MarketDataBloc createInstance() => _sl<MarketDataBloc>();

  /// Inicializa el BLoC con símbolos específicos
  static void initializeWithSymbols(MarketDataBloc bloc, List<String> symbols) {
    bloc.add(
      InitializeMarketData(
        symbols: symbols,
        enableRealTimeStreams: true,
        loadStatistics: true,
      ),
    );
  }

  /// Agrega símbolos adicionales a un BLoC existente
  static void addSymbolsToExistingBloc(
    MarketDataBloc bloc,
    List<String> symbols,
  ) {
    for (final symbol in symbols) {
      bloc.add(SubscribeToTicker(symbol));
      bloc.add(AddToWatchlist(symbol));
    }
  }

  /// Obtiene estadísticas de rendimiento
  static Map<String, dynamic> getPerformanceStats(MarketDataBloc bloc) {
    return bloc.getPerformanceStats();
  }

  /// Reconecta todos los streams
  static Future<void> reconnectAll(MarketDataBloc bloc) async {
    await bloc.reconnectAllStreams();
  }
}
