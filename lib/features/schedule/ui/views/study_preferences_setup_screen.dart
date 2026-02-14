// Navigation extensions moved to core/utils/extensions.dart
import 'package:camelson/features/schedule/ui/widgets/study_preferences_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../../data/repos/event_repository.dart';
import '../../data/repos/study_preferences_repository.dart';
import '../logic/study_preferences_cubit.dart';
import 'ai_plan_preview.dart';

class StudyPreferencesSetupScreen extends StatefulWidget {
  const StudyPreferencesSetupScreen({super.key});

  @override
  State<StudyPreferencesSetupScreen> createState() =>
      _StudyPreferencesSetupScreenState();
}

class _StudyPreferencesSetupScreenState
    extends State<StudyPreferencesSetupScreen> {
  @override
  void initState() {
    super.initState();
    // التأكد من إخفاء الـ navigation bar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.setNavBarVisible(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    // إنشاء Cubit جديد لهذه الصفحة بدلاً من محاولة الوصول للموجود
    return BlocProvider(
      create: (context) => StudyPreferencesCubit(
        studyPreferencesRepository: sl<StudyPreferencesRepository>(),
        eventRepository: sl<EventRepository>(),
      )..checkSetupStatus(),
      child: const StudyPreferencesSetupView(),
    );
  }
}

class StudyPreferencesSetupView extends StatefulWidget {
  const StudyPreferencesSetupView({super.key});

  @override
  State<StudyPreferencesSetupView> createState() =>
      _StudyPreferencesSetupViewState();
}

class _StudyPreferencesSetupViewState extends State<StudyPreferencesSetupView> {
  @override
  void initState() {
    super.initState();
    // التأكد من إخفاء الـ navigation bar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.setNavBarVisible(false);
    });
  }

  @override
  void dispose() {
    // إظهار الـ navigation bar عند الخروج من الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.setNavBarVisible(true);
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StudyPreferencesCubit, StudyPreferencesState>(
      listener: (context, state) {
        if (state is StudyPreferencesPlanGenerated) {
          // Get the cubit instance before navigation
          final cubit = context.read<StudyPreferencesCubit>();

          // الانتقال إلى AI Plan Preview مع نقل الـ Cubit
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: cubit,
                child: AIPlanPreviewView(
                  preferences: state.preferences,
                  onAcceptPlan: (generatedEvents) {
                    cubit.acceptGeneratedPlan(generatedEvents);
                  },
                ),
              ),
            ),
          );
        } else if (state is StudyPreferencesPlanAccepted) {
          // إظهار الـ navigation bar قبل العودة
          context.setNavBarVisible(true);

          // العودة إلى Plan والإشارة للنجاح
          Navigator.of(context).popUntil((route) => route.isFirst);

          // عرض رسالة نجاح
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Study plan created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          });
        } else if (state is StudyPreferencesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is StudyPreferencesLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading your preferences...'),
                ],
              ),
            ),
          );
        }

        if (state is StudyPreferencesSetupRequired) {
          return Scaffold(
            body: StudyPreferencesForm(
              onSubmit: (preferences) {
                final cubit = context.read<StudyPreferencesCubit>();
                cubit.savePreferencesAndGeneratePlan(preferences);
              },
            ),
          );
        }

        if (state is StudyPreferencesGeneratingPlan) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2F98D7), Color(0xFF166EA2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(60),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2F98D7).withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.psychology,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Generating Your Personalized Study Plan...',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F98D7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'AI is analyzing your preferences and creating a customized study schedule',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF2F98D7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is StudyPreferencesLoaded) {
          // المستخدم لديه تفضيلات مسبقاً
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF2F98D7)),
                onPressed: () {
                  // إظهار الـ navigation bar قبل العودة
                  context.setNavBarVisible(true);
                  Navigator.pop(context);
                },
              ),
              title: const Text(
                'Study Preferences',
                style: TextStyle(
                  color: Color(0xFF2F98D7),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2F98D7), Color(0xFF166EA2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2F98D7).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Preferences Already Set',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You have already configured your study preferences',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildOptionCard(
                    context: context,
                    icon: Icons.edit,
                    title: 'Edit Preferences',
                    subtitle: 'Modify your current study preferences',
                    onTap: () {
                      final cubit = context.read<StudyPreferencesCubit>();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BlocProvider.value(
                            value: cubit,
                            child: Scaffold(
                              body: StudyPreferencesForm(
                                initialPreferences: state.preferences,
                                onSubmit: (preferences) {
                                  cubit.updatePreferences(preferences);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildOptionCard(
                    context: context,
                    icon: Icons.refresh,
                    title: 'Generate New Plan',
                    subtitle:
                        'Create a new study plan with current preferences',
                    onTap: () {
                      final cubit = context.read<StudyPreferencesCubit>();
                      cubit.savePreferencesAndGeneratePlan(state.preferences);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildOptionCard(
                    context: context,
                    icon: Icons.restore,
                    title: 'Reset Everything',
                    subtitle: 'Start over with fresh preferences',
                    color: Colors.red,
                    onTap: () {
                      _showResetDialog(context);
                    },
                  ),
                ],
              ),
            ),
          );
        }

        // Default loading state
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    final cardColor = color ?? const Color(0xFF2F98D7);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: cardColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: cardColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: cardColor, size: 16),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset All Preferences'),
        content: const Text(
          'This will delete all your study preferences and generated lessons. You will need to set up your preferences again from scratch.',
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
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
