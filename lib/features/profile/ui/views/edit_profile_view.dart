import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toastification/toastification.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../auth/data/models/auth_response.dart';
import '../logic/profle/profile_cubit.dart';
import '../logic/profle/profile_state.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileCubit>()..loadProfile(),
      child: const _EditProfileContent(),
    );
  }
}

class _EditProfileContent extends StatefulWidget {
  const _EditProfileContent();

  @override
  State<_EditProfileContent> createState() => _EditProfileContentState();
}

class _EditProfileContentState extends State<_EditProfileContent> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _nickNameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  int? _selectedGender;
  int? _selectedStageId;
  int? _selectedYearId;
  int? _selectedSectionId;
  DateTime? _selectedDate;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.setNavBarVisible(false);
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nickNameController.dispose();
    _dateOfBirthController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _initializeFields(UserData userData) {
    if (_isInitialized) return;
    _isInitialized = true;

    _fullNameController.text = userData.name ?? '';
    _nickNameController.text = userData.nickname ?? '';
    _emailController.text = userData.email ?? '';
    _phoneController.text = userData.phoneNumber ?? '';
    _selectedGender = userData.gender;
    _selectedStageId = userData.academicStageId;
    _selectedYearId = userData.academicYearId;
    _selectedSectionId = userData.academicSectionId;

    if (userData.dateOfBirth != null) {
      try {
        _selectedDate = DateTime.parse(userData.dateOfBirth!);
        _dateOfBirthController.text =
            '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF5F9FF),
      appBar: CustomAppBar(
        title: 'Edit Profile',
        onBackPressed: () {
          context.setNavBarVisible(true);
          Navigator.pop(context);
        },
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.error) {
            toastification.show(
              context: context,
              title: Text(state.errorMessage ?? 'An error occurred'),
              type: ToastificationType.error,
              autoCloseDuration: const Duration(seconds: 3),
            );
          }
        },
        builder: (context, state) {
          if (state.status == ProfileStatus.loading && state.userData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.userData != null) {
            _initializeFields(state.userData!);
          }

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 18.h),
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                  borderRadius: BorderRadius.circular(40.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(25.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: 20.h),
                        _buildAvatar(isDarkMode, state.userData),
                        SizedBox(height: 40.h),
                        _buildTextField(
                          controller: _fullNameController,
                          label: 'Full Name',
                          icon: Icons.person_outline,
                          isDarkMode: isDarkMode,
                        ),
                        SizedBox(height: 20.h),
                        _buildTextField(
                          controller: _nickNameController,
                          label: 'Nickname',
                          icon: Icons.person_outline,
                          isDarkMode: isDarkMode,
                        ),
                        SizedBox(height: 20.h),
                        _buildTextField(
                          controller: _dateOfBirthController,
                          label: 'Date of Birth',
                          icon: Icons.calendar_today_outlined,
                          onTap: () => _selectDate(context),
                          readOnly: true,
                          isDarkMode: isDarkMode,
                          isRequired: false,
                        ),
                        SizedBox(height: 20.h),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          isDarkMode: isDarkMode,
                          enabled: false,
                        ),
                        SizedBox(height: 20.h),
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          isDarkMode: isDarkMode,
                          isRequired: false,
                        ),
                        SizedBox(height: 20.h),
                        _buildGenderDropdown(isDarkMode),
                        SizedBox(height: 20.h),
                        _buildStageDropdown(isDarkMode, state.stages),
                        SizedBox(height: 20.h),
                        _buildYearDropdown(isDarkMode, state),
                        SizedBox(height: 20.h),
                        _buildSectionDropdown(isDarkMode, state.sections),
                        SizedBox(height: 40.h),
                        _buildUpdateButton(state),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar(bool isDarkMode, UserData? userData) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 50.r,
          backgroundColor: isDarkMode
              ? const Color(0xFF0961F5).withValues(alpha: 0.2)
              : const Color(0xFFE8F4FD),
          backgroundImage: userData?.profileImageUrl != null
              ? NetworkImage(userData!.profileImageUrl!)
              : null,
          child: userData?.profileImageUrl == null
              ? Icon(
                  Icons.person,
                  size: 60.sp,
                  color: const Color(0xFF0961F5),
                )
              : null,
        ),
        Positioned(
          right: -5.w,
          bottom: -5.h,
          child: Container(
            width: 35.w,
            height: 35.h,
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: const Color(0xFF2F98D7),
                width: 3.w,
              ),
            ),
            child: Center(
              child: Text(
                userData?.name?.isNotEmpty == true
                    ? userData!.name![0].toUpperCase()
                    : 'U',
                style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w800,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDarkMode,
    TextInputType? keyboardType,
    VoidCallback? onTap,
    bool readOnly = false,
    bool enabled = true,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onTap: onTap,
      readOnly: readOnly,
      enabled: enabled,
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black,
        fontSize: 16.sp,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          fontSize: 16.sp,
        ),
        prefixIcon: Icon(
          icon,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          size: 20.sp,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF0961F5)),
        ),
        filled: true,
        fillColor: enabled
            ? (isDarkMode ? const Color(0xFF3A3A3A) : Colors.grey[50])
            : (isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[200]),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $label';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildGenderDropdown(bool isDarkMode) {
    return _buildDropdown<int>(
      value: _selectedGender,
      hint: 'Select Gender',
      icon: Icons.person_outline,
      isDarkMode: isDarkMode,
      items: const [
        DropdownMenuItem(value: 1, child: Text('Male')),
        DropdownMenuItem(value: 2, child: Text('Female')),
      ],
      onChanged: (value) => setState(() => _selectedGender = value),
    );
  }

  Widget _buildStageDropdown(bool isDarkMode, List<AcademicStage>? stages) {
    return _buildDropdown<int>(
      value: _selectedStageId,
      hint: 'Select Academic Stage',
      icon: Icons.school_outlined,
      isDarkMode: isDarkMode,
      items: stages
              ?.map((stage) => DropdownMenuItem(
                    value: stage.id,
                    child: Text(stage.name ?? stage.stageName ?? ''),
                  ))
              .toList() ??
          [],
      onChanged: (value) {
        setState(() {
          _selectedStageId = value;
          _selectedYearId = null; // Reset year when stage changes
        });
      },
    );
  }

  Widget _buildYearDropdown(bool isDarkMode, ProfileState state) {
    final filteredYears = state.getYearsForStage(_selectedStageId);
    return _buildDropdown<int>(
      value: filteredYears.any((y) => y.id == _selectedYearId)
          ? _selectedYearId
          : null,
      hint: 'Select Academic Year',
      icon: Icons.calendar_month_outlined,
      isDarkMode: isDarkMode,
      items: filteredYears
          .map((year) => DropdownMenuItem(
                value: year.id,
                child: Text(year.name ?? year.yearName ?? ''),
              ))
          .toList(),
      onChanged: (value) => setState(() => _selectedYearId = value),
    );
  }

  Widget _buildSectionDropdown(
      bool isDarkMode, List<AcademicSection>? sections) {
    return _buildDropdown<int>(
      value: _selectedSectionId,
      hint: 'Select Section',
      icon: Icons.class_outlined,
      isDarkMode: isDarkMode,
      items: sections
              ?.map((section) => DropdownMenuItem(
                    value: section.id,
                    child: Text(section.name ?? section.sectionName ?? ''),
                  ))
              .toList() ??
          [],
      onChanged: (value) => setState(() => _selectedSectionId = value),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required IconData icon,
    required bool isDarkMode,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF3A3A3A) : Colors.grey[50],
        border: Border.all(
          color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        hint: Text(
          hint,
          style: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            fontSize: 16.sp,
          ),
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            size: 20.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        ),
        dropdownColor: isDarkMode ? const Color(0xFF3A3A3A) : Colors.white,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: 16.sp,
        ),
        items: items,
        onChanged: onChanged,
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          size: 20.sp,
        ),
      ),
    );
  }

  Widget _buildUpdateButton(ProfileState state) {
    final isLoading = state.status == ProfileStatus.loading;
    return SizedBox(
      width: double.infinity,
      height: 55.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleUpdate,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0961F5),
          disabledBackgroundColor: const Color(0xFF0961F5).withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24.w,
                height: 24.h,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Update',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<ProfileCubit>();
    final success = await cubit.updateProfile(
      name: _fullNameController.text,
      nickname: _nickNameController.text,
      gender: _selectedGender,
      phoneNumber: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      dateOfBirth: _selectedDate != null
          ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
          : null,
      academicStageId: _selectedStageId,
      academicYearId: _selectedYearId,
      academicSectionId: _selectedSectionId,
    );

    if (success && mounted) {
      toastification.show(
        context: context,
        title: const Text('Profile updated successfully'),
        type: ToastificationType.success,
        autoCloseDuration: const Duration(seconds: 2),
      );
      context.setNavBarVisible(true);
      Navigator.pop(context);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: const Color(0xFF0961F5),
              onPrimary: Colors.white,
              surface: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
              onSurface: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateOfBirthController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }
}
