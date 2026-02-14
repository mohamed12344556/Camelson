import 'package:easy_date_timeline/easy_date_timeline.dart';
// Navigation extensions moved to core/utils/extensions.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/core.dart' hide DateFormatter;
import '../../../../core/widgets/modern_empty_state.dart';
import '../../../../core/widgets/modern_error_state.dart';
import '../../../../core/widgets/modern_loading_indicator.dart';
import '../logic/plan_cubit.dart';
import '../widgets/add_event_bottom_sheet.dart';
import '../widgets/event_timeline_widget.dart';

class MyPlanView extends StatefulWidget {
  const MyPlanView({super.key});

  @override
  State<MyPlanView> createState() => _MyPlanViewState();
}

class _MyPlanViewState extends State<MyPlanView> with TickerProviderStateMixin {
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

    context.read<PlanCubit>().loadEvents();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlanCubit, PlanState>(
      builder: (context, state) {
        return AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Column(
                children: [
                  // Date Timeline - Only show when data is loaded
                  if (state is PlanLoaded) _buildDateTimeline(state),

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

  Widget _buildDateTimeline(PlanLoaded state) {
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
            context.read<PlanCubit>().selectDate(selectedDate);
          },
          headerProps: const EasyHeaderProps(
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

  Widget _buildContent(PlanState state) {
    if (state is PlanLoading) {
      return const ModernLoadingIndicator.fetching(
        message: 'Loading your plan...',
        gradientColors: [Color(0xFF2F98D7), Color(0xFF166EA2)],
      );
    }

    if (state is PlanError) {
      return ErrorStateExtension.fromErrorMessage(
        state.message,
        onRetry: () => context.read<PlanCubit>().loadEvents(),
        secondaryButtonText: 'Go Back',
        onSecondaryAction: () => context.pop(),
      );
    }

    if (state is PlanLoaded) {
      // Check if there are events for the selected date
      final selectedDateEvents =
          state.events.where((event) {
            final eventDate = event.startTime;
            final selectedDate = state.selectedDate;
            return eventDate.year == selectedDate.year &&
                eventDate.month == selectedDate.month &&
                eventDate.day == selectedDate.day;
          }).toList();

      return Stack(
        children: [
          selectedDateEvents.isEmpty
              ? _buildEmptyState(state.selectedDate)
              : Column(
                children: [
                  // Header with date info - only show when there are events
                  _buildContentHeader(
                    state.selectedDate,
                    selectedDateEvents.length,
                  ),

                  // Events content
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: EventTimelineWidget(
                          events: selectedDateEvents,
                          onEventTap: (eventId) {
                            context.read<PlanCubit>().toggleEventCompletion(
                              eventId,
                            );
                          },
                          onEventDelete: (eventId) {
                            _showDeleteDialog(eventId);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),

          // Floating Action Button
          Positioned(
            bottom: 100.h,
            right: 20.w,
            child: FloatingActionButton(
              onPressed: () => _showAddEventBottomSheet(state.selectedDate),
              backgroundColor: const Color(0xFF2F98D7),
              elevation: 8,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
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
      margin: EdgeInsets.all(16.w),
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
              isToday ? Icons.today : Icons.event_note,
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
                  '$eventsCount ${eventsCount == 1 ? 'event' : 'events'} planned',
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
      icon: Icons.event_available_outlined,
      title: 'No Events ${isToday ? 'Today' : 'on $dayName'}',
      subtitle:
          isToday
              ? 'You don\'t have any events planned for today.\nTap the + button to add one!'
              : 'No events are planned for this date.\nTap the + button to create an event.',
      buttonText: 'Add Event',
      onButtonPressed: () {
        _showAddEventBottomSheet(selectedDate);
      },
      gradientColors: const [Color(0xFF2F98D7), Color(0xFF166EA2)],
    );
  }

  void _showAddEventBottomSheet(DateTime selectedDate) {
    context
        .showCustomBottomSheet(
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder:
              (bottomSheetContext) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(25.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, -10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 12.h),
                      width: 50.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),

                    // Header
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 8.h,
                      ),
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
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.event_note,
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
                                  'Add New Event',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _formatDate(selectedDate),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Content
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 20.w,
                          right: 20.w,
                          bottom:
                              MediaQuery.of(
                                bottomSheetContext,
                              ).viewInsets.bottom +
                              20.h,
                        ),
                        child: AddEventBottomSheet(
                          selectedDate: selectedDate,
                          onAddEvent: (event) {
                            context.read<PlanCubit>().addEvent(event);
                            BuildContextExtensions(
                              context,
                            ).showSuccessSnackBar('Event added successfully!');
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        )
        .whenComplete(() {
          // Notify when bottom sheet is closed
          // _notifyBottomSheetState(false);
        });
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  void _showDeleteDialog(String eventId) async {
    final result = await BuildContextExtensions(
      context,
    ).showDeleteConfirmationDialog(
      title: 'Delete Event',
      message:
          'Are you sure you want to delete this event? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
    );

    if (result == true) {
      context.read<PlanCubit>().deleteEvent(eventId);
      BuildContextExtensions(
        context,
      ).showSuccessSnackBar('Event deleted successfully');
    }
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
