import 'package:flutter/material.dart';

import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import '/core/injections/dashboard_di.dart' as di;
import '/core/injections/trading_pair_di.dart' as tp_di;
import '/core/router/app_router.dart';
import '/core/bloc/blocs.dart';
import '/core/core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await di.initializeDependenciesWithEnvironment(di.Environment.development);
  di.validateDependencies();

  await tp_di.initializeTradingPairDependenciesWithEnvironment(
    tp_di.TradingPairEnvironment.development,
  );
  tp_di.validateTradingPairDependencies();

  runApp(
    MultiBlocProvider(providers: getListBloc(), child: const BanexCoinApp()),
  );
}

class BanexCoinApp extends StatelessWidget {
  const BanexCoinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp.router(
          title: 'BanexCoin',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          routerConfig: AppRouter.createRouter(),
          builder: (context, child) {
            return ResponsiveBreakpoints.builder(
              child: child!,
              breakpoints: [
                const Breakpoint(start: 0, end: 450, name: MOBILE),
                const Breakpoint(start: 451, end: 800, name: TABLET),
                const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
              ],
            );
          },
        );
      },
    );
  }
}
