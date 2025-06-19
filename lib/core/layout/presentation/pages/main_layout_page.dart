import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '/core/layout/presentation/widgets/widgets.dart';
import '/core/bloc/blocs.dart';

class MainLayoutPage extends StatelessWidget {
  const MainLayoutPage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, navigationState) {
        return BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            final isMobile = ResponsiveBreakpoints.of(context).isMobile;
            final isTablet = ResponsiveBreakpoints.of(context).isTablet;

            if (isMobile || isTablet) {
              return MobileLayout(
                currentIndex: navigationState.currentIndex,
                currentRoute: navigationState.currentRoute,
                child: child,
              );
            }

            return DesktopLayout(
              currentIndex: navigationState.currentIndex,
              currentRoute: navigationState.currentRoute,
              isSidebarExpanded: navigationState.isSidebarExpanded,
              child: child,
            );
          },
        );
      },
    );
  }
}
