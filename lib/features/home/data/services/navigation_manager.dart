import 'package:flutter/material.dart';
import '../../configs/tab_navigation_state.dart';

/// Central navigation manager for tab-based navigation
/// Singleton pattern to ensure single instance across the app
class NavigationManager extends ChangeNotifier {
  static final NavigationManager _instance = NavigationManager._internal();
  factory NavigationManager() => _instance;
  NavigationManager._internal();

  // Navigation state for each tab
  final Map<int, TabNavigationState> _tabsState = {};

  // Current selected tab
  int _currentTabIndex = 0;

  // Navigation bar visibility
  bool _isNavBarVisible = true;

  // Bottom sheet state
  bool _isBottomSheetOpen = false;

  // Getters
  int get currentTabIndex => _currentTabIndex;
  bool get isNavBarVisible => _isNavBarVisible && !_isBottomSheetOpen;
  bool get isBottomSheetOpen => _isBottomSheetOpen;

  /// Initialize navigation manager with number of tabs
  void initialize(int tabCount) {
    if (_tabsState.isEmpty) {
      for (int i = 0; i < tabCount; i++) {
        _tabsState[i] = TabNavigationState.initial(i);
      }
    }
    _currentTabIndex = 0;
    _isNavBarVisible = true;
    _isBottomSheetOpen = false;
    notifyListeners();
  }

  /// Get navigator key for specific tab
  GlobalKey<NavigatorState> getNavigatorKey(int tabIndex) {
    return _tabsState[tabIndex]?.navigatorKey ?? GlobalKey<NavigatorState>();
  }

  /// Get current tab state
  TabNavigationState? getTabState(int tabIndex) {
    return _tabsState[tabIndex];
  }

  /// Get current route for specific tab
  String getCurrentRoute(int tabIndex) {
    return _tabsState[tabIndex]?.currentRoute ?? '/';
  }

  /// Check if tab can go back
  bool canGoBack(int tabIndex) {
    return _tabsState[tabIndex]?.canGoBack ?? false;
  }

  /// Switch to specific tab
  void switchToTab(int tabIndex) {
    if (tabIndex < 0 || tabIndex >= _tabsState.length) return;

    if (_currentTabIndex == tabIndex) {
      // Same tab tapped - reset to root if not already there
      if (!_tabsState[tabIndex]!.isAtRoot) {
        resetTabToRoot(tabIndex);
      }
    } else {
      // Different tab - just switch without resetting
      _currentTabIndex = tabIndex;
      _updateNavBarVisibility();
      notifyListeners();
    }
  }

  /// Navigate to specific route in specific tab
  void navigateToRoute(int tabIndex, String route, {Object? arguments}) {
    if (tabIndex < 0 || tabIndex >= _tabsState.length) {
      debugPrint('❌ NavigationManager: Invalid tab index $tabIndex');
      return;
    }

    final currentState = _tabsState[tabIndex]!;
    final navigatorKey = currentState.navigatorKey;

    debugPrint('🔄 NavigationManager: Navigating to $route in tab $tabIndex');
    debugPrint('📦 Arguments: $arguments');
    debugPrint('🔑 Navigator key current state: ${navigatorKey.currentState}');

    // Navigate using navigator - the observer will update the state
    final result = navigatorKey.currentState?.pushNamed(route, arguments: arguments);
    debugPrint('✅ Navigation result: $result');
  }

  /// Navigate in current tab
  void navigateInCurrentTab(String route, {Object? arguments}) {
    navigateToRoute(_currentTabIndex, route, arguments: arguments);
  }

  /// Navigate to specific route in home tab (tab 0)
  void navigateInHomeTab(String route, {Object? arguments}) {
    navigateToRoute(0, route, arguments: arguments);
  }

  /// Go back in specific tab
  void goBackInTab(int tabIndex) {
    if (tabIndex < 0 || tabIndex >= _tabsState.length) return;

    final currentState = _tabsState[tabIndex]!;

    if (currentState.canGoBack) {
      // Pop the route - the observer will update the state
      currentState.navigatorKey.currentState?.pop();
    }
  }

  /// Handle system back press
  Future<bool> handleBackPress() async {
    final currentState = _tabsState[_currentTabIndex]!;

    // If current tab can go back, go back
    if (currentState.canGoBack) {
      goBackInTab(_currentTabIndex);
      return false; // Don't exit app
    }

    // If not in home tab, go to home tab
    if (_currentTabIndex != 0) {
      switchToTab(0);
      return false; // Don't exit app
    }

    // If in home tab and at root, request exit
    return true; // Exit app (will show confirmation dialog in UI)
  }

  /// Update route in tab (called by NavigationObserver)
  void onRoutePushed(int tabIndex, String? routeName) {
    if (tabIndex < 0 || tabIndex >= _tabsState.length) return;
    if (routeName == null || routeName == '/') return;

    // Schedule update after current frame to avoid calling during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (tabIndex < 0 || tabIndex >= _tabsState.length) return;

      final currentState = _tabsState[tabIndex]!;
      _tabsState[tabIndex] = currentState.pushRoute(routeName);
      _updateNavBarVisibility();
      notifyListeners();
    });
  }

  /// Update route when popped (called by NavigationObserver)
  void onRoutePopped(int tabIndex) {
    if (tabIndex < 0 || tabIndex >= _tabsState.length) return;

    // Schedule update after current frame to avoid calling during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (tabIndex < 0 || tabIndex >= _tabsState.length) return;

      final currentState = _tabsState[tabIndex]!;
      _tabsState[tabIndex] = currentState.popRoute();
      _updateNavBarVisibility();
      notifyListeners();
    });
  }

  /// Reset specific tab to root
  void resetTabToRoot(int tabIndex) {
    if (tabIndex < 0 || tabIndex >= _tabsState.length) return;

    final currentState = _tabsState[tabIndex]!;
    currentState.navigatorKey.currentState?.popUntil((route) => route.isFirst);

    _tabsState[tabIndex] = currentState.resetToRoot();

    _updateNavBarVisibility();
    notifyListeners();
  }

  /// Reset all tabs to root
  void resetAllTabs() {
    for (int i = 0; i < _tabsState.length; i++) {
      resetTabToRoot(i);
    }
  }

  /// Update navigation bar visibility based on current route
  void _updateNavBarVisibility() {
    final currentRoute = getCurrentRoute(_currentTabIndex);

    // Nav bar is visible only for root routes
    _isNavBarVisible = currentRoute == '/';
  }

  /// Manually set navigation bar visibility
  void setNavBarVisibility(bool visible) {
    if (_isNavBarVisible != visible) {
      _isNavBarVisible = visible;
      notifyListeners();
    }
  }

  /// Set bottom sheet state
  void setBottomSheetState(bool isOpen) {
    if (_isBottomSheetOpen != isOpen) {
      _isBottomSheetOpen = isOpen;
      notifyListeners();
    }
  }

  /// Debug method to print current state
  void debugPrintState() {
    debugPrint('=== Navigation Manager State ===');
    debugPrint('Current Tab: $_currentTabIndex');
    debugPrint('Nav Bar Visible: $_isNavBarVisible');
    debugPrint('Bottom Sheet Open: $_isBottomSheetOpen');

    for (int i = 0; i < _tabsState.length; i++) {
      debugPrint('Tab $i: ${_tabsState[i]}');
    }
    debugPrint('================================');
  }

  /// Clean up resources
  @override
  void dispose() {
    _tabsState.clear();
    super.dispose();
  }
}
