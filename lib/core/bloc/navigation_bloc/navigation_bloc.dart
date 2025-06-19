import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '/core/router/app_router.dart';

part 'navigation_event.dart';
part 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState()) {
    on<NavigateToPageEvent>(_onNavigateToPage);
    on<ToggleSidebarEvent>(_onToggleSidebar);
    on<SetSidebarExpandedEvent>(_onSetSidebarExpanded);
  }

  void _onNavigateToPage(
    NavigateToPageEvent event,
    Emitter<NavigationState> emit,
  ) {
    emit(
      state.copyWith(
        previousRoute: state.currentRoute,
        currentRoute: event.route,
        currentIndex: event.index,
      ),
    );
  }

  void _onToggleSidebar(
    ToggleSidebarEvent event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(isSidebarExpanded: !state.isSidebarExpanded));
  }

  void _onSetSidebarExpanded(
    SetSidebarExpandedEvent event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(isSidebarExpanded: event.isExpanded));
  }

  // Helper methods for navigation
  void navigateToDashboard() {
    add(const NavigateToPageEvent(route: AppRouter.dashboard, index: 0));
  }

  void navigateToTradingPairs() {
    add(const NavigateToPageEvent(route: AppRouter.tradingPairs, index: 1));
  }

  void navigateToOrderBook() {
    add(const NavigateToPageEvent(route: AppRouter.orderBook, index: 2));
  }

  void navigateToCalculator() {
    add(const NavigateToPageEvent(route: AppRouter.calculator, index: 3));
  }

  // void navigateToPortfolio() {
  //   add(const NavigateToPageEvent(route: AppRouter.portfolio, index: 4));
  // }

  // void navigateToSettings() {
  //   add(const NavigateToPageEvent(route: AppRouter.settings, index: 5));
  // }
}
