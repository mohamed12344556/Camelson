import 'package:hive_ce/hive.dart';

part 'study_preferences_model.g.dart';

@HiveType(typeId: 3)
class StudyPreferences {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime createdAt;

  @HiveField(2)
  final bool studyAllSubjectsDaily;

  @HiveField(3)
  final List<String> preferredSubjectsOrder;

  @HiveField(4)
  final String hardestSubject;

  @HiveField(5)
  final Map<String, double> hoursPerSubject;

  @HiveField(6)
  final String favoriteSubject;

  @HiveField(7)
  final String timeConsumingSubject;

  @HiveField(8)
  final String scienceVsLiterature; // 'science', 'literature', 'both'

  @HiveField(9)
  final String studyStyle; // 'intensive', 'diverse'

  @HiveField(10)
  final String reviewFrequency; // 'daily', 'weekly'

  @HiveField(11)
  final bool usesAdditionalResources;

  @HiveField(12)
  final String highestGradeSubject;

  @HiveField(13)
  final bool hasTimeManagementDifficulty;

  @HiveField(14)
  final String needsHelpWith;

  @HiveField(15)
  final String hardToRememberSubject;

  @HiveField(16)
  final bool sameStudyMethodForAll;

  @HiveField(17)
  final String timeTakingSubject;

  @HiveField(18)
  final String preferredLearningType; // 'memorization', 'understanding', 'both'

  @HiveField(19)
  final bool reviewsBeforeNewSubject;

  @HiveField(20)
  final bool prefersWeeklyDistribution;

  @HiveField(21)
  final String examPreparationMethod;

  @HiveField(22)
  final double dailyStudyHours;

  @HiveField(23)
  final int subjectsPerDay;

  @HiveField(24)
  final String preferredTimeToStudy; // 'morning', 'evening', 'afternoon'

  @HiveField(25)
  final bool usesSummaries;

  @HiveField(26)
  final int reviewFrequencyCount;

  @HiveField(27)
  final bool usesAdditionalSources;

  @HiveField(28)
  final bool takesBreaks;

  @HiveField(29)
  final int breakDurationMinutes;

  @HiveField(30)
  final bool hasFixedSchedule;

  @HiveField(31)
  final bool feelsStressed;

  @HiveField(32)
  final String stressReason;

  @HiveField(33)
  final bool usesTimeManagementApps;

  @HiveField(34)
  final String studyEnvironment; // 'alone', 'group'

  @HiveField(35)
  final int concentrationLevel; // 1-10

  @HiveField(36)
  final bool reviewsBeforeSleep;

  @HiveField(37)
  final bool solvesExercises;

  @HiveField(38)
  final List<String> distractions;

  @HiveField(39)
  final String examPreparationStrategy;

  StudyPreferences({
    required this.id,
    required this.createdAt,
    required this.studyAllSubjectsDaily,
    required this.preferredSubjectsOrder,
    required this.hardestSubject,
    required this.hoursPerSubject,
    required this.favoriteSubject,
    required this.timeConsumingSubject,
    required this.scienceVsLiterature,
    required this.studyStyle,
    required this.reviewFrequency,
    required this.usesAdditionalResources,
    required this.highestGradeSubject,
    required this.hasTimeManagementDifficulty,
    required this.needsHelpWith,
    required this.hardToRememberSubject,
    required this.sameStudyMethodForAll,
    required this.timeTakingSubject,
    required this.preferredLearningType,
    required this.reviewsBeforeNewSubject,
    required this.prefersWeeklyDistribution,
    required this.examPreparationMethod,
    required this.dailyStudyHours,
    required this.subjectsPerDay,
    required this.preferredTimeToStudy,
    required this.usesSummaries,
    required this.reviewFrequencyCount,
    required this.usesAdditionalSources,
    required this.takesBreaks,
    required this.breakDurationMinutes,
    required this.hasFixedSchedule,
    required this.feelsStressed,
    required this.stressReason,
    required this.usesTimeManagementApps,
    required this.studyEnvironment,
    required this.concentrationLevel,
    required this.reviewsBeforeSleep,
    required this.solvesExercises,
    required this.distractions,
    required this.examPreparationStrategy,
  });

  StudyPreferences copyWith({
    String? id,
    DateTime? createdAt,
    bool? studyAllSubjectsDaily,
    List<String>? preferredSubjectsOrder,
    String? hardestSubject,
    Map<String, double>? hoursPerSubject,
    String? favoriteSubject,
    String? timeConsumingSubject,
    String? scienceVsLiterature,
    String? studyStyle,
    String? reviewFrequency,
    bool? usesAdditionalResources,
    String? highestGradeSubject,
    bool? hasTimeManagementDifficulty,
    String? needsHelpWith,
    String? hardToRememberSubject,
    bool? sameStudyMethodForAll,
    String? timeTakingSubject,
    String? preferredLearningType,
    bool? reviewsBeforeNewSubject,
    bool? prefersWeeklyDistribution,
    String? examPreparationMethod,
    double? dailyStudyHours,
    int? subjectsPerDay,
    String? preferredTimeToStudy,
    bool? usesSummaries,
    int? reviewFrequencyCount,
    bool? usesAdditionalSources,
    bool? takesBreaks,
    int? breakDurationMinutes,
    bool? hasFixedSchedule,
    bool? feelsStressed,
    String? stressReason,
    bool? usesTimeManagementApps,
    String? studyEnvironment,
    int? concentrationLevel,
    bool? reviewsBeforeSleep,
    bool? solvesExercises,
    List<String>? distractions,
    String? examPreparationStrategy,
  }) {
    return StudyPreferences(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      studyAllSubjectsDaily: studyAllSubjectsDaily ?? this.studyAllSubjectsDaily,
      preferredSubjectsOrder: preferredSubjectsOrder ?? this.preferredSubjectsOrder,
      hardestSubject: hardestSubject ?? this.hardestSubject,
      hoursPerSubject: hoursPerSubject ?? this.hoursPerSubject,
      favoriteSubject: favoriteSubject ?? this.favoriteSubject,
      timeConsumingSubject: timeConsumingSubject ?? this.timeConsumingSubject,
      scienceVsLiterature: scienceVsLiterature ?? this.scienceVsLiterature,
      studyStyle: studyStyle ?? this.studyStyle,
      reviewFrequency: reviewFrequency ?? this.reviewFrequency,
      usesAdditionalResources: usesAdditionalResources ?? this.usesAdditionalResources,
      highestGradeSubject: highestGradeSubject ?? this.highestGradeSubject,
      hasTimeManagementDifficulty: hasTimeManagementDifficulty ?? this.hasTimeManagementDifficulty,
      needsHelpWith: needsHelpWith ?? this.needsHelpWith,
      hardToRememberSubject: hardToRememberSubject ?? this.hardToRememberSubject,
      sameStudyMethodForAll: sameStudyMethodForAll ?? this.sameStudyMethodForAll,
      timeTakingSubject: timeTakingSubject ?? this.timeTakingSubject,
      preferredLearningType: preferredLearningType ?? this.preferredLearningType,
      reviewsBeforeNewSubject: reviewsBeforeNewSubject ?? this.reviewsBeforeNewSubject,
      prefersWeeklyDistribution: prefersWeeklyDistribution ?? this.prefersWeeklyDistribution,
      examPreparationMethod: examPreparationMethod ?? this.examPreparationMethod,
      dailyStudyHours: dailyStudyHours ?? this.dailyStudyHours,
      subjectsPerDay: subjectsPerDay ?? this.subjectsPerDay,
      preferredTimeToStudy: preferredTimeToStudy ?? this.preferredTimeToStudy,
      usesSummaries: usesSummaries ?? this.usesSummaries,
      reviewFrequencyCount: reviewFrequencyCount ?? this.reviewFrequencyCount,
      usesAdditionalSources: usesAdditionalSources ?? this.usesAdditionalSources,
      takesBreaks: takesBreaks ?? this.takesBreaks,
      breakDurationMinutes: breakDurationMinutes ?? this.breakDurationMinutes,
      hasFixedSchedule: hasFixedSchedule ?? this.hasFixedSchedule,
      feelsStressed: feelsStressed ?? this.feelsStressed,
      stressReason: stressReason ?? this.stressReason,
      usesTimeManagementApps: usesTimeManagementApps ?? this.usesTimeManagementApps,
      studyEnvironment: studyEnvironment ?? this.studyEnvironment,
      concentrationLevel: concentrationLevel ?? this.concentrationLevel,
      reviewsBeforeSleep: reviewsBeforeSleep ?? this.reviewsBeforeSleep,
      solvesExercises: solvesExercises ?? this.solvesExercises,
      distractions: distractions ?? this.distractions,
      examPreparationStrategy: examPreparationStrategy ?? this.examPreparationStrategy,
    );
  }
}