import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/core.dart' hide DateFormatter;
import '../../../../core/widgets/modern_empty_state.dart';
import '../../../../core/widgets/modern_error_state.dart';
import '../../../../core/widgets/modern_loading_indicator.dart';
import '../logic/lessons_cubit.dart';
import '../widgets/event_timeline_widget.dart';

class LessonsView extends StatefulWidget {
  const LessonsView({super.key});

  @override
  State<LessonsView> createState() => _LessonsViewState();
}

class _LessonsViewState extends State<LessonsView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    context.read<LessonsCubit>().loadEvents();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LessonsCubit, LessonsState>(
      builder: (context, state) {
        return AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Column(
                children: [
                  // Date Timeline - Only show when data is loaded
                  if (state is LessonsLoaded) _buildDateTimeline(state),

                  // Main Content Area
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.r),
                          topRight: Radius.circular(20.r),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: _buildContent(state),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDateTimeline(LessonsLoaded state) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: EasyDateTimeLine(
          initialDate: state.selectedDate,
          onDateChange: (selectedDate) {
            context.read<LessonsCubit>().selectDate(selectedDate);
          },
          headerProps: EasyHeaderProps(
            monthPickerType: MonthPickerType.switcher,
            dateFormatter: DateFormatter.fullDateDMonthAsStrY(),
            showHeader: true,
          ),
          dayProps: EasyDayProps(
            dayStructure: DayStructure.dayStrDayNumMonth,
            activeDayStyle: const DayStyle(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2F98D7), Color(0xFF166EA2)],
                ),
              ),
            ),
            inactiveDayStyle: const DayStyle(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFBFDBFB), Color(0xFFA8D0F5)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(LessonsState state) {
    if (state is LessonsLoading) {
      return const ModernLoadingIndicator.fetching(
        message: 'Loading your lessons...',
        gradientColors: [Color(0xFF2F98D7), Color(0xFF166EA2)],
      );
    }

    if (state is LessonsError) {
      return ErrorStateExtension.fromErrorMessage(
        state.message,
        onRetry: () => context.read<LessonsCubit>().loadEvents(),
        secondaryButtonText: 'Go Back',
        onSecondaryAction: () => context.pop(), // استخدام extension
      );
    }

    if (state is LessonsLoaded) {
      // Check if there are events for the selected date
      final selectedDateEvents =
          state.events.where((event) {
            final eventDate = event.startTime;
            final selectedDate = state.selectedDate;
            return eventDate.year == selectedDate.year &&
                eventDate.month == selectedDate.month &&
                eventDate.day == selectedDate.day;
          }).toList();

      if (selectedDateEvents.isEmpty) {
        return _buildEmptyState(state.selectedDate);
      }

      return Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date info
            _buildContentHeader(state.selectedDate, selectedDateEvents.length),

            SizedBox(height: 16.h),

            // Events list
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: EventTimelineWidget(
                  events: selectedDateEvents,
                  onEventTap: (eventId) {
                    context.read<LessonsCubit>().toggleEventCompletion(eventId);
                  },
                  onEventDelete: (eventId) {
                    _showDeleteEventDialog(eventId);
                  },
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const ModernEmptyState.noData(
      gradientColors: [Color(0xFF2F98D7), Color(0xFF166EA2)],
    );
  }

  Widget _buildContentHeader(DateTime selectedDate, int eventsCount) {
    final isToday = _isToday(selectedDate);
    final dayName = _getDayName(selectedDate);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2F98D7), Color(0xFF166EA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F98D7).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              isToday ? Icons.today : Icons.calendar_today,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isToday ? 'Today' : dayName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$eventsCount ${eventsCount == 1 ? 'lesson' : 'lessons'} scheduled',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              eventsCount.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(DateTime selectedDate) {
    final isToday = _isToday(selectedDate);
    final dayName = _getDayName(selectedDate);

    return ModernEmptyState(
      icon: Icons.event_note_outlined,
      title: 'No Lessons ${isToday ? 'Today' : 'on $dayName'}',
      subtitle:
          isToday
              ? 'You don\'t have any lessons scheduled for today.\nEnjoy your free time!'
              : 'No lessons are scheduled for this date.\nSelect another date to view lessons.',
      buttonText: isToday ? 'Browse All Lessons' : 'View Today',
      onButtonPressed: () {
        if (isToday) {
          // استخدام extension لإظهار SnackBar
          context.showInfoSnackBar('Browse all lessons feature coming soon!');
        } else {
          // Go back to today
          context.read<LessonsCubit>().selectDate(DateTime.now());
        }
      },
      gradientColors: const [Color(0xFF2F98D7), Color(0xFF166EA2)],
    );
  }

  // استخدام extension لتحسين delete dialog
  void _showDeleteEventDialog(String eventId) {
    context.showErrorDialog(
      title: 'Delete Event',
      message:
          'System events cannot be deleted. This action is restricted to maintain system integrity.',
      buttonText: 'Got it',
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _getDayName(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[date.weekday - 1];
  }
}
