// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_preferences_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StudyPreferencesAdapter extends TypeAdapter<StudyPreferences> {
  @override
  final typeId = 3;

  @override
  StudyPreferences read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudyPreferences(
      id: fields[0] as String,
      createdAt: fields[1] as DateTime,
      studyAllSubjectsDaily: fields[2] as bool,
      preferredSubjectsOrder: (fields[3] as List).cast<String>(),
      hardestSubject: fields[4] as String,
      hoursPerSubject: (fields[5] as Map).cast<String, double>(),
      favoriteSubject: fields[6] as String,
      timeConsumingSubject: fields[7] as String,
      scienceVsLiterature: fields[8] as String,
      studyStyle: fields[9] as String,
      reviewFrequency: fields[10] as String,
      usesAdditionalResources: fields[11] as bool,
      highestGradeSubject: fields[12] as String,
      hasTimeManagementDifficulty: fields[13] as bool,
      needsHelpWith: fields[14] as String,
      hardToRememberSubject: fields[15] as String,
      sameStudyMethodForAll: fields[16] as bool,
      timeTakingSubject: fields[17] as String,
      preferredLearningType: fields[18] as String,
      reviewsBeforeNewSubject: fields[19] as bool,
      prefersWeeklyDistribution: fields[20] as bool,
      examPreparationMethod: fields[21] as String,
      dailyStudyHours: (fields[22] as num).toDouble(),
      subjectsPerDay: (fields[23] as num).toInt(),
      preferredTimeToStudy: fields[24] as String,
      usesSummaries: fields[25] as bool,
      reviewFrequencyCount: (fields[26] as num).toInt(),
      usesAdditionalSources: fields[27] as bool,
      takesBreaks: fields[28] as bool,
      breakDurationMinutes: (fields[29] as num).toInt(),
      hasFixedSchedule: fields[30] as bool,
      feelsStressed: fields[31] as bool,
      stressReason: fields[32] as String,
      usesTimeManagementApps: fields[33] as bool,
      studyEnvironment: fields[34] as String,
      concentrationLevel: (fields[35] as num).toInt(),
      reviewsBeforeSleep: fields[36] as bool,
      solvesExercises: fields[37] as bool,
      distractions: (fields[38] as List).cast<String>(),
      examPreparationStrategy: fields[39] as String,
    );
  }

  @override
  void write(BinaryWriter writer, StudyPreferences obj) {
    writer
      ..writeByte(40)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.studyAllSubjectsDaily)
      ..writeByte(3)
      ..write(obj.preferredSubjectsOrder)
      ..writeByte(4)
      ..write(obj.hardestSubject)
      ..writeByte(5)
      ..write(obj.hoursPerSubject)
      ..writeByte(6)
      ..write(obj.favoriteSubject)
      ..writeByte(7)
      ..write(obj.timeConsumingSubject)
      ..writeByte(8)
      ..write(obj.scienceVsLiterature)
      ..writeByte(9)
      ..write(obj.studyStyle)
      ..writeByte(10)
      ..write(obj.reviewFrequency)
      ..writeByte(11)
      ..write(obj.usesAdditionalResources)
      ..writeByte(12)
      ..write(obj.highestGradeSubject)
      ..writeByte(13)
      ..write(obj.hasTimeManagementDifficulty)
      ..writeByte(14)
      ..write(obj.needsHelpWith)
      ..writeByte(15)
      ..write(obj.hardToRememberSubject)
      ..writeByte(16)
      ..write(obj.sameStudyMethodForAll)
      ..writeByte(17)
      ..write(obj.timeTakingSubject)
      ..writeByte(18)
      ..write(obj.preferredLearningType)
      ..writeByte(19)
      ..write(obj.reviewsBeforeNewSubject)
      ..writeByte(20)
      ..write(obj.prefersWeeklyDistribution)
      ..writeByte(21)
      ..write(obj.examPreparationMethod)
      ..writeByte(22)
      ..write(obj.dailyStudyHours)
      ..writeByte(23)
      ..write(obj.subjectsPerDay)
      ..writeByte(24)
      ..write(obj.preferredTimeToStudy)
      ..writeByte(25)
      ..write(obj.usesSummaries)
      ..writeByte(26)
      ..write(obj.reviewFrequencyCount)
      ..writeByte(27)
      ..write(obj.usesAdditionalSources)
      ..writeByte(28)
      ..write(obj.takesBreaks)
      ..writeByte(29)
      ..write(obj.breakDurationMinutes)
      ..writeByte(30)
      ..write(obj.hasFixedSchedule)
      ..writeByte(31)
      ..write(obj.feelsStressed)
      ..writeByte(32)
      ..write(obj.stressReason)
      ..writeByte(33)
      ..write(obj.usesTimeManagementApps)
      ..writeByte(34)
      ..write(obj.studyEnvironment)
      ..writeByte(35)
      ..write(obj.concentrationLevel)
      ..writeByte(36)
      ..write(obj.reviewsBeforeSleep)
      ..writeByte(37)
      ..write(obj.solvesExercises)
      ..writeByte(38)
      ..write(obj.distractions)
      ..writeByte(39)
      ..write(obj.examPreparationStrategy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudyPreferencesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
