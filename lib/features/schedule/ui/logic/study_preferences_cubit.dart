import 'package:bloc/bloc.dart';
import 'package:camelson/core/core.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/event_model.dart';
import '../../data/models/study_preferences_model.dart';
import '../../data/repos/event_repository.dart';
import '../../data/repos/study_preferences_repository.dart';
import '../../data/services/ai_study_service.dart';

part 'study_preferences_state.dart';

class StudyPreferencesCubit extends Cubit<StudyPreferencesState> {
  final StudyPreferencesRepository _studyPreferencesRepository;
  final EventRepository _eventRepository;

  StudyPreferencesCubit({
    required StudyPreferencesRepository studyPreferencesRepository,
    required EventRepository eventRepository,
  }) : _studyPreferencesRepository = studyPreferencesRepository,
       _eventRepository = eventRepository,
       super(StudyPreferencesInitial());

  /// Check if user has completed initial setup
  Future<void> checkSetupStatus() async {
    try {
      safeEmit(StudyPreferencesLoading());

      final hasCompleted = await _studyPreferencesRepository
          .hasCompletedSetup();
      final currentPreferences = await _studyPreferencesRepository
          .getCurrentPreferences();

      if (hasCompleted && currentPreferences != null) {
        safeEmit(StudyPreferencesLoaded(preferences: currentPreferences));
      } else {
        safeEmit(StudyPreferencesSetupRequired());
      }
    } catch (e) {
      safeEmit(StudyPreferencesError(message: e.toString()));
    }
  }

  /// Save study preferences and generate AI plan
  Future<void> savePreferencesAndGeneratePlan(
    StudyPreferences preferences,
  ) async {
    try {
      safeEmit(StudyPreferencesLoading());

      // Save preferences
      await _studyPreferencesRepository.savePreferences(preferences);

      // Generate AI study plan
      safeEmit(StudyPreferencesGeneratingPlan(preferences: preferences));

      final generatedEvents = await AIStudyService.generateStudyPlan(
        preferences,
      );

      safeEmit(
        StudyPreferencesPlanGenerated(
          preferences: preferences,
          generatedEvents: generatedEvents,
        ),
      );
    } catch (e) {
      safeEmit(StudyPreferencesError(message: e.toString()));
    }
  }

  /// Accept the generated plan and save events
  Future<void> acceptGeneratedPlan(List<Event> events) async {
    try {
      safeEmit(StudyPreferencesLoading());

      // Clear existing system events (AI-generated events)
      final existingEvents = await _eventRepository.getEvents();
      for (final event in existingEvents) {
        if (event.type == EventType.system) {
          await _eventRepository.deleteEvent(event.id);
        }
      }

      // Add new generated events
      for (final event in events) {
        await _eventRepository.addEvent(event);
      }

      // Get current preferences
      final currentPreferences = await _studyPreferencesRepository
          .getCurrentPreferences();

      if (currentPreferences != null) {
        safeEmit(StudyPreferencesPlanAccepted(preferences: currentPreferences));
      } else {
        safeEmit(StudyPreferencesError(message: 'Failed to load preferences'));
      }
    } catch (e) {
      safeEmit(StudyPreferencesError(message: e.toString()));
    }
  }

  /// Update existing preferences
  Future<void> updatePreferences(StudyPreferences preferences) async {
    try {
      safeEmit(StudyPreferencesLoading());

      await _studyPreferencesRepository.updatePreferences(preferences);

      safeEmit(StudyPreferencesLoaded(preferences: preferences));
    } catch (e) {
      safeEmit(StudyPreferencesError(message: e.toString()));
    }
  }

  /// Get current preferences
  Future<void> loadCurrentPreferences() async {
    try {
      safeEmit(StudyPreferencesLoading());

      final preferences = await _studyPreferencesRepository
          .getCurrentPreferences();

      if (preferences != null) {
        safeEmit(StudyPreferencesLoaded(preferences: preferences));
      } else {
        safeEmit(StudyPreferencesSetupRequired());
      }
    } catch (e) {
      safeEmit(StudyPreferencesError(message: e.toString()));
    }
  }

  /// Reset preferences (for testing or fresh start)
  Future<void> resetPreferences() async {
    try {
      safeEmit(StudyPreferencesLoading());

      await _studyPreferencesRepository.clearAllPreferences();

      // Clear all system events
      final existingEvents = await _eventRepository.getEvents();
      for (final event in existingEvents) {
        if (event.type == EventType.system) {
          await _eventRepository.deleteEvent(event.id);
        }
      }

      safeEmit(StudyPreferencesSetupRequired());
    } catch (e) {
      safeEmit(StudyPreferencesError(message: e.toString()));
    }
  }
}
