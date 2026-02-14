import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/api/api_service.dart';
import '../../../../auth/data/models/auth_response.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ApiService _apiService;

  ProfileCubit(this._apiService) : super(const ProfileState());

  /// Load student profile and academic data
  Future<void> loadProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading));

    try {
      // Load all data in parallel
      final results = await Future.wait([
        _apiService.getStudentProfile(),
        _apiService.getAcademicStages(),
        _apiService.getAcademicYears(),
        _apiService.getAcademicSections(),
      ]);

      final profileResponse = results[0] as StudentProfileResponse;
      final stagesResponse = results[1] as AcademicStagesResponse;
      final yearsResponse = results[2] as AcademicYearsResponse;
      final sectionsResponse = results[3] as AcademicSectionsResponse;

      if (profileResponse.isSuccess) {
        emit(state.copyWith(
          status: ProfileStatus.success,
          userData: profileResponse.data,
          stages: stagesResponse.data,
          years: yearsResponse.data,
          sections: sectionsResponse.data,
        ));
      } else {
        emit(state.copyWith(
          status: ProfileStatus.error,
          errorMessage: profileResponse.message ?? 'Failed to load profile',
        ));
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error loading profile',
        name: 'ProfileCubit',
        error: e,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Update student profile
  Future<bool> updateProfile({
    String? name,
    String? nickname,
    int? gender,
    String? phoneNumber,
    String? dateOfBirth,
    int? academicStageId,
    int? academicYearId,
    int? academicSectionId,
  }) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    try {
      final request = UpdateStudentProfileRequest(
        name: name,
        nickname: nickname,
        gender: gender,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        academicStageId: academicStageId,
        academicYearId: academicYearId,
        academicSectionId: academicSectionId,
      );

      final response = await _apiService.updateStudentProfile(request);

      if (response.isSuccess) {
        emit(state.copyWith(
          status: ProfileStatus.success,
          userData: response.data,
        ));
        return true;
      } else {
        emit(state.copyWith(
          status: ProfileStatus.error,
          errorMessage: response.message ?? 'Failed to update profile',
        ));
        return false;
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error updating profile',
        name: 'ProfileCubit',
        error: e,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }
}
