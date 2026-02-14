import 'dart:async';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/token_manager.dart';
import '../../../../core/constants/key_strings.dart';
import '../../../../core/core.dart';
import '../../../../generated/l10n.dart';
import '../../../community/data/models/community_constants.dart';
import '../../data/models/auth_request.dart';
import '../../data/models/auth_response.dart';
import '../../data/repo/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final ApiService _apiService;
  final AuthRepository _authRepository;
  String? currentSignupEmail;

  AuthCubit(this._apiService, this._authRepository) : super(AuthInitial());

  // Controllers
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  final TextEditingController registrationEmailController =
      TextEditingController();
  final TextEditingController registerPasswordController =
      TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final loginEmailFocusNode = FocusNode();
  final loginPasswordFocusNode = FocusNode();
  final registrationEmailFocusNode = FocusNode();
  final registerPasswordFocusNode = FocusNode();
  final userNameFocusNode = FocusNode();
  final usernameFocusNode = FocusNode();
  final mobileNumberFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();

  // Toggle States
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isTeacherSelected = true;

  // Password criteria
  bool hasMinLength = false;
  bool hasUppercase = false;
  bool hasLowercase = false;
  bool hasNumber = false;
  bool hasSpecialChar = false;

  // Validation states
  bool isEmailValid = false;
  bool isPasswordValid = false;

  // Dropdown values (Old - for compatibility)
  String? selectedRole;
  String? selectedYear;
  String? selectedSpecialization;

  // Academic Dropdown IDs (New backend)
  int? selectedAcademicStageId;
  int? selectedAcademicYearId;
  int? selectedAcademicSectionId;

  // Lists for dropdowns (Old)
  final List<String> roles = S.current.roles.split('\n');
  final List<String> years = S.current.years.split('\n');
  final List<String> specializations = S.current.specializations.split('\n');

  // Academic Data Lists (New backend)
  List<AcademicStage> academicStages = [];
  List<AcademicYear> academicYears = [];
  List<AcademicSection> academicSections = [];
  bool isLoadingAcademicData = false;

  // OTP Related
  Timer? _timer;
  bool canResend = true;
  String timerText = '';
  final int otpLength = 6;
  String userOtp = '';
  bool isOtpValid = false;
  bool isPasswordReset = false;
  String? selectedEmail;
  String? verificationToken;

  // Toggle Functions
  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    safeEmit(SignUpFormChanged());
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
    safeEmit(SignUpFormChanged());
  }

  void toggleRole(bool isTeacher) {
    isTeacherSelected = isTeacher;
    safeEmit(SignUpFormChanged());
    loginEmailController.clear();
    loginPasswordController.clear();
  }

  // Dropdown handlers (Old)
  void handleRoleChange(String? value) {
    selectedRole = value;
    safeEmit(SignUpFormChanged());
  }

  void handleYearChange(String? value) {
    selectedYear = value?.replaceAll(' ', '');
    safeEmit(SignUpFormChanged());
  }

  void handleSpecializationChange(String? value) {
    selectedSpecialization = value;
    safeEmit(SignUpFormChanged());
  }

  // Academic Dropdown handlers (New)
  void handleAcademicStageChange(int? stageId) {
    selectedAcademicStageId = stageId;
    // Reset dependent dropdowns
    selectedAcademicYearId = null;
    selectedAcademicSectionId = null;
    safeEmit(SignUpFormChanged());
    // Fetch years for selected stage if needed
  }

  void handleAcademicYearChange(int? yearId) {
    selectedAcademicYearId = yearId;
    safeEmit(SignUpFormChanged());
  }

  void handleAcademicSectionChange(int? sectionId) {
    selectedAcademicSectionId = sectionId;
    safeEmit(SignUpFormChanged());
  }

  // Email validation
  void validateEmail(String email) {
    isEmailValid = email.isNotEmpty && email.contains('@');
    safeEmit(SignUpFormChanged());
  }

  // Password validation
  void checkPassword(String value) {
    hasMinLength = value.length >= 8;
    hasUppercase = value.contains(RegExp(r'[A-Z]'));
    hasLowercase = value.contains(RegExp(r'[a-z]'));
    hasNumber = value.contains(RegExp(r'[0-9]'));
    hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    safeEmit(SignUpFormChanged());
  }

  void validatePassword(String password) {
    isPasswordValid = password.isNotEmpty && password.length >= 8;
    safeEmit(SignUpFormChanged());
  }

  //? Login Methods
  void handleSignIn(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;

    safeEmit(AuthLoading());

    try {
      final response = await _authRepository.login(
        email: loginEmailController.text.trim(),
        password: loginPasswordController.text,
      );

      await response.fold(
        (error) {
          safeEmit(LoginError(error));
        },
        (response) async {
          if (response.isSuccess && response.data != null) {
            try {
              await saveUserTokens(
                token: response.data!.accessToken!,
                refreshToken: response.data!.refreshToken!,
              );

              // Update Community user from Auth response
              if (response.data!.user != null) {
                final communityUser = UserService.convertToCommunityUser(
                  response.data!.user!,
                );
                CommunityConstants.updateCurrentUser(communityUser);
                log('Login: Community user updated - ${communityUser.name}');
              } else {
                // Fallback: load from token
                await CommunityConstants.initializeCurrentUser();
                log('Login: Community user loaded from token');
              }

              AppState.isLoggedIn = true;
              await SharedPrefHelper.setData(StorageKeys.isLoggedIn, true);
              safeEmit(LoginSuccess());
            } catch (e) {
              safeEmit(
                LoginError(
                  ApiErrorModel(
                    errorMessage: ErrorData(message: 'Error saving user data'),
                  ),
                ),
              );
            }
          } else {
            safeEmit(
              LoginError(
                ApiErrorModel(
                  errorMessage: ErrorData(
                    message: response.message ?? 'Login failed',
                  ),
                ),
              ),
            );
          }
        },
      );
    } catch (e) {
      safeEmit(
        LoginError(
          ApiErrorModel(errorMessage: ErrorData(message: e.toString())),
        ),
      );
    }
  }

  //? Sign Up Methods
  bool get isSignUpFormValid {
    return userNameController.text.isNotEmpty &&
        usernameController.text.isNotEmpty &&
        registrationEmailController.text.isNotEmpty &&
        mobileNumberController.text.isNotEmpty &&
        registerPasswordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        selectedRole != null &&
        selectedAcademicStageId != null &&
        selectedAcademicYearId != null &&
        selectedAcademicSectionId != null &&
        hasMinLength &&
        hasUppercase &&
        hasLowercase &&
        hasNumber &&
        hasSpecialChar;
  }

  void validateSignUpForm() {
    safeEmit(SignUpFormChanged());
  }

  String _formatPhoneNumber(String phone) {
    if (phone.startsWith('+')) return phone;
    if (phone.startsWith('0')) return '+2$phone';
    return '+2$phone';
  }

  void handleSignup(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate() || !isSignUpFormValid) return;

    safeEmit(AuthLoading());
    currentSignupEmail = registrationEmailController.text.trim();

    try {
      final response = await _authRepository.signup(
        name: userNameController.text.trim(),
        username: usernameController.text.trim(),
        email: currentSignupEmail!,
        phoneNumber: _formatPhoneNumber(mobileNumberController.text.trim()),
        password: registerPasswordController.text,
        confirmPassword: confirmPasswordController.text,
        role: isTeacherSelected ? 'Teacher' : 'Student',
        academicStageId: selectedAcademicStageId ?? 1,
        academicYearId: selectedAcademicYearId ?? 1,
        academicSectionId: selectedAcademicSectionId ?? 1,
      );

      response.fold((error) => safeEmit(SignUpError(message: error)), (
        response,
      ) async {
        if (response.isSuccess && response.data != null) {
          // New backend returns tokens directly after signup
          try {
            await saveUserTokens(
              token: response.data!.accessToken!,
              refreshToken: response.data!.refreshToken!,
            );

            // Update Community user from Auth response
            if (response.data!.user != null) {
              final communityUser = UserService.convertToCommunityUser(
                response.data!.user!,
              );
              CommunityConstants.updateCurrentUser(communityUser);
              log('Signup: Community user updated - ${communityUser.name}');
            } else {
              // Fallback: load from token
              await CommunityConstants.initializeCurrentUser();
              log('Signup: Community user loaded from token');
            }

            AppState.isLoggedIn = true;
            await SharedPrefHelper.setData(StorageKeys.isLoggedIn, true);
            safeEmit(SignUpSuccess(email: currentSignupEmail!));
          } catch (e) {
            safeEmit(
              SignUpError(
                message: ApiErrorModel(
                  errorMessage: ErrorData(message: 'Error saving user data'),
                  status: false,
                ),
              ),
            );
          }
        } else {
          safeEmit(
            SignUpError(
              message: ApiErrorModel(
                errorMessage: ErrorData(
                  message: response.message ?? 'Registration failed',
                ),
                status: false,
              ),
            ),
          );
        }
      });
    } catch (e) {
      safeEmit(
        SignUpError(
          message: ApiErrorModel(
            errorMessage: ErrorData(message: e.toString()),
            status: false,
          ),
        ),
      );
    }
  }

  //? OTP Methods
  void startTimer() {
    canResend = false;
    int secondsRemaining = 60;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining <= 0) {
        canResend = true;
        timer.cancel();
        safeEmit(AuthInitial());
      } else {
        secondsRemaining--;
        timerText = '${secondsRemaining}s';
        safeEmit(AuthInitial());
      }
    });
  }

  void setEmail(String userEmail, {bool isReset = false}) {
    selectedEmail = userEmail;
    isPasswordReset = isReset;
    startTimer();
  }

  void updateUserInput(String value) {
    userOtp = value;
    isOtpValid = value.length == otpLength;
    safeEmit(AuthInitial());
  }

  //? Verify OTP (Unified for both email verification and password reset)
  Future<void> verifyOtp() async {
    if (!isOtpValid) return;

    log(
      'Debugging verifyOtp - Email: $selectedEmail, OTP: $userOtp, isPasswordReset: $isPasswordReset',
    );

    try {
      safeEmit(AuthLoading());

      final response = await _authRepository.verifyOtp(
        email: selectedEmail!,
        otp: userOtp,
      );

      response.fold((error) => safeEmit(OtpError(message: error)), (success) {
        if (success.isSuccess) {
          // Save verification token for password reset
          if (isPasswordReset && success.data != null) {
            verificationToken = success.data
                .toString(); // Store the token string
            log('Saved verification token for password reset');
          }
          log('OTP verified successfully');
          safeEmit(OtpSuccess());
        } else {
          safeEmit(
            OtpError(
              message: ApiErrorModel(
                errorMessage: ErrorData(
                  message: success.message ?? 'OTP verification failed',
                ),
                status: false,
              ),
            ),
          );
        }
      });
    } catch (e) {
      log('Debugging verifyOtp - Error: $e');
      safeEmit(
        OtpError(
          message: ApiErrorModel(
            errorMessage: ErrorData(message: e.toString()),
            status: false,
          ),
        ),
      );
    }
  }

  //? Resend OTP
  Future<void> resendOtp() async {
    if (!canResend) return;

    try {
      safeEmit(AuthLoading());

      // New backend: Just resend forgot password OTP
      final response = await _authRepository.forgotPassword(
        email: selectedEmail!,
      );

      response.fold(
        (error) {
          safeEmit(OtpError(message: error));
        },
        (success) {
          if (success.isSuccess) {
            startTimer();
            safeEmit(AuthInitial());
          } else {
            safeEmit(
              OtpError(
                message: ApiErrorModel(
                  errorMessage: ErrorData(
                    message: success.message ?? 'Failed to resend OTP',
                  ),
                  status: false,
                ),
              ),
            );
          }
        },
      );
    } catch (e) {
      safeEmit(
        OtpError(
          message: ApiErrorModel(
            errorMessage: ErrorData(message: e.toString()),
            status: false,
          ),
        ),
      );
    }
  }

  //? Forgot Password Methods
  Future<void> sendForgotPasswordOTP({required String email}) async {
    safeEmit(AuthLoading());

    try {
      final response = await _authRepository.forgotPassword(
        email: email.trim(),
      );

      response.fold(
        (error) {
          safeEmit(AuthError(error));
        },
        (success) async {
          if (success.isSuccess) {
            selectedEmail = email;
            safeEmit(AuthSuccess());
          } else {
            safeEmit(
              AuthError(
                ApiErrorModel(
                  errorMessage: ErrorData(
                    message: success.message ?? 'Failed to send OTP',
                  ),
                  status: false,
                ),
              ),
            );
          }
        },
      );
    } catch (e) {
      safeEmit(
        AuthError(
          ApiErrorModel(
            errorMessage: ErrorData(message: e.toString()),
            status: false,
          ),
        ),
      );
    }
  }

  //? Reset Password Methods
  void resetPassword(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;

    // Validate verification token
    if (verificationToken == null || verificationToken!.isEmpty) {
      safeEmit(
        ResetPasswordFailure(
          message: ApiErrorModel(
            errorMessage: ErrorData(
              message: 'Verification token missing. Please verify OTP first.',
            ),
            status: false,
          ),
        ),
      );
      return;
    }

    safeEmit(AuthLoading());

    try {
      final response = await _authRepository.resetPassword(
        email: selectedEmail!,
        newPassword: loginPasswordController.text,
        confirmPassword: confirmPasswordController.text,
        verificationToken: verificationToken!,
      );

      response.fold(
        (error) {
          safeEmit(ResetPasswordFailure(message: error));
        },
        (success) async {
          if (success.isSuccess) {
            // Clear verification token
            verificationToken = null;
            await logout();
            safeEmit(ResetPasswordSuccess());
          } else {
            safeEmit(
              ResetPasswordFailure(
                message: ApiErrorModel(
                  errorMessage: ErrorData(
                    message: success.message ?? 'Failed to reset password',
                  ),
                  status: false,
                ),
              ),
            );
          }
        },
      );
    } catch (e) {
      safeEmit(ResetPasswordFailure(message: ApiErrorHandler.handle(e)));
    }
  }

  //? Token Management Methods
  Future<void> saveUserTokens({
    required String token,
    required String refreshToken,
  }) async {
    try {
      if (token.isEmpty || refreshToken.isEmpty) {
        throw Exception('Invalid tokens received');
      }

      await TokenManager.saveTokens(
        accessToken: token,
        refreshToken: refreshToken,
      );

      AppState.isLoggedIn = true;
      await SharedPrefHelper.setData(StorageKeys.isLoggedIn, true);

      safeEmit(AuthSuccess());
    } catch (e) {
      safeEmit(
        AuthError(
          ApiErrorModel(
            errorMessage: ErrorData(message: 'Failed to save tokens: $e'),
            status: false,
          ),
        ),
      );
    }
  }

  //? Logout
  Future<void> logout() async {
    try {
      safeEmit(AuthLoading());

      final tokens = await TokenManager.getTokens();
      if (tokens != null) {
        try {
          // Call new backend logout endpoint
          await _authRepository.logout();
        } catch (e) {
          log('Error calling logout endpoint: $e');
        }
      }

      await TokenManager.clearTokens();
      AppState.isLoggedIn = false;
      await SharedPrefHelper.setData(StorageKeys.isLoggedIn, false);

      // Reset Community user to guest
      CommunityConstants.resetCurrentUser();
      log('Logout: Community user reset to guest');

      clearAuthData();
      safeEmit(AuthLoggedOut());
    } catch (e) {
      safeEmit(
        AuthError(
          ApiErrorModel(
            errorMessage: ErrorData(message: 'Logout failed: $e'),
            status: false,
          ),
        ),
      );
    }
  }

  //? Check if user is logged in
  // Future<bool> checkIsLoggedIn() async {
  //   try {
  //     safeEmit(AuthLoading());
  //     final isLoggedIn = await SharedPrefHelper.getBool(StorageKeys.isLoggedIn);
  //     AppState.isLoggedIn = isLoggedIn;

  //     final tokens = await TokenManager.getTokens();
  //     if (tokens == null) {
  //       AppState.isLoggedIn = false;
  //       await SharedPrefHelper.setData(StorageKeys.isLoggedIn, false);
  //       safeEmit(AuthLoggedOut());
  //       return false;
  //     }

  //     try {
  //       final response = await _apiService.testAuthenticatedEndpoint();
  //       if (response.status == true) {
  //         AppState.isLoggedIn = true;
  //         await SharedPrefHelper.setData(StorageKeys.isLoggedIn, true);
  //         safeEmit(AuthSuccess());
  //         return true;
  //       }

  //       final refreshResult = await refreshToken();
  //       return refreshResult.fold(
  //         (error) {
  //           AppState.isLoggedIn = false;
  //           SharedPrefHelper.setData(StorageKeys.isLoggedIn, false);
  //           return false;
  //         },
  //         (response) {
  //           AppState.isLoggedIn = response.isSuccess;
  //           SharedPrefHelper.setData(
  //               StorageKeys.isLoggedIn, response.isSuccess);
  //           return response.isSuccess;
  //         },
  //       );
  //     } catch (e) {
  //       log('Error checking auth status: $e');
  //       AppState.isLoggedIn = false;
  //       await SharedPrefHelper.setData(StorageKeys.isLoggedIn, false);
  //       safeEmit(AuthLoggedOut());
  //       return false;
  //     }
  //   } catch (e) {
  //     safeEmit(AuthError(ApiErrorModel(
  //       errorMessage: ErrorData(message: 'Failed to check login status: $e'),
  //       status: false,
  //     )));
  //     return false;
  //   }
  // }

  //? Refresh Token
  Future<Either<ApiErrorModel, AuthResponse>> refreshToken() async {
    try {
      safeEmit(AuthLoading());

      final tokens = await TokenManager.getTokens();
      if (tokens == null) {
        throw Exception('No tokens available for refresh');
      }

      final refreshRequest = AuthRequest.refreshToken(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      final response = await _apiService.refreshToken(refreshRequest);

      if (response.isSuccess && response.data != null) {
        await TokenManager.saveTokens(
          accessToken: response.data!.accessToken!,
          refreshToken: response.data!.refreshToken!,
        );
        safeEmit(AuthSuccess());
        return Right(response);
      }

      safeEmit(
        AuthError(
          ApiErrorModel(
            errorMessage: ErrorData(message: 'Token refresh failed'),
            status: false,
          ),
        ),
      );
      return Left(
        ApiErrorModel(
          errorMessage: ErrorData(message: 'Token refresh failed'),
          status: false,
        ),
      );
    } catch (e) {
      final error = ApiErrorHandler.handle(e);
      safeEmit(AuthError(error));
      return Left(error);
    }
  }

  // bool isTokenExpired(String token) {
  //   try {
  //     final parts = token.split('.');
  //     if (parts.length != 3) return true;

  //     final payload = parts[1];
  //     final normalized = base64Url.normalize(payload);
  //     final resp = utf8.decode(base64Url.decode(normalized));
  //     final payloadMap = json.decode(resp);

  //     if (!payloadMap.containsKey('exp')) return true;

  //     final expiry =
  //         DateTime.fromMillisecondsSinceEpoch(payloadMap['exp'] * 1000);
  //     return DateTime.now().isAfter(expiry);
  //   } catch (e) {
  //     return true;
  //   }
  // }
  bool isTokenExpired(String token) {
    return TokenManager.isTokenExpired(token);
  }

  //? Change Password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      safeEmit(AuthLoading());

      final response = await _authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      response.fold((error) => safeEmit(AuthError(error)), (success) {
        if (success.isSuccess) {
          safeEmit(AuthSuccess());
        } else {
          safeEmit(
            AuthError(
              ApiErrorModel(
                errorMessage: ErrorData(
                  message: success.message ?? 'Failed to change password',
                ),
                status: false,
              ),
            ),
          );
        }
      });
    } catch (e) {
      safeEmit(
        AuthError(
          ApiErrorModel(
            errorMessage: ErrorData(message: e.toString()),
            status: false,
          ),
        ),
      );
    }
  }

  //? Get User Profile
  Future<void> getUserProfile() async {
    try {
      safeEmit(AuthLoading());

      final response = await _authRepository.getUserProfile();

      response.fold((error) => safeEmit(AuthError(error)), (success) {
        if (success.isSuccess && success.data != null) {
          log('User profile fetched: ${success.data!.email}');
          safeEmit(AuthSuccess());
        } else {
          safeEmit(
            AuthError(
              ApiErrorModel(
                errorMessage: ErrorData(
                  message: success.message ?? 'Failed to get profile',
                ),
                status: false,
              ),
            ),
          );
        }
      });
    } catch (e) {
      safeEmit(
        AuthError(
          ApiErrorModel(
            errorMessage: ErrorData(message: e.toString()),
            status: false,
          ),
        ),
      );
    }
  }

  //? Get Academic Data
  Future<void> fetchAcademicStages() async {
    try {
      isLoadingAcademicData = true;
      safeEmit(SignUpFormChanged());

      final response = await _authRepository.getAcademicStages();

      response.fold(
        (error) {
          log('Error fetching academic stages: $error');
          isLoadingAcademicData = false;
          safeEmit(SignUpFormChanged());
        },
        (response) {
          if (response.isSuccess && response.data != null) {
            academicStages = response.data!;
            log(
              'Academic stages fetched successfully: ${academicStages.length} items',
            );
          } else {
            log('Failed to fetch academic stages: ${response.message}');
          }
          isLoadingAcademicData = false;
          safeEmit(SignUpFormChanged());
        },
      );
    } catch (e) {
      log('Error fetching academic stages: $e');
      isLoadingAcademicData = false;
      safeEmit(SignUpFormChanged());
    }
  }

  Future<void> fetchAcademicYears() async {
    try {
      isLoadingAcademicData = true;
      safeEmit(SignUpFormChanged());

      final response = await _authRepository.getAcademicYears();

      response.fold(
        (error) {
          log('Error fetching academic years: $error');
          isLoadingAcademicData = false;
          safeEmit(SignUpFormChanged());
        },
        (response) {
          if (response.isSuccess && response.data != null) {
            academicYears = response.data!;
            log(
              'Academic years fetched successfully: ${academicYears.length} items',
            );
          } else {
            log('Failed to fetch academic years: ${response.message}');
          }
          isLoadingAcademicData = false;
          safeEmit(SignUpFormChanged());
        },
      );
    } catch (e) {
      log('Error fetching academic years: $e');
      isLoadingAcademicData = false;
      safeEmit(SignUpFormChanged());
    }
  }

  Future<void> fetchAcademicSections() async {
    try {
      isLoadingAcademicData = true;
      safeEmit(SignUpFormChanged());

      final response = await _authRepository.getAcademicSections();

      response.fold(
        (error) {
          log('Error fetching academic sections: $error');
          isLoadingAcademicData = false;
          safeEmit(SignUpFormChanged());
        },
        (response) {
          if (response.isSuccess && response.data != null) {
            academicSections = response.data!;
            log(
              'Academic sections fetched successfully: ${academicSections.length} items',
            );
          } else {
            log('Failed to fetch academic sections: ${response.message}');
          }
          isLoadingAcademicData = false;
          safeEmit(SignUpFormChanged());
        },
      );
    } catch (e) {
      log('Error fetching academic sections: $e');
      isLoadingAcademicData = false;
      safeEmit(SignUpFormChanged());
    }
  }

  void clearAuthData() {
    loginEmailController.clear();
    loginPasswordController.clear();
    registrationEmailController.clear();
    registerPasswordController.clear();
    userNameController.clear();
    usernameController.clear();
    mobileNumberController.clear();
    confirmPasswordController.clear();
    selectedRole = null;
    selectedYear = null;
    selectedSpecialization = null;
    selectedAcademicStageId = null;
    selectedAcademicYearId = null;
    selectedAcademicSectionId = null;
    isPasswordVisible = false;
    isConfirmPasswordVisible = false;
    selectedEmail = null;
    verificationToken = null;
    userOtp = '';
    isOtpValid = false;
    isPasswordReset = false;
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    userNameController.dispose();
    usernameController.dispose();
    loginEmailController.dispose();
    registrationEmailController.dispose();
    registerPasswordController.dispose();
    mobileNumberController.dispose();
    loginPasswordController.dispose();
    confirmPasswordController.dispose();
    loginEmailFocusNode.dispose();
    loginPasswordFocusNode.dispose();
    registrationEmailFocusNode.dispose();
    registerPasswordFocusNode.dispose();
    userNameFocusNode.dispose();
    usernameFocusNode.dispose();
    mobileNumberFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    return super.close();
  }
}
