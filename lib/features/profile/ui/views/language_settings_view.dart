// Navigation extensions moved to core/utils/extensions.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/languages.dart';
import '../../../../core/core.dart';
import '../../../../core/languages/language_cubit.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_search_bar.dart';
import '../../../../generated/l10n.dart';

class LanguageSettingsView extends StatefulWidget {
  const LanguageSettingsView({super.key});

  @override
  State<LanguageSettingsView> createState() => _LanguageSettingsViewState();
}

class _LanguageSettingsViewState extends State<LanguageSettingsView> {
  String _selectedLanguage = 'en';
  List<Map<String, dynamic>> _filteredLanguages = [];
  final TextEditingController _searchController = TextEditingController();

  // قائمة اللغات المتاحة (كودات اللغات)
  final List<String> _languageCodes = [
    'en',
    'ar',
    'fr',
    'es',
    'pt',
    'ru',
    'zh',
    'ja',
    'de',
    'it',
    'ko',
    'vi',
    'tr',
    'pl',
    'id',
  ];

  // تحديث قائمة اللغات باستخدام الكلاس Languages
  List<Map<String, dynamic>> get _languages =>
      _languageCodes
          .map(
            (code) => {
              'name': Languages.getLanguageName(code),
              'nativeName': Languages.getLanguageNativeName(code),
              'flag': Languages.getLanguageFlag(code),
              'code': code,
            },
          )
          .toList();

  @override
  void initState() {
    super.initState();
    _filteredLanguages = _languages;

    // الحصول على اللغة الحالية
    final languageCubit = context.read<LanguageCubit>();
    _selectedLanguage = languageCubit.getCurrentLanguageCode();

    // إخفاء شريط التنقل
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.setNavBarVisible(false);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterLanguages(String query) {
    setState(() {
      _filteredLanguages =
          _languages.where((language) {
            return language['name'].toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                language['nativeName'].toLowerCase().contains(
                  query.toLowerCase(),
                );
          }).toList();
    });
  }

  void _onClearPressed() {
    _searchController.clear();
    _filterLanguages('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: CustomAppBar(
        title: S.of(context).language_settings ?? 'Language Settings',
        onBackPressed: () {
          context.setNavBarVisible(true);
          Navigator.pop(context);
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 18.h),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40.r),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 20.h),

                    // Search Bar using CustomSearchBar
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25.w),
                      child: CustomSearchBar(
                        isPaddingZero: true,
                        searchController: _searchController,
                        onChanged: _filterLanguages,
                        onClearPressed: _onClearPressed,
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Current Language Info
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 25.w),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F8FF),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: const Color(0xFF0961F5).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0961F5),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              Icons.language,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  S.of(context).current_language ??
                                      'Current Language',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  Languages.getLanguageName(_selectedLanguage),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0961F5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Languages List
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 25.w),
                        itemCount: _filteredLanguages.length,
                        itemBuilder: (context, index) {
                          return _buildLanguageTile(_filteredLanguages[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Apply Button
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
            child: ElevatedButton(
              onPressed: () {
                // تطبيق تغيير اللغة
                context.read<LanguageCubit>().changeLanguage(_selectedLanguage);

                // إظهار رسالة نجاح
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      S.of(context).language_changed ??
                          'Language changed successfully',
                    ),
                    backgroundColor: const Color(0xFF0961F5),
                  ),
                );

                // العودة للصفحة السابقة
                context.setNavBarVisible(true);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0961F5),
                minimumSize: Size(double.infinity, 55.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              child: Text(
                S.of(context).apply_changes ?? 'Apply Changes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(Map<String, dynamic> language) {
    final isSelected = _selectedLanguage == language['code'];

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? const Color(0xFF0961F5) : Colors.grey[300]!,
          width: isSelected ? 2.w : 1.w,
        ),
        borderRadius: BorderRadius.circular(16.r),
        color: isSelected ? const Color(0xFFF0F8FF) : Colors.grey[50],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          width: 50.w,
          height: 50.h,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Text(language['flag'], style: TextStyle(fontSize: 24.sp)),
          ),
        ),
        title: Text(
          language['name'],
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          language['nativeName'],
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
        ),
        trailing: Radio<String>(
          value: language['code'],
          groupValue: _selectedLanguage,
          onChanged: (String? value) {
            if (value != null) {
              setState(() {
                _selectedLanguage = value;
              });
            }
          },
          activeColor: const Color(0xFF0961F5),
        ),
        onTap: () {
          setState(() {
            _selectedLanguage = language['code'];
          });
        },
      ),
    );
  }
}
