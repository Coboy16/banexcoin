import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/theme/theme.dart';
import '/core/bloc/blocs.dart';
import 'sidebar_widget.dart';
import 'top_bar_widget.dart';

class DesktopLayout extends StatelessWidget {
  const DesktopLayout({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.currentRoute,
    required this.isSidebarExpanded,
  });

  final Widget child;
  final int currentIndex;
  final String currentRoute;
  final bool isSidebarExpanded;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final isDark = state.isDarkMode;
        return Scaffold(
          backgroundColor: AppColors.getPrimaryBackground(isDark),
          body: Row(
            children: [
              // Sidebar
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isSidebarExpanded ? 280 : 80,
                child: SidebarWidget(
                  isExpanded: isSidebarExpanded,
                  currentIndex: currentIndex,
                  currentRoute: currentRoute,
                ),
              ),

              // Main content
              Expanded(
                child: Column(
                  children: [
                    // Top bar
                    TopBarWidget(
                      onMenuPressed: () {
                        context.read<NavigationBloc>().add(
                          const ToggleSidebarEvent(),
                        );
                      },
                      onThemeToggle: () {
                        context.read<ThemeBloc>().add(const ToggleThemeEvent());
                      },
                    ),

                    // Body
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: child,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
