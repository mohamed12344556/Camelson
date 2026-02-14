import 'package:hive_ce/hive.dart';

import '../models/study_preferences_model.dart';

class StudyPreferencesRepository {
  static const String _boxName = 'study_preferences';

  Future<Box<StudyPreferences>> get _box async => 
      await Hive.openBox<StudyPreferences>(_boxName);

  /// Get the current study preferences
  Future<StudyPreferences?> getCurrentPreferences() async {
    final box = await _box;
    if (box.isEmpty) return null;
    
    // Get the most recent preferences
    final preferences = box.values.toList();
    preferences.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return preferences.first;
  }

  /// Save new study preferences
  Future<void> savePreferences(StudyPreferences preferences) async {
    final box = await _box;
    await box.put(preferences.id, preferences);
  }

  /// Update existing preferences
  Future<void> updatePreferences(StudyPreferences preferences) async {
    final box = await _box;
    await box.put(preferences.id, preferences);
  }

  /// Get all preferences history
  Future<List<StudyPreferences>> getAllPreferences() async {
    final box = await _box;
    final preferences = box.values.toList();
    preferences.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return preferences;
  }

  /// Delete specific preferences
  Future<void> deletePreferences(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  /// Clear all preferences
  Future<void> clearAllPreferences() async {
    final box = await _box;
    await box.clear();
  }

  /// Check if user has completed the initial setup
  Future<bool> hasCompletedSetup() async {
    final preferences = await getCurrentPreferences();
    return preferences != null;
  }

  /// Get preferences created within a specific time range
  Future<List<StudyPreferences>> getPreferencesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final box = await _box;
    return box.values
        .where((prefs) => 
            prefs.createdAt.isAfter(startDate) && 
            prefs.createdAt.isBefore(endDate))
        .toList();
  }
}