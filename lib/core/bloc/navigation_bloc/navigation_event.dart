part of 'navigation_bloc.dart';

sealed class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object> get props => [];
}

class NavigateToPageEvent extends NavigationEvent {
  const NavigateToPageEvent({required this.route, required this.index});

  final String route;
  final int index;

  @override
  List<Object> get props => [route, index];
}

class ToggleSidebarEvent extends NavigationEvent {
  const ToggleSidebarEvent();
}

class SetSidebarExpandedEvent extends NavigationEvent {
  const SetSidebarExpandedEvent(this.isExpanded);

  final bool isExpanded;

  @override
  List<Object> get props => [isExpanded];
}
