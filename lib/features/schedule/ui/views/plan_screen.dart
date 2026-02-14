// Navigation extensions moved to core/utils/extensions.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/repos/study_preferences_repository.dart';
import '../logic/lessons_cubit.dart';
import '../logic/main_plan_cubit.dart';
import '../logic/plan_cubit.dart';
import '../logic/study_preferences_cubit.dart';
import 'lessons_view.dart';
import 'my_plan_view.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlanScreenView();
  }
}

class PlanScreenView extends StatefulWidget {
  const PlanScreenView({super.key});

  @override
  State<PlanScreenView> createState() => _PlanScreenViewState();
}

class _PlanScreenViewState extends State<PlanScreenView> {
  @override
  void initState() {
    super.initState();
    // التأكد من إظهار الـ navigation bar عند دخول الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.setNavBarVisible(true);
      // Reset to default tab when entering the screen
      context.read<MainPlanCubit>().resetToDefault();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Plan',
        actions: [
          BlocBuilder<StudyPreferencesCubit, StudyPreferencesState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.settings),
                onPressed:
                    () => Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.studyPreferencesSetup),
              );
            },
          ),
        ],
      ),
      body: BlocListener<StudyPreferencesCubit, StudyPreferencesState>(
        listener: (context, state) {
          if (state is StudyPreferencesSetupRequired) {
            Navigator.of(context).pushNamed(AppRoutes.studyPreferencesSetup);
          } else if (state is StudyPreferencesPlanGenerated) {
            Navigator.of(context).pushNamed(AppRoutes.aiPlanPreview);
          } else if (state is StudyPreferencesPlanAccepted) {
            // إظهار الـ navigation bar بعد النجاح
            context.setNavBarVisible(true);

            // تحديث البيانات
            context.read<PlanCubit>().loadEvents();
            context.read<LessonsCubit>().loadEvents();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Study plan updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is StudyPreferencesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Column(
          children: [
            // Tab Bar
            BlocBuilder<MainPlanCubit, int>(
              builder: (context, currentTabIndex) {
                print(
                  'PlanScreen - Building tab bar with index: $currentTabIndex',
                );
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      TabBarWidget(
                        index: 0,
                        title: 'My Plan',
                        isSelected: currentTabIndex == 0,
                        onTap: (index) {
                          print('PlanScreen - My Plan tab tapped');
                          context.read<MainPlanCubit>().changeTab(index);
                          // تحميل البيانات عند التبديل
                          context.read<PlanCubit>().loadEvents();
                        },
                        radius: 16,
                      ),
                      const SizedBox(width: 16),
                      TabBarWidget(
                        index: 1,
                        title: 'Lessons',
                        isSelected: currentTabIndex == 1,
                        onTap: (index) {
                          print('PlanScreen - Lessons tab tapped');
                          context.read<MainPlanCubit>().changeTab(index);
                          // تحميل البيانات عند التبديل
                          context.read<LessonsCubit>().loadEvents();
                        },
                        radius: 16,
                      ),
                    ],
                  ),
                );
              },
            ),

            // Content
            Expanded(
              child: BlocBuilder<MainPlanCubit, int>(
                builder: (context, currentTabIndex) {
                  print(
                    'PlanScreen - Building content with index: $currentTabIndex',
                  );
                  return IndexedStack(
                    index: currentTabIndex,
                    children: const [MyPlanView(), LessonsView()],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRegeneratePlanDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Generate New Plan'),
            content: const Text(
              'This will create a new study plan based on your current preferences. Your existing plan will be replaced.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Generate'),
              ),
            ],
          ),
    );

    if (result == true && context.mounted) {
      final cubit = context.read<StudyPreferencesCubit>();
      final currentPreferences =
          await sl<StudyPreferencesRepository>().getCurrentPreferences();

      if (currentPreferences != null) {
        cubit.savePreferencesAndGeneratePlan(currentPreferences);
      }
    }
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Reset Preferences'),
            content: const Text(
              'This will delete all your study preferences and generated lessons. You will need to set up your preferences again.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.read<StudyPreferencesCubit>().resetPreferences();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Reset',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}
