part of 'navigation_bloc.dart';

class NavigationState extends Equatable {
  const NavigationState({
    this.currentRoute = '/',
    this.currentIndex = 0,
    this.isSidebarExpanded = true,
    this.previousRoute,
  });

  final String currentRoute;
  final int currentIndex;
  final bool isSidebarExpanded;
  final String? previousRoute;

  NavigationState copyWith({
    String? currentRoute,
    int? currentIndex,
    bool? isSidebarExpanded,
    String? previousRoute,
  }) {
    return NavigationState(
      currentRoute: currentRoute ?? this.currentRoute,
      currentIndex: currentIndex ?? this.currentIndex,
      isSidebarExpanded: isSidebarExpanded ?? this.isSidebarExpanded,
      previousRoute: previousRoute ?? this.previousRoute,
    );
  }

  @override
  List<Object?> get props => [
    currentRoute,
    currentIndex,
    isSidebarExpanded,
    previousRoute,
  ];
}
