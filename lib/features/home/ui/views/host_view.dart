import 'package:camelson/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../configs/tab_configs.dart';
import '../../data/models/tab_config.dart';
import '../widgets/bottom_navigation_bar.dart';

class HostView extends StatefulWidget {
  final int initialPage;

  const HostView({super.key, this.initialPage = 0});

  @override
  State<HostView> createState() => _HostViewState();
}

class _HostViewState extends State<HostView> {
  late final List<TabConfig> _tabConfigs;
  late final NavBarController _navBarController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabConfigs = TabConfigs.getTabConfigs();
    _currentTabIndex = widget.initialPage;
    _navBarController = NavBarController();
  }

  @override
  void dispose() {
    _navBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _navBarController,
      builder: (context, _) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (!didPop) {
              await _handleBackPress();
            }
          },
          child: Scaffold(
            body: NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                // تحقق إن الـ scroll راسي فقط (vertical)
                final isVertical = notification.metrics.axis == Axis.vertical;

                if (isVertical) {
                  if (notification.direction == ScrollDirection.reverse) {
                    _navBarController.hide();
                  } else if (notification.direction ==
                      ScrollDirection.forward) {
                    _navBarController.show();
                  }
                }

                return false;
              },
              child: Stack(
                children: [
                  _tabConfigs[_currentTabIndex].view,
                  _buildAnimatedNavBar(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedNavBar() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      bottom: _navBarController.isVisible ? 16 : -100,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _navBarController.isVisible ? 1.0 : 0.0,
        child: CustomBottomNavigationBar(
          tabConfigs: _tabConfigs,
          selectedIndex: _currentTabIndex,
          onTabTapped: (index) {
            setState(() {
              _currentTabIndex = index;
            });
            _navBarController.show();
          },
        ),
      ),
    );
  }

  Future<void> _handleBackPress() async {
    if (_currentTabIndex != 0) {
      setState(() {
        _currentTabIndex = 0;
      });
      _navBarController.show();
      return;
    }

    final confirmed = await context.showExitConfirmationDialog();

    if (confirmed == true && mounted) {
      SystemNavigator.pop();
    }
  }
}

// في ملف منفصل: nav_bar_controller.dart
class NavBarController extends ChangeNotifier {
  bool _isVisible = true;

  bool get isVisible => _isVisible;

  void show() {
    if (!_isVisible) {
      _isVisible = true;
      notifyListeners();
    }
  }

  void hide() {
    if (_isVisible) {
      _isVisible = false;
      notifyListeners();
    }
  }

  void toggle() {
    _isVisible = !_isVisible;
    notifyListeners();
  }
}
