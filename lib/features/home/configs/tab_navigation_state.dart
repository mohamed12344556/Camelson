import 'package:flutter/material.dart';

/// Model to represent the navigation state of a single tab
class TabNavigationState {
  final List<String> routeHistory;
  final GlobalKey<NavigatorState> navigatorKey;

  const TabNavigationState({
    required this.routeHistory,
    required this.navigatorKey,
  });

  /// Create initial state for a tab
  factory TabNavigationState.initial(int tabIndex) {
    return TabNavigationState(
      routeHistory: ['/'],
      navigatorKey: GlobalKey<NavigatorState>(),
    );
  }

  /// Get current route (last in history)
  String get currentRoute => routeHistory.isEmpty ? '/' : routeHistory.last;

  /// Check if can go back
  bool get canGoBack => routeHistory.length > 1;

  /// Check if at root
  bool get isAtRoot => routeHistory.length == 1 && currentRoute == '/';

  /// Create new state when pushing a route
  TabNavigationState pushRoute(String route) {
    // Avoid duplicate consecutive routes
    if (routeHistory.isNotEmpty && routeHistory.last == route) {
      return this;
    }

    return TabNavigationState(
      routeHistory: [...routeHistory, route],
      navigatorKey: navigatorKey,
    );
  }

  /// Create new state when popping a route
  TabNavigationState popRoute() {
    if (routeHistory.length <= 1) {
      return this; // Already at root
    }

    return TabNavigationState(
      routeHistory: routeHistory.sublist(0, routeHistory.length - 1),
      navigatorKey: navigatorKey,
    );
  }

  /// Reset tab to root
  TabNavigationState resetToRoot() {
    return TabNavigationState(
      routeHistory: ['/'],
      navigatorKey: navigatorKey,
    );
  }

  @override
  String toString() {
    return 'TabNavigationState(current: $currentRoute, canGoBack: $canGoBack, history: $routeHistory)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! TabNavigationState) return false;

    if (routeHistory.length != other.routeHistory.length) return false;

    for (int i = 0; i < routeHistory.length; i++) {
      if (routeHistory[i] != other.routeHistory[i]) return false;
    }

    return true;
  }

  @override
  int get hashCode {
    return Object.hashAll(routeHistory);
  }
}
