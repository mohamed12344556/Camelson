import 'package:equatable/equatable.dart';

import '../../../../auth/data/models/auth_response.dart';

enum ProfileStatus { initial, loading, success, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserData? userData;
  final List<AcademicStage>? stages;
  final List<AcademicYear>? years;
  final List<AcademicSection>? sections;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.userData,
    this.stages,
    this.years,
    this.sections,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserData? userData,
    List<AcademicStage>? stages,
    List<AcademicYear>? years,
    List<AcademicSection>? sections,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      userData: userData ?? this.userData,
      stages: stages ?? this.stages,
      years: years ?? this.years,
      sections: sections ?? this.sections,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Get years filtered by selected stage
  List<AcademicYear> getYearsForStage(int? stageId) {
    if (years == null || stageId == null) return [];
    return years!.where((y) => y.academicStageId == stageId).toList();
  }

  @override
  List<Object?> get props => [
    status,
    userData,
    stages,
    years,
    sections,
    errorMessage,
  ];
}
