import 'package:camelson/core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainPlanCubit extends Cubit<int> {
  MainPlanCubit() : super(0);

  void changeTab(int index) {
    print('MainPlanCubit - changeTab called with index: $index');
    print('MainPlanCubit - Current state: $state');

    // Always emit, even if it's the same state
    safeEmit(index);

    print('MainPlanCubit - New state after emit: $state');
  }

  // Method to reset to default tab
  void resetToDefault() {
    safeEmit(0);
  }

  // Method to get current tab
  int get currentTab => state;
}
