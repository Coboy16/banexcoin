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
