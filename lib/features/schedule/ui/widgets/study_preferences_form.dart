import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/study_preferences_model.dart';

class StudyPreferencesForm extends StatefulWidget {
  final Function(StudyPreferences) onSubmit;
  final StudyPreferences? initialPreferences;

  const StudyPreferencesForm({
    super.key,
    required this.onSubmit,
    this.initialPreferences,
  });

  @override
  State<StudyPreferencesForm> createState() => _StudyPreferencesFormState();
}

class _StudyPreferencesFormState extends State<StudyPreferencesForm> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 8;

  // Form data
  bool _studyAllSubjectsDaily = true;
  final List<String> _preferredSubjectsOrder = [];
  String _hardestSubject = '';
  final Map<String, double> _hoursPerSubject = {};
  String _favoriteSubject = '';
  String _timeConsumingSubject = '';
  String _scienceVsLiterature = 'both';
  String _studyStyle = 'diverse';
  String _reviewFrequency = 'daily';
  bool _usesAdditionalResources = false;
  String _highestGradeSubject = '';
  bool _hasTimeManagementDifficulty = false;
  String _needsHelpWith = '';
  String _hardToRememberSubject = '';
  bool _sameStudyMethodForAll = true;
  String _timeTakingSubject = '';
  String _preferredLearningType = 'both';
  bool _reviewsBeforeNewSubject = true;
  bool _prefersWeeklyDistribution = false;
  String _examPreparationMethod = '';
  double _dailyStudyHours = 4.0;
  int _subjectsPerDay = 3;
  String _preferredTimeToStudy = 'evening';
  bool _usesSummaries = true;
  int _reviewFrequencyCount = 2;
  bool _usesAdditionalSources = false;
  bool _takesBreaks = true;
  int _breakDurationMinutes = 15;
  bool _hasFixedSchedule = false;
  bool _feelsStressed = false;
  String _stressReason = '';
  bool _usesTimeManagementApps = false;
  String _studyEnvironment = 'alone';
  int _concentrationLevel = 7;
  bool _reviewsBeforeSleep = false;
  bool _solvesExercises = true;
  final List<String> _distractions = [];
  String _examPreparationStrategy = '';

  static const List<String> _subjects = [
    'الرياضيات',
    'الفيزياء',
    'الكيمياء',
    'الأحياء',
    'اللغة العربية',
    'اللغة الإنجليزية',
    'التاريخ',
    'الجغرافيا',
    'الفلسفة والمنطق',
    'علم النفس والاجتماع',
  ];

  static const List<String> _commonDistractions = [
    'الهاتف المحمول',
    'وسائل التواصل الاجتماعي',
    'الضوضاء',
    'التلفزيون',
    'الأصدقاء',
    'الإنترنت',
    'الألعاب',
    'التفكير في أشياء أخرى',
  ];

  @override
  void initState() {
    super.initState();
    _initializeFromExistingPreferences();
  }

  void _initializeFromExistingPreferences() {
    if (widget.initialPreferences != null) {
      final prefs = widget.initialPreferences!;
      setState(() {
        _studyAllSubjectsDaily = prefs.studyAllSubjectsDaily;
        _preferredSubjectsOrder.addAll(prefs.preferredSubjectsOrder);
        _hardestSubject = prefs.hardestSubject;
        _hoursPerSubject.addAll(prefs.hoursPerSubject);
        _favoriteSubject = prefs.favoriteSubject;
        _timeConsumingSubject = prefs.timeConsumingSubject;
        _scienceVsLiterature = prefs.scienceVsLiterature;
        _studyStyle = prefs.studyStyle;
        _reviewFrequency = prefs.reviewFrequency;
        _usesAdditionalResources = prefs.usesAdditionalResources;
        _highestGradeSubject = prefs.highestGradeSubject;
        _hasTimeManagementDifficulty = prefs.hasTimeManagementDifficulty;
        _needsHelpWith = prefs.needsHelpWith;
        _hardToRememberSubject = prefs.hardToRememberSubject;
        _sameStudyMethodForAll = prefs.sameStudyMethodForAll;
        _timeTakingSubject = prefs.timeTakingSubject;
        _preferredLearningType = prefs.preferredLearningType;
        _reviewsBeforeNewSubject = prefs.reviewsBeforeNewSubject;
        _prefersWeeklyDistribution = prefs.prefersWeeklyDistribution;
        _examPreparationMethod = prefs.examPreparationMethod;
        _dailyStudyHours = prefs.dailyStudyHours;
        _subjectsPerDay = prefs.subjectsPerDay;
        _preferredTimeToStudy = prefs.preferredTimeToStudy;
        _usesSummaries = prefs.usesSummaries;
        _reviewFrequencyCount = prefs.reviewFrequencyCount;
        _usesAdditionalSources = prefs.usesAdditionalSources;
        _takesBreaks = prefs.takesBreaks;
        _breakDurationMinutes = prefs.breakDurationMinutes;
        _hasFixedSchedule = prefs.hasFixedSchedule;
        _feelsStressed = prefs.feelsStressed;
        _stressReason = prefs.stressReason;
        _usesTimeManagementApps = prefs.usesTimeManagementApps;
        _studyEnvironment = prefs.studyEnvironment;
        _concentrationLevel = prefs.concentrationLevel;
        _reviewsBeforeSleep = prefs.reviewsBeforeSleep;
        _solvesExercises = prefs.solvesExercises;
        _distractions.addAll(prefs.distractions);
        _examPreparationStrategy = prefs.examPreparationStrategy;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2F98D7)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'إعداد خطة الدراسة',
          style: TextStyle(
            color: const Color(0xFF2F98D7),
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),

          // Form content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: [
                _buildPage1(), // Basic study habits
                _buildPage2(), // Subject preferences
                _buildPage3(), // Time management
                _buildPage4(), // Study methods
                _buildPage5(), // Challenges and difficulties
                _buildPage6(), // Study environment
                _buildPage7(), // Exam preparation
                _buildPage8(), // Final preferences
              ],
            ),
          ),

          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: EdgeInsets.all(20.w),
      child: Column(
        children: [
          Row(
            children: List.generate(_totalPages, (index) {
              return Expanded(
                child: Container(
                  height: 4.h,
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  decoration: BoxDecoration(
                    color:
                        index <= _currentPage
                            ? const Color(0xFF2F98D7)
                            : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 8.h),
          Text(
            'خطوة ${_currentPage + 1} من $_totalPages',
            style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildPage1() {
    return _buildPageWrapper(
      title: 'عادات الدراسة الأساسية',
      subtitle: 'دعنا نتعرف على طريقة دراستك',
      children: [
        _buildQuestionCard(
          question: 'هل تذاكر جميع المواد في اليوم الواحد؟',
          child: _buildBooleanSelector(
            value: _studyAllSubjectsDaily,
            onChanged:
                (value) => setState(() => _studyAllSubjectsDaily = value),
            trueText: 'نعم، أذاكر كل المواد',
            falseText: 'لا، أركز على مواد معينة',
          ),
        ),

        _buildQuestionCard(
          question: 'كم ساعة تذاكر يومياً؟',
          child: _buildSlider(
            value: _dailyStudyHours,
            min: 1.0,
            max: 12.0,
            divisions: 11,
            label: '${_dailyStudyHours.round()} ساعات',
            onChanged: (value) => setState(() => _dailyStudyHours = value),
          ),
        ),

        _buildQuestionCard(
          question: 'كم مادة تذاكر في اليوم الواحد؟',
          child: _buildNumberSelector(
            value: _subjectsPerDay,
            min: 1,
            max: 6,
            onChanged: (value) => setState(() => _subjectsPerDay = value),
          ),
        ),
      ],
    );
  }

  Widget _buildPage2() {
    return _buildPageWrapper(
      title: 'تفضيلات المواد',
      subtitle: 'أخبرنا عن المواد التي تدرسها',
      children: [
        _buildQuestionCard(
          question: 'ما هي مادتك المفضلة؟',
          child: _buildSubjectDropdown(
            value: _favoriteSubject,
            hint: 'اختر المادة المفضلة',
            onChanged:
                (value) => setState(() => _favoriteSubject = value ?? ''),
          ),
        ),

        _buildQuestionCard(
          question: 'ما هي أصعب مادة بالنسبة لك؟',
          child: _buildSubjectDropdown(
            value: _hardestSubject,
            hint: 'اختر أصعب مادة',
            onChanged: (value) => setState(() => _hardestSubject = value ?? ''),
          ),
        ),

        _buildQuestionCard(
          question: 'ما المادة التي تحصل فيها على أعلى الدرجات؟',
          child: _buildSubjectDropdown(
            value: _highestGradeSubject,
            hint: 'اختر المادة',
            onChanged:
                (value) => setState(() => _highestGradeSubject = value ?? ''),
          ),
        ),

        _buildQuestionCard(
          question: 'هل تفضل المواد العلمية أم الأدبية؟',
          child: _buildMultipleChoice(
            value: _scienceVsLiterature,
            options: const {
              'science': 'المواد العلمية',
              'literature': 'المواد الأدبية',
              'both': 'كلاهما بنفس الدرجة',
            },
            onChanged: (value) => setState(() => _scienceVsLiterature = value),
          ),
        ),
      ],
    );
  }

  Widget _buildPage3() {
    return _buildPageWrapper(
      title: 'إدارة الوقت',
      subtitle: 'كيف تنظم وقت دراستك؟',
      children: [
        _buildQuestionCard(
          question: 'متى تفضل المذاكرة؟',
          child: _buildMultipleChoice(
            value: _preferredTimeToStudy,
            options: const {
              'morning': 'في الصباح الباكر',
              'afternoon': 'بعد الظهر',
              'evening': 'في المساء',
            },
            onChanged: (value) => setState(() => _preferredTimeToStudy = value),
          ),
        ),

        _buildQuestionCard(
          question: 'هل لديك جدول ثابت للمذاكرة؟',
          child: _buildBooleanSelector(
            value: _hasFixedSchedule,
            onChanged: (value) => setState(() => _hasFixedSchedule = value),
            trueText: 'نعم، لدي جدول ثابت',
            falseText: 'لا، أذاكر بشكل عشوائي',
          ),
        ),

        _buildQuestionCard(
          question: 'هل تأخذ فترات استراحة أثناء المذاكرة؟',
          child: _buildBooleanSelector(
            value: _takesBreaks,
            onChanged: (value) => setState(() => _takesBreaks = value),
            trueText: 'نعم، آخذ استراحات',
            falseText: 'لا، أذاكر بشكل متواصل',
          ),
        ),

        if (_takesBreaks)
          _buildQuestionCard(
            question: 'كم تستغرق فترة الاستراحة؟',
            child: _buildSlider(
              value: _breakDurationMinutes.toDouble(),
              min: 5.0,
              max: 60.0,
              divisions: 11,
              label: '$_breakDurationMinutes دقيقة',
              onChanged:
                  (value) =>
                      setState(() => _breakDurationMinutes = value.round()),
            ),
          ),

        _buildQuestionCard(
          question: 'هل تواجه صعوبة في تنظيم وقتك؟',
          child: _buildBooleanSelector(
            value: _hasTimeManagementDifficulty,
            onChanged:
                (value) => setState(() => _hasTimeManagementDifficulty = value),
            trueText: 'نعم، أواجه صعوبة',
            falseText: 'لا، أنظم وقتي جيداً',
          ),
        ),
      ],
    );
  }

  Widget _buildPage4() {
    return _buildPageWrapper(
      title: 'طرق الدراسة',
      subtitle: 'كيف تفضل أن تدرس؟',
      children: [
        _buildQuestionCard(
          question: 'هل تفضل دراسة مادة واحدة بشكل مكثف أم التنويع؟',
          child: _buildMultipleChoice(
            value: _studyStyle,
            options: const {
              'intensive': 'التركيز المكثف على مادة واحدة',
              'diverse': 'التنويع بين المواد',
            },
            onChanged: (value) => setState(() => _studyStyle = value),
          ),
        ),

        _buildQuestionCard(
          question: 'هل تعتمد على تلخيص الدروس؟',
          child: _buildBooleanSelector(
            value: _usesSummaries,
            onChanged: (value) => setState(() => _usesSummaries = value),
            trueText: 'نعم، أعتمد على التلخيص',
            falseText: 'لا، أقرأ الكتاب كاملاً',
          ),
        ),

        _buildQuestionCard(
          question: 'هل تفضل الحفظ أم الفهم؟',
          child: _buildMultipleChoice(
            value: _preferredLearningType,
            options: const {
              'memorization': 'أفضل الحفظ',
              'understanding': 'أفضل الفهم',
              'both': 'كلاهما مهم',
            },
            onChanged:
                (value) => setState(() => _preferredLearningType = value),
          ),
        ),

        _buildQuestionCard(
          question: 'هل تذاكر بمفردك أم مع مجموعة؟',
          child: _buildMultipleChoice(
            value: _studyEnvironment,
            options: const {'alone': 'بمفردي', 'group': 'مع مجموعة'},
            onChanged: (value) => setState(() => _studyEnvironment = value),
          ),
        ),
      ],
    );
  }

  Widget _buildPage5() {
    return _buildPageWrapper(
      title: 'التحديات والصعوبات',
      subtitle: 'ما هي أكبر التحديات التي تواجهها؟',
      children: [
        _buildQuestionCard(
          question: 'ما المادة التي تأخذ منك وقتاً أطول؟',
          child: _buildSubjectDropdown(
            value: _timeConsumingSubject,
            hint: 'اختر المادة',
            onChanged:
                (value) => setState(() => _timeConsumingSubject = value ?? ''),
          ),
        ),

        _buildQuestionCard(
          question: 'ما المادة الأصعب في التذكر؟',
          child: _buildSubjectDropdown(
            value: _hardToRememberSubject,
            hint: 'اختر المادة',
            onChanged:
                (value) => setState(() => _hardToRememberSubject = value ?? ''),
          ),
        ),

        _buildQuestionCard(
          question: 'هل تشعر بالإجهاد أثناء المذاكرة؟',
          child: _buildBooleanSelector(
            value: _feelsStressed,
            onChanged: (value) => setState(() => _feelsStressed = value),
            trueText: 'نعم، أشعر بالإجهاد',
            falseText: 'لا، أشعر بالراحة',
          ),
        ),

        _buildQuestionCard(
          question: 'ما أكثر الأشياء التي تشتت انتباهك؟',
          child: _buildDistractionSelector(),
        ),
      ],
    );
  }

  Widget _buildPage6() {
    return _buildPageWrapper(
      title: 'بيئة الدراسة',
      subtitle: 'حدد مستوى تركيزك وتفضيلاتك',
      children: [
        _buildQuestionCard(
          question: 'كيف تقيم مستوى تركيزك؟ (من 1 إلى 10)',
          child: _buildRatingSelector(
            value: _concentrationLevel,
            onChanged: (value) => setState(() => _concentrationLevel = value),
          ),
        ),

        _buildQuestionCard(
          question: 'هل تستخدم تطبيقات تنظيم الوقت؟',
          child: _buildBooleanSelector(
            value: _usesTimeManagementApps,
            onChanged:
                (value) => setState(() => _usesTimeManagementApps = value),
            trueText: 'نعم، أستخدم تطبيقات',
            falseText: 'لا، لا أستخدم تطبيقات',
          ),
        ),

        _buildQuestionCard(
          question: 'هل تراجع قبل النوم؟',
          child: _buildBooleanSelector(
            value: _reviewsBeforeSleep,
            onChanged: (value) => setState(() => _reviewsBeforeSleep = value),
            trueText: 'نعم، أراجع قبل النوم',
            falseText: 'لا، لا أراجع قبل النوم',
          ),
        ),

        _buildQuestionCard(
          question: 'هل تستخدم مصادر إضافية للمذاكرة؟',
          child: _buildBooleanSelector(
            value: _usesAdditionalSources,
            onChanged:
                (value) => setState(() => _usesAdditionalSources = value),
            trueText: 'نعم، أستخدم مصادر إضافية',
            falseText: 'لا، أكتفي بالكتب المدرسية',
          ),
        ),
      ],
    );
  }

  Widget _buildPage7() {
    return _buildPageWrapper(
      title: 'الاستعداد للامتحانات',
      subtitle: 'كيف تحضر للامتحانات؟',
      children: [
        _buildQuestionCard(
          question: 'كم مرة تراجع المادة قبل الامتحان؟',
          child: _buildSlider(
            value: _reviewFrequencyCount.toDouble(),
            min: 1.0,
            max: 10.0,
            divisions: 9,
            label: '$_reviewFrequencyCount مرات',
            onChanged:
                (value) =>
                    setState(() => _reviewFrequencyCount = value.round()),
          ),
        ),

        _buildQuestionCard(
          question: 'هل تحل تدريبات أثناء المذاكرة؟',
          child: _buildBooleanSelector(
            value: _solvesExercises,
            onChanged: (value) => setState(() => _solvesExercises = value),
            trueText: 'نعم، أحل تدريبات',
            falseText: 'لا، أكتفي بالقراءة',
          ),
        ),

        _buildQuestionCard(
          question: 'هل تراجع يومياً أم أسبوعياً؟',
          child: _buildMultipleChoice(
            value: _reviewFrequency,
            options: const {
              'daily': 'مراجعة يومية',
              'weekly': 'مراجعة أسبوعية',
            },
            onChanged: (value) => setState(() => _reviewFrequency = value),
          ),
        ),
      ],
    );
  }

  Widget _buildPage8() {
    return _buildPageWrapper(
      title: 'اللمسات الأخيرة',
      subtitle: 'تفضيلات إضافية لتحسين خطتك',
      children: [
        _buildQuestionCard(
          question: 'هل تفضل توزيع المواد على أيام الأسبوع؟',
          child: _buildBooleanSelector(
            value: _prefersWeeklyDistribution,
            onChanged:
                (value) => setState(() => _prefersWeeklyDistribution = value),
            trueText: 'نعم، توزيع أسبوعي',
            falseText: 'لا، نفس المواد يومياً',
          ),
        ),

        _buildQuestionCard(
          question: 'هل تراجع قبل الانتقال لمادة جديدة؟',
          child: _buildBooleanSelector(
            value: _reviewsBeforeNewSubject,
            onChanged:
                (value) => setState(() => _reviewsBeforeNewSubject = value),
            trueText: 'نعم، أراجع أولاً',
            falseText: 'لا، أنتقل مباشرة',
          ),
        ),

        if (_needsHelpWith.isEmpty)
          _buildQuestionCard(
            question: 'أي مادة تحتاج مساعدة إضافية فيها؟',
            child: _buildSubjectDropdown(
              value: _needsHelpWith,
              hint: 'اختر المادة (اختياري)',
              onChanged:
                  (value) => setState(() => _needsHelpWith = value ?? ''),
            ),
          ),

        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2F98D7), Color(0xFF166EA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: [
              Icon(Icons.psychology, color: Colors.white, size: 48.sp),
              SizedBox(height: 12.h),
              Text(
                'جاهز لإنشاء خطتك الشخصية!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'سيقوم الذكاء الاصطناعي بتحليل إجاباتك وإنشاء خطة دراسية مخصصة لك',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPageWrapper({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2F98D7),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 24.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildQuestionCard({required String question, required Widget child}) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
            ),
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }


  Widget _buildBooleanSelector({
    required bool value,
    required Function(bool) onChanged,
    required String trueText,
    required String falseText,
  }) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(true),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: value ? const Color(0xFF2F98D7) : Colors.grey[100],
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: value ? const Color(0xFF2F98D7) : Colors.grey[300]!,
                ),
              ),
              child: Text(
                trueText,
                style: TextStyle(
                  color: value ? Colors.white : Colors.grey[600],
                  fontSize: 14.sp,
                  fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(false),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: !value ? const Color(0xFF2F98D7) : Colors.grey[100],
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: !value ? const Color(0xFF2F98D7) : Colors.grey[300]!,
                ),
              ),
              child: Text(
                falseText,
                style: TextStyle(
                  color: !value ? Colors.white : Colors.grey[600],
                  fontSize: 14.sp,
                  fontWeight: !value ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultipleChoice({
    required String value,
    required Map<String, String> options,
    required Function(String) onChanged,
  }) {
    return Column(
      children:
          options.entries.map((entry) {
            final isSelected = value == entry.key;
            return GestureDetector(
              onTap: () => onChanged(entry.key),
              child: Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFF2F98D7) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color:
                        isSelected
                            ? const Color(0xFF2F98D7)
                            : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isSelected ? Colors.white : Colors.grey[600],
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[600],
                          fontSize: 14.sp,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildSubjectDropdown({
    required String value,
    required String hint,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value.isEmpty ? null : value,
          hint: Text(hint),
          isExpanded: true,
          items:
              _subjects.map((subject) {
                return DropdownMenuItem(value: subject, child: Text(subject));
              }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSlider({
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required Function(double) onChanged,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2F98D7),
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: const Color(0xFF2F98D7),
          inactiveColor: Colors.grey[300],
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildNumberSelector({
    required int value,
    required int min,
    required int max,
    required Function(int) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(max - min + 1, (index) {
        final number = min + index;
        final isSelected = value == number;
        return GestureDetector(
          onTap: () => onChanged(number),
          child: Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2F98D7) : Colors.grey[100],
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected ? const Color(0xFF2F98D7) : Colors.grey[300]!,
              ),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRatingSelector({
    required int value,
    required Function(int) onChanged,
  }) {
    return Column(
      children: [
        Text(
          '$value/10',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2F98D7),
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(10, (index) {
            final rating = index + 1;
            final isSelected = value == rating;
            return GestureDetector(
              onTap: () => onChanged(rating),
              child: Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFF2F98D7) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(15.r),
                  border: Border.all(
                    color:
                        isSelected
                            ? const Color(0xFF2F98D7)
                            : Colors.grey[300]!,
                  ),
                ),
                child: Center(
                  child: Text(
                    rating.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[600],
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ضعيف',
              style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
            ),
            Text(
              'ممتاز',
              style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDistractionSelector() {
    return Column(
      children:
          _commonDistractions.map((distraction) {
            final isSelected = _distractions.contains(distraction);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _distractions.remove(distraction);
                  } else {
                    _distractions.add(distraction);
                  }
                });
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFF2F98D7) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color:
                        isSelected
                            ? const Color(0xFF2F98D7)
                            : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: isSelected ? Colors.white : Colors.grey[600],
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        distraction,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[600],
                          fontSize: 14.sp,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: ElevatedButton(
                onPressed: _previousPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.grey[600],
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back, size: 18.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'السابق',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (_currentPage > 0) SizedBox(width: 16.w),

          Expanded(
            flex: _currentPage == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed:
                  _currentPage == _totalPages - 1 ? _submitForm : _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F98D7),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_currentPage == _totalPages - 1) ...[
                    Icon(Icons.psychology, size: 18.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'إنشاء الخطة',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ] else ...[
                    Text(
                      'التالي',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.arrow_forward, size: 18.sp),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitForm() {
    final preferences = StudyPreferences(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      studyAllSubjectsDaily: _studyAllSubjectsDaily,
      preferredSubjectsOrder: _preferredSubjectsOrder,
      hardestSubject: _hardestSubject,
      hoursPerSubject: _hoursPerSubject,
      favoriteSubject: _favoriteSubject,
      timeConsumingSubject: _timeConsumingSubject,
      scienceVsLiterature: _scienceVsLiterature,
      studyStyle: _studyStyle,
      reviewFrequency: _reviewFrequency,
      usesAdditionalResources: _usesAdditionalResources,
      highestGradeSubject: _highestGradeSubject,
      hasTimeManagementDifficulty: _hasTimeManagementDifficulty,
      needsHelpWith: _needsHelpWith,
      hardToRememberSubject: _hardToRememberSubject,
      sameStudyMethodForAll: _sameStudyMethodForAll,
      timeTakingSubject: _timeTakingSubject,
      preferredLearningType: _preferredLearningType,
      reviewsBeforeNewSubject: _reviewsBeforeNewSubject,
      prefersWeeklyDistribution: _prefersWeeklyDistribution,
      examPreparationMethod: _examPreparationMethod,
      dailyStudyHours: _dailyStudyHours,
      subjectsPerDay: _subjectsPerDay,
      preferredTimeToStudy: _preferredTimeToStudy,
      usesSummaries: _usesSummaries,
      reviewFrequencyCount: _reviewFrequencyCount,
      usesAdditionalSources: _usesAdditionalSources,
      takesBreaks: _takesBreaks,
      breakDurationMinutes: _breakDurationMinutes,
      hasFixedSchedule: _hasFixedSchedule,
      feelsStressed: _feelsStressed,
      stressReason: _stressReason,
      usesTimeManagementApps: _usesTimeManagementApps,
      studyEnvironment: _studyEnvironment,
      concentrationLevel: _concentrationLevel,
      reviewsBeforeSleep: _reviewsBeforeSleep,
      solvesExercises: _solvesExercises,
      distractions: _distractions,
      examPreparationStrategy: _examPreparationStrategy,
    );

    widget.onSubmit(preferences);
  }
}
