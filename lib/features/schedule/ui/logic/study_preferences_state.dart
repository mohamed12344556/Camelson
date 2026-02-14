part of 'study_preferences_cubit.dart';

abstract class StudyPreferencesState extends Equatable {
  const StudyPreferencesState();

  @override
  List<Object?> get props => [];
}

class StudyPreferencesInitial extends StudyPreferencesState {}

class StudyPreferencesLoading extends StudyPreferencesState {}

class StudyPreferencesSetupRequired extends StudyPreferencesState {}

class StudyPreferencesLoaded extends StudyPreferencesState {
  final StudyPreferences preferences;

  const StudyPreferencesLoaded({required this.preferences});

  @override
  List<Object?> get props => [preferences];
}

class StudyPreferencesGeneratingPlan extends StudyPreferencesState {
  final StudyPreferences preferences;

  const StudyPreferencesGeneratingPlan({required this.preferences});

  @override
  List<Object?> get props => [preferences];
}

class StudyPreferencesPlanGenerated extends StudyPreferencesState {
  final StudyPreferences preferences;
  final List<Event> generatedEvents;

  const StudyPreferencesPlanGenerated({
    required this.preferences,
    required this.generatedEvents,
  });

  @override
  List<Object?> get props => [preferences, generatedEvents];
}

class StudyPreferencesPlanAccepted extends StudyPreferencesState {
  final StudyPreferences preferences;

  const StudyPreferencesPlanAccepted({required this.preferences});

  @override
  List<Object?> get props => [preferences];
}

class StudyPreferencesError extends StudyPreferencesState {
  final String message;

  const StudyPreferencesError({required this.message});

  @override
  List<Object?> get props => [message];
}