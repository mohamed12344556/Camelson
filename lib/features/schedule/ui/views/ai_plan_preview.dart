import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/event_model.dart';
import '../../data/models/study_preferences_model.dart';
import '../../data/services/ai_study_service.dart';

class AIPlanPreviewView extends StatefulWidget {
  final StudyPreferences? preferences;
  final Function(List<Event>)? onAcceptPlan;

  const AIPlanPreviewView({super.key, this.preferences, this.onAcceptPlan});

  @override
  State<AIPlanPreviewView> createState() => _AIPlanPreviewViewState();
}

class _AIPlanPreviewViewState extends State<AIPlanPreviewView>
    with TickerProviderStateMixin {
  late AnimationController _loadingController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<Event>? _generatedPlan;
  Map<String, dynamic>? _recommendations;
  bool _isLoading = true;
  bool _showRecommendations = false;
  String? _errorMessage;
  int _currentLoadingStep = 0;

  final List<String> _loadingSteps = [
    'تحليل عادات الدراسة الشخصية',
    'تحديد نقاط القوة والضعف',
    'إنشاء جدول زمني مخصص',
    'تحسين التوصيات الذكية',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateAIPlan();
  }

  void _initializeAnimations() {
    _loadingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _startLoadingAnimation();
  }

  void _startLoadingAnimation() {
    _loadingController.addListener(() {
      final newStep = (_loadingController.value * _loadingSteps.length).floor();
      if (newStep != _currentLoadingStep && newStep < _loadingSteps.length) {
        setState(() {
          _currentLoadingStep = newStep;
        });
      }
    });
    _loadingController.forward();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _generateAIPlan() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Simulate AI processing time
      await Future.delayed(const Duration(seconds: 4));

      final plan = await AIStudyService.generateStudyPlan(widget.preferences!);
      final recommendations = AIStudyService.generateStudyRecommendations(
        widget.preferences!,
      );

      if (mounted) {
        setState(() {
          _generatedPlan = plan;
          _recommendations = recommendations;
          _isLoading = false;
        });

        _loadingController.stop();
        await _fadeController.forward();
        await _slideController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'حدث خطأ أثناء إنشاء الخطة الدراسية';
        });
        _loadingController.stop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child:
                  _isLoading
                      ? _buildLoadingView()
                      : _errorMessage != null
                      ? _buildErrorView()
                      : _buildPlanView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: const Color(0xFF2F98D7),
              size: 20.sp,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'خطتك الدراسية المقترحة',
              style: TextStyle(
                color: const Color(0xFF2F98D7),
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 48.w), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // AI Brain Animation
            _buildAIBrainAnimation(),
            SizedBox(height: 40.h),

            // Loading Title
            Text(
              'جاري تحليل تفضيلاتك الدراسية...',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2F98D7),
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 16.h),

            Text(
              'الذكاء الاصطناعي يقوم بإنشاء خطة مخصصة تماماً لأسلوب دراستك',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 48.h),

            // Loading Steps
            _buildAnimatedLoadingSteps(),

            SizedBox(height: 32.h),

            // Progress Indicator
            _buildProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildAIBrainAnimation() {
    return AnimatedBuilder(
      animation: _loadingController,
      builder: (context, child) {
        return Container(
          width: 120.w,
          height: 120.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2F98D7),
                const Color(0xFF166EA2),
                const Color(0xFF2F98D7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, _loadingController.value, 1.0],
            ),
            borderRadius: BorderRadius.circular(60.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2F98D7).withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Transform.scale(
            scale: 1.0 + (_loadingController.value * 0.1),
            child: Icon(Icons.psychology, color: Colors.white, size: 60.sp),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedLoadingSteps() {
    return Column(
      children:
          _loadingSteps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isActive = _currentLoadingStep == index;
            final isCompleted = _currentLoadingStep > index;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(vertical: 8.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color:
                    isActive
                        ? const Color(0xFF2F98D7).withOpacity(0.1)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color:
                      isActive ? const Color(0xFF2F98D7) : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      color:
                          isCompleted
                              ? const Color(0xFF4CAF50)
                              : isActive
                              ? const Color(0xFF2F98D7)
                              : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child:
                        isCompleted
                            ? Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16.sp,
                            )
                            : isActive
                            ? SizedBox(
                              width: 16.w,
                              height: 16.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      step,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color:
                            isActive
                                ? const Color(0xFF2F98D7)
                                : isCompleted
                                ? const Color(0xFF4CAF50)
                                : Colors.grey[600],
                        fontWeight:
                            isActive || isCompleted
                                ? FontWeight.w600
                                : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: (_currentLoadingStep + 1) / _loadingSteps.length,
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2F98D7)),
          minHeight: 6.h,
        ),
        SizedBox(height: 8.h),
        Text(
          '${((_currentLoadingStep + 1) / _loadingSteps.length * 100).round()}% مكتمل',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanView() {
    if (_generatedPlan == null) {
      return _buildErrorView();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            _buildAIInsightsHeader(),
            _buildToggleSwitch(),
            Expanded(
              child:
                  _showRecommendations
                      ? _buildRecommendationsView()
                      : _buildWeeklyPlanView(),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildAIInsightsHeader() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2F98D7), Color(0xFF166EA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F98D7).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 32.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'خطة ذكية مخصصة لك',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'تم إنشاؤها بناءً على ${_getAnalysisPoints()} نقطة تحليل شخصية',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final totalEvents = _generatedPlan!.length;
    final studySessions =
        _generatedPlan!
            .where(
              (e) => !e.title.contains('امتحان') && !e.title.contains('مراجعة'),
            )
            .length;
    final exams =
        _generatedPlan!.where((e) => e.title.contains('امتحان')).length;
    final reviews =
        _generatedPlan!.where((e) => e.title.contains('مراجعة')).length;

    return Row(
      children: [
        _buildQuickStat('الدروس', studySessions.toString(), Icons.book),
        SizedBox(width: 12.w),
        _buildQuickStat('المراجعة', reviews.toString(), Icons.refresh),
        SizedBox(width: 12.w),
        _buildQuickStat('الامتحانات', exams.toString(), Icons.quiz),
      ],
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24.sp),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
      child: Row(
        children: [
          _buildToggleOption('الجدول الأسبوعي', !_showRecommendations, false),
          _buildToggleOption('التوصيات الذكية', _showRecommendations, true),
        ],
      ),
    );
  }

  Widget _buildToggleOption(
    String title,
    bool isSelected,
    bool isRecommendations,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _showRecommendations = isRecommendations),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2F98D7) : Colors.transparent,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isRecommendations ? Icons.lightbulb : Icons.calendar_today,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyPlanView() {
    final groupedEvents = <String, List<Event>>{};

    for (final event in _generatedPlan!) {
      final dayKey = _getDayName(event.startTime);
      groupedEvents.putIfAbsent(dayKey, () => []).add(event);
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: groupedEvents.length,
      itemBuilder: (context, index) {
        final dayName = groupedEvents.keys.elementAt(index);
        final dayEvents = groupedEvents[dayName]!;
        return _buildDayCard(dayName, dayEvents);
      },
    );
  }

  Widget _buildDayCard(String dayName, List<Event> events) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDayHeader(dayName, events.length),
          _buildDayEvents(events),
        ],
      ),
    );
  }

  Widget _buildDayHeader(String dayName, int eventCount) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2F98D7), Color(0xFF166EA2)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.today, color: Colors.white, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              dayName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '$eventCount أنشطة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayEvents(List<Event> events) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: events.map((event) => _buildEventCard(event)).toList(),
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    final isExam = event.title.contains('امتحان');
    final isReview = event.title.contains('مراجعة');

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Color(event.colorValue).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Color(event.colorValue).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 6.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: Color(event.colorValue),
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                  ),
                ),
                SizedBox(height: 8.h),
                _buildEventDetails(event),
              ],
            ),
          ),
          _buildEventType(isExam, isReview, Color(event.colorValue)),
        ],
      ),
    );
  }

  Widget _buildEventDetails(Event event) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.access_time, size: 16.sp, color: Colors.grey[600]),
            SizedBox(width: 6.w),
            Text(
              '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Icon(Icons.location_on, size: 16.sp, color: Colors.grey[600]),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                event.place,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEventType(bool isExam, bool isReview, Color color) {
    String type = 'درس';
    Color typeColor = color;
    IconData icon = Icons.book;

    if (isExam) {
      type = 'امتحان';
      typeColor = Colors.red;
      icon = Icons.quiz;
    } else if (isReview) {
      type = 'مراجعة';
      typeColor = Colors.orange;
      icon = Icons.refresh;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: typeColor, size: 16.sp),
          SizedBox(width: 4.w),
          Text(
            type,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: typeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsView() {
    if (_recommendations == null || _recommendations!.isEmpty) {
      return _buildEmptyRecommendations();
    }

    return ListView(
      padding: EdgeInsets.all(16.w),
      children: _buildRecommendationSections(),
    );
  }

  Widget _buildEmptyRecommendations() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lightbulb_outline, size: 80.sp, color: Colors.grey[400]),
          SizedBox(height: 24.h),
          Text(
            'لا توجد توصيات متاحة',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'سيتم إضافة توصيات ذكية قريباً',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRecommendationSections() {
    final sections = <Widget>[];

    if (_recommendations!.containsKey('timeManagement')) {
      sections.add(
        _buildRecommendationSection(
          'إدارة الوقت',
          _recommendations!['timeManagement'],
          Icons.schedule,
          const Color(0xFF2F98D7),
        ),
      );
    }

    if (_recommendations!.containsKey('studyTechniques')) {
      sections.add(
        _buildRecommendationSection(
          'تقنيات الدراسة',
          _recommendations!['studyTechniques'],
          Icons.psychology,
          const Color(0xFF4CAF50),
        ),
      );
    }

    if (_recommendations!.containsKey('examPreparation')) {
      sections.add(
        _buildRecommendationSection(
          'التحضير للامتحانات',
          _recommendations!['examPreparation'],
          Icons.quiz,
          const Color(0xFFFF9800),
        ),
      );
    }

    return sections;
  }

  Widget _buildRecommendationSection(
    String title,
    dynamic content,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: color, size: 28.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: _buildRecommendationContent(content),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationContent(dynamic content) {
    if (content is String) {
      return Text(
        content,
        style: TextStyle(fontSize: 16.sp, color: Colors.grey[700], height: 1.6),
      );
    } else if (content is List) {
      return Column(
        children:
            content
                .map((item) => _buildRecommendationItem(item.toString()))
                .toList(),
      );
    }
    return const SizedBox();
  }

  Widget _buildRecommendationItem(String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 8.h),
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: const Color(0xFF2F98D7),
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[700],
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
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
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[100],
                foregroundColor: Colors.grey[700],
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'إعادة التخصيص',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            flex: 1,
            child: ElevatedButton(
              onPressed: () {
                if (_generatedPlan != null) {
                  widget.onAcceptPlan!(_generatedPlan!);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F98D7),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'قبول الخطة والبدء',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(
                Icons.error_outline,
                size: 80.sp,
                color: Colors.red[400],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              _errorMessage ?? 'حدث خطأ غير متوقع',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              'يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.grey[700],
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'العودة',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _errorMessage = null;
                        _currentLoadingStep = 0;
                      });
                      _loadingController.reset();
                      _fadeController.reset();
                      _slideController.reset();
                      _startLoadingAnimation();
                      _generateAIPlan();
                    },
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
                        Icon(Icons.refresh, size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'إعادة المحاولة',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods
  String _getDayName(DateTime date) {
    const days = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return days[date.weekday - 1];
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  int _getAnalysisPoints() {
    int points = 0;

    // Count analysis points based on study preferences
    if (widget.preferences!.preferredSubjectsOrder.isNotEmpty) points += 15;
    if (widget.preferences!.dailyStudyHours > 0) points += 10;
    if (widget.preferences!.preferredTimeToStudy.isNotEmpty) points += 8;
    if (widget.preferences!.studyStyle.isNotEmpty) points += 12;
    if (widget.preferences!.hardestSubject.isNotEmpty) points += 10;
    if (widget.preferences!.favoriteSubject.isNotEmpty) points += 8;
    if (widget.preferences!.concentrationLevel > 0) points += 7;
    if (widget.preferences!.breakDurationMinutes > 0) points += 5;
    if (widget.preferences!.reviewFrequency.isNotEmpty) points += 9;
    if (widget.preferences!.examPreparationStrategy.isNotEmpty) points += 11;
    if (widget.preferences!.studyEnvironment.isNotEmpty) points += 6;
    if (widget.preferences!.distractions.isNotEmpty) points += 8;

    return points.clamp(50, 150); // Ensure reasonable range
  }
}
