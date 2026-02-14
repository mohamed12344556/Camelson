// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `EOL`
  String get app_title {
    return Intl.message('EOL', name: 'app_title', desc: '', args: []);
  }

  /// `Apple sign in`
  String get apple_sign_in {
    return Intl.message(
      'Apple sign in',
      name: 'apple_sign_in',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get button_continue {
    return Intl.message(
      'Continue',
      name: 'button_continue',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get confirm_password_label {
    return Intl.message(
      'Confirm Password',
      name: 'confirm_password_label',
      desc: '',
      args: [],
    );
  }

  /// `Or continue with`
  String get continue_with {
    return Intl.message(
      'Or continue with',
      name: 'continue_with',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email_label {
    return Intl.message('Email', name: 'email_label', desc: '', args: []);
  }

  /// `student@student.eol.edu`
  String get email_placeholder_student {
    return Intl.message(
      'student@student.eol.edu',
      name: 'email_placeholder_student',
      desc: '',
      args: [],
    );
  }

  /// `teacher@teacher.eol.edu`
  String get email_placeholder_teacher {
    return Intl.message(
      'teacher@teacher.eol.edu',
      name: 'email_placeholder_teacher',
      desc: '',
      args: [],
    );
  }

  /// `Email is required`
  String get email_required {
    return Intl.message(
      'Email is required',
      name: 'email_required',
      desc: '',
      args: [],
    );
  }

  /// `This field is required`
  String get field_required {
    return Intl.message(
      'This field is required',
      name: 'field_required',
      desc: '',
      args: [],
    );
  }

  /// `Forgot Password`
  String get forget_pass_title_page {
    return Intl.message(
      'Forgot Password',
      name: 'forget_pass_title_page',
      desc: '',
      args: [],
    );
  }

  /// `Forgot Password?`
  String get forgot_password {
    return Intl.message(
      'Forgot Password?',
      name: 'forgot_password',
      desc: '',
      args: [],
    );
  }

  /// `Full Name`
  String get full_name_label {
    return Intl.message(
      'Full Name',
      name: 'full_name_label',
      desc: '',
      args: [],
    );
  }

  /// `Google sign in`
  String get google_sign_in {
    return Intl.message(
      'Google sign in',
      name: 'google_sign_in',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Select which contact details should we use to\nReset Your Password`
  String get instruction_text {
    return Intl.message(
      'Select which contact details should we use to\nReset Your Password',
      name: 'instruction_text',
      desc: '',
      args: [],
    );
  }

  /// `Invalid email format`
  String get invalid_email_format {
    return Intl.message(
      'Invalid email format',
      name: 'invalid_email_format',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login_button {
    return Intl.message('Login', name: 'login_button', desc: '', args: []);
  }

  /// `Via Email`
  String get option_via_email {
    return Intl.message(
      'Via Email',
      name: 'option_via_email',
      desc: '',
      args: [],
    );
  }

  /// `Via SMS`
  String get option_via_sms {
    return Intl.message('Via SMS', name: 'option_via_sms', desc: '', args: []);
  }

  /// `Enter the 4-digit OTP code that has been sent via SMS\nto complete your account registration`
  String get otp_instruction {
    return Intl.message(
      'Enter the 4-digit OTP code that has been sent via SMS\nto complete your account registration',
      name: 'otp_instruction',
      desc: '',
      args: [],
    );
  }

  /// `OTP Authenticate`
  String get otp_page_title {
    return Intl.message(
      'OTP Authenticate',
      name: 'otp_page_title',
      desc: '',
      args: [],
    );
  }

  /// `Lowercase`
  String get password_criteria_lowercase {
    return Intl.message(
      'Lowercase',
      name: 'password_criteria_lowercase',
      desc: '',
      args: [],
    );
  }

  /// `8+ Characters`
  String get password_criteria_min_length {
    return Intl.message(
      '8+ Characters',
      name: 'password_criteria_min_length',
      desc: '',
      args: [],
    );
  }

  /// `Number`
  String get password_criteria_number {
    return Intl.message(
      'Number',
      name: 'password_criteria_number',
      desc: '',
      args: [],
    );
  }

  /// `Special Char`
  String get password_criteria_special_char {
    return Intl.message(
      'Special Char',
      name: 'password_criteria_special_char',
      desc: '',
      args: [],
    );
  }

  /// `Uppercase`
  String get password_criteria_uppercase {
    return Intl.message(
      'Uppercase',
      name: 'password_criteria_uppercase',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password_label {
    return Intl.message('Password', name: 'password_label', desc: '', args: []);
  }

  /// `Enter new password`
  String get password_label_reset_page {
    return Intl.message(
      'Enter new password',
      name: 'password_label_reset_page',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 8 characters`
  String get password_min_length {
    return Intl.message(
      'Password must be at least 8 characters',
      name: 'password_min_length',
      desc: '',
      args: [],
    );
  }

  /// `at least 8 characters`
  String get password_min_length_reset {
    return Intl.message(
      'at least 8 characters',
      name: 'password_min_length_reset',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password_placeholder {
    return Intl.message(
      'Password',
      name: 'password_placeholder',
      desc: '',
      args: [],
    );
  }

  /// `Password is required`
  String get password_required {
    return Intl.message(
      'Password is required',
      name: 'password_required',
      desc: '',
      args: [],
    );
  }

  /// `Please meet all password requirements`
  String get password_requirements {
    return Intl.message(
      'Please meet all password requirements',
      name: 'password_requirements',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match`
  String get passwords_dont_match {
    return Intl.message(
      'Passwords do not match',
      name: 'passwords_dont_match',
      desc: '',
      args: [],
    );
  }

  /// `Phone Number`
  String get phone_number_label {
    return Intl.message(
      'Phone Number',
      name: 'phone_number_label',
      desc: '',
      args: [],
    );
  }

  /// `Resend`
  String get resend_button {
    return Intl.message('Resend', name: 'resend_button', desc: '', args: []);
  }

  /// `Haven't got the confirmation code yet?`
  String get resend_instruction {
    return Intl.message(
      'Haven\'t got the confirmation code yet?',
      name: 'resend_instruction',
      desc: '',
      args: [],
    );
  }

  /// `Reset Password`
  String get reset_pass_title_page {
    return Intl.message(
      'Reset Password',
      name: 'reset_pass_title_page',
      desc: '',
      args: [],
    );
  }

  /// `Reset Password`
  String get reset_password_button {
    return Intl.message(
      'Reset Password',
      name: 'reset_password_button',
      desc: '',
      args: [],
    );
  }

  /// `Role`
  String get role_hint {
    return Intl.message('Role', name: 'role_hint', desc: '', args: []);
  }

  /// `Student`
  String get role_student {
    return Intl.message('Student', name: 'role_student', desc: '', args: []);
  }

  /// `Teacher`
  String get role_teacher {
    return Intl.message('Teacher', name: 'role_teacher', desc: '', args: []);
  }

  /// `Student\nTeacher`
  String get roles {
    return Intl.message('Student\nTeacher', name: 'roles', desc: '', args: []);
  }

  /// `Reset your password`
  String get screen_title {
    return Intl.message(
      'Reset your password',
      name: 'screen_title',
      desc: '',
      args: [],
    );
  }

  /// `Please select an option`
  String get select_option {
    return Intl.message(
      'Please select an option',
      name: 'select_option',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get sign_in_button {
    return Intl.message('Sign In', name: 'sign_in_button', desc: '', args: []);
  }

  /// `Don't have an account? `
  String get sign_up_prompt {
    return Intl.message(
      'Don\'t have an account? ',
      name: 'sign_up_prompt',
      desc: '',
      args: [],
    );
  }

  /// `Already have an Account? `
  String get signin_prompt {
    return Intl.message(
      'Already have an Account? ',
      name: 'signin_prompt',
      desc: '',
      args: [],
    );
  }

  /// `Sign up`
  String get signup_button {
    return Intl.message('Sign up', name: 'signup_button', desc: '', args: []);
  }

  /// `Specialization`
  String get specialization_hint {
    return Intl.message(
      'Specialization',
      name: 'specialization_hint',
      desc: '',
      args: [],
    );
  }

  /// `Scientific\nScience (Mathematics)\nLiterature`
  String get specializations {
    return Intl.message(
      'Scientific\nScience (Mathematics)\nLiterature',
      name: 'specializations',
      desc: '',
      args: [],
    );
  }

  /// `Please use a valid student email (@student.eol.edu)`
  String get student_email_required {
    return Intl.message(
      'Please use a valid student email (@student.eol.edu)',
      name: 'student_email_required',
      desc: '',
      args: [],
    );
  }

  /// `Please use a valid teacher email (@teacher.eol.edu)`
  String get teacher_email_required {
    return Intl.message(
      'Please use a valid teacher email (@teacher.eol.edu)',
      name: 'teacher_email_required',
      desc: '',
      args: [],
    );
  }

  /// `Here's a tip: Use a combination of\nNumbers, Uppercase, Lowercase and\nSpecial characters`
  String get tip_text {
    return Intl.message(
      'Here\'s a tip: Use a combination of\nNumbers, Uppercase, Lowercase and\nSpecial characters',
      name: 'tip_text',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid email address`
  String get valid_email {
    return Intl.message(
      'Please enter a valid email address',
      name: 'valid_email',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your full name (at least 2 names)`
  String get valid_full_name {
    return Intl.message(
      'Please enter your full name (at least 2 names)',
      name: 'valid_full_name',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid phone number`
  String get valid_phone_number {
    return Intl.message(
      'Please enter a valid phone number',
      name: 'valid_phone_number',
      desc: '',
      args: [],
    );
  }

  /// `Verification code has been sent to`
  String get verification_code_has_been_sent_to {
    return Intl.message(
      'Verification code has been sent to',
      name: 'verification_code_has_been_sent_to',
      desc: '',
      args: [],
    );
  }

  /// `Verify`
  String get verify_button {
    return Intl.message('Verify', name: 'verify_button', desc: '', args: []);
  }

  /// `Welcome. Let's start by creating your\naccount or sign in if you already have one`
  String get welcome_messagewelcome_message {
    return Intl.message(
      'Welcome. Let\'s start by creating your\naccount or sign in if you already have one',
      name: 'welcome_messagewelcome_message',
      desc: '',
      args: [],
    );
  }

  /// `Year`
  String get year_hint {
    return Intl.message('Year', name: 'year_hint', desc: '', args: []);
  }

  /// `First Year\nSecond Year\nThird Year`
  String get years {
    return Intl.message(
      'First Year\nSecond Year\nThird Year',
      name: 'years',
      desc: '',
      args: [],
    );
  }

  /// `Language Settings`
  String get language_settings {
    return Intl.message(
      'Language Settings',
      name: 'language_settings',
      desc: '',
      args: [],
    );
  }

  /// `Search languages...`
  String get search_languages {
    return Intl.message(
      'Search languages...',
      name: 'search_languages',
      desc: '',
      args: [],
    );
  }

  /// `Current Language`
  String get current_language {
    return Intl.message(
      'Current Language',
      name: 'current_language',
      desc: '',
      args: [],
    );
  }

  /// `Apply Changes`
  String get apply_changes {
    return Intl.message(
      'Apply Changes',
      name: 'apply_changes',
      desc: '',
      args: [],
    );
  }

  /// `Language changed successfully`
  String get language_changed {
    return Intl.message(
      'Language changed successfully',
      name: 'language_changed',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
