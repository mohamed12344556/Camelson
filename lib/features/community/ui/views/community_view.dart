// community_view.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/themes/font_weight_helper.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/custom_search_bar.dart';
import '../../../../core/widgets/modern_empty_state.dart';
import '../../../../core/widgets/modern_error_state.dart';
import '../../../../core/widgets/modern_loading_indicator.dart';
import '../../data/models/community_constants.dart';
import '../../data/models/question.dart';
import '../../data/models/room.dart'; // Used for ChatRoomView
import '../../data/services/question_service.dart';
import '../logic/chat_bloc/chat_bloc.dart';
import '../logic/community_bloc/community_bloc.dart';
import '../logic/community_bloc/community_event.dart';
import '../logic/community_bloc/community_state.dart';
import '../widgets/ask_question_bottom_sheet.dart';
import '../widgets/policy_bottom_sheet.dart';
import '../widgets/question_card_widget.dart';
import '../widgets/edit_question_bottom_sheet.dart';
import 'chat_room_view.dart';

class CommunityView extends StatefulWidget {
  const CommunityView({super.key});

  @override
  State<CommunityView> createState() => _CommunityViewState();
}

class _CommunityViewState extends State<CommunityView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isFabVisible = true;

  // ✅ Helper method to safely add events to bloc
  void _safeAddEvent(CommunityEvent event) {
    if (mounted) {
      final bloc = context.read<CommunityBloc>();
      if (!bloc.isClosed) {
        bloc.add(event);
      }
    }
  }

  // ✅ Helper method to extract user-friendly error messages from API responses
  String _getErrorMessage(dynamic e) {
    if (e is DioException && e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'].toString();
      }
    }
    return e.toString();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Listen to tab changes
    _tabController.addListener(_onTabChanged);

    // Listen to scroll for pagination
    _scrollController.addListener(_onScroll);

    // Load questions on init
    _safeAddEvent(const CommunityLoadRequested());
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      // Tab animation finished
      final filter = _tabController.index == 0
          ? QuestionFilter.active
          : QuestionFilter.all;
      _safeAddEvent(CommunityFilterChanged(filter));
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Near bottom, load more
      _safeAddEvent(const CommunityLoadMoreRequested());
    }

    // Hide/show FAB based on scroll direction
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse && _isFabVisible) {
      setState(() => _isFabVisible = false);
    } else if (direction == ScrollDirection.forward && !_isFabVisible) {
      setState(() => _isFabVisible = true);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: BlocBuilder<CommunityBloc, CommunityState>(builder: _buildBody),
      floatingActionButton:  Align(
        alignment: Alignment(1.0, 0.85),
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 300),
          offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isFabVisible ? 1.0 : 0.0,
            child: _buildFloatingActionButton(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, CommunityState state) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ✨ Modern App Bar
        _buildSliverAppBar(state),

        // ✨ Search Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _buildSearchBar(),
          ),
        ),

        // ✨ Stats Cards
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildStatsCards(state),
          ),
        ),

        // ✨ Tabs
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyTabBarDelegate(child: _buildTabBar()),
        ),

        // ✨ Content
        _buildContent(state),

        // ✨ Loading More Indicator
        if (state.status == CommunityStatus.loadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  Widget _buildSliverAppBar(CommunityState state) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: context.colors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'المجتمع التعليمي',
          style: context.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeightHelper.bold,
          ),
        ),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.colors.primary,
                context.colors.primary.withOpacity(0.85),
                context.colors.secondary.withOpacity(0.6),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -60,
                right: -60,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: 40,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              // Center Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.forum_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
            ),
          ),
          onPressed: () {
            _showComingSoonSnackbar('الإشعارات');
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar() {
    return CustomSearchBar(
      searchController: _searchController,
      hintText: 'ابحث عن سؤال أو موضوع...',
      onChanged: (value) {
        _safeAddEvent(CommunitySearchQueryChanged(value));
      },
      onClearPressed: () {
        _searchController.clear();
        _safeAddEvent(const CommunitySearchQueryChanged(''));
      },
    );
  }

  Widget _buildStatsCards(CommunityState state) {
    final totalQuestions = state.allQuestions.length;
    final activeToday = state.allQuestions
        .where((q) => _isToday(q.createdAt))
        .length;
    final totalMembers = state.allQuestions.fold<int>(
      0,
      (sum, q) => sum + q.memberCount,
    );

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.question_answer_rounded,
            label: 'الأسئلة',
            value: '$totalQuestions',
            color: context.colors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.people_rounded,
            label: 'الأعضاء',
            value: '$totalMembers',
            color: context.colors.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.trending_up_rounded,
            label: 'نشطة اليوم',
            value: '$activeToday',
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeightHelper.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: context.colors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الأسئلة النشطة'),
            Tab(text: 'كل الأسئلة'),
          ],
          indicator: BoxDecoration(
            color: context.colors.primary,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: context.colors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          labelColor: Colors.white,
          unselectedLabelColor: context.colors.onSurfaceVariant,
          labelStyle: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeightHelper.semiBold,
          ),
          unselectedLabelStyle: context.textTheme.titleSmall,
          indicatorSize: TabBarIndicatorSize.tab,
        ),
      ),
    );
  }

  Widget _buildContent(CommunityState state) {
    // Show loading for both initial and loading states
    if (state.status == CommunityStatus.initial ||
        state.status == CommunityStatus.loading) {
      return SliverFillRemaining(
        child: ModernLoadingIndicator(
          message: 'جاري تحميل الأسئلة...',
          type: LoadingType.pulse,
        ),
      );
    }

    if (state.status == CommunityStatus.error) {
      return SliverFillRemaining(
        child: ModernErrorState(
          title: 'فشل تحميل البيانات',
          subtitle: state.errorMessage ?? 'حدث خطأ أثناء تحميل الأسئلة',
          buttonText: 'إعادة المحاولة',
          onButtonPressed: () {
            _safeAddEvent(const CommunityLoadRequested(forceRefresh: true));
          },
        ),
      );
    }

    final questions = _searchController.text.isEmpty
        ? state.allQuestions
        : state.filteredQuestions;

    if (questions.isEmpty) {
      return SliverFillRemaining(
        child: ModernEmptyState(
          icon: Icons.question_answer_rounded,
          title: _searchController.text.isEmpty
              ? 'لا توجد أسئلة'
              : 'لم نجد نتائج',
          subtitle: _searchController.text.isEmpty
              ? 'كن أول من يطرح سؤالاً في المجتمع'
              : 'جرب البحث بكلمات مختلفة',
          buttonText: _searchController.text.isEmpty
              ? 'اطرح سؤالاً'
              : 'مسح البحث',
          onButtonPressed: _searchController.text.isEmpty
              ? _showAskQuestionBottomSheet
              : () {
                  _searchController.clear();
                  _safeAddEvent(const CommunitySearchQueryChanged(''));
                },
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final question = questions[index];
          // Only show edit/delete/close actions if user is the creator
          final canManage = question.creatorId ==
              CommunityConstants.currentUser.id;
          return QuestionCardWidget(
            question: question,
            onTap: () => _navigateToChat(question),
            onEdit: canManage ? () => _editQuestion(question) : null,
            onDelete: canManage ? () => _deleteQuestion(question) : null,
            onClose: canManage && !question.isClosed
                ? () => _closeQuestion(question)
                : null,
          );
        }, childCount: questions.length),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _showAskQuestionBottomSheet,
      icon: const Icon(Icons.add_rounded),
      label: const Text('اطرح سؤالاً'),
      elevation: 4,
      backgroundColor: context.colors.primary,
      foregroundColor: Colors.white,
    );
  }

  // ✅ تحديث _navigateToChat لعمل refresh عند الرجوع
  Future<void> _navigateToChat(Question question) async {
    // Check if policy is accepted
    if (context.read<CommunityBloc>().state.currentUser == null) {
      _showPolicyBottomSheet();
      return;
    }

    // Check if user has left this room
    final isViewOnly = context
        .read<CommunityBloc>()
        .state
        .leftRoomIds
        .contains(question.id);

    // ✅ Navigate and wait for result
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<ChatBloc>(),
          child: ChatRoomView(
            isViewOnly: isViewOnly,
            room: Room(
              id: question.id,
              name: question.title,
              description: question.description,
              subject: question.subjectName,
              grade: '', // Not available in Question model
              createdAt: question.createdAt,
              memberCount: question.memberCount,
              messageCount: question.messageCount,
              lastMessage: null,
              lastMessageTime: question.updatedAt ?? question.createdAt,
              unreadCount: 0,
              creatorId: question.creatorId,
              creatorName: question.creatorName,
              currentUserRole: question.currentUserRole,
            ),
          ),
        ),
      ),
    );

    // Track if user left this room
    if (result != null && result.isNotEmpty) {
      _safeAddEvent(CommunityRoomLeft(result));
    }

    // ✅ عند الرجوع، refresh البيانات
    _safeAddEvent(const CommunityLoadRequested(forceRefresh: true));
  }

  void _showAskQuestionBottomSheet() {
    // Check if policy is accepted
    if (context.read<CommunityBloc>().state.currentUser == null) {
      _showPolicyBottomSheet();
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<CommunityBloc>(),
        child: AskQuestionBottomSheet(
          onQuestionSubmitted: (question) {
            // Refresh the questions list
            _safeAddEvent(const CommunityLoadRequested(forceRefresh: true));
            // Navigate to the chat room
            _navigateToChat(question);
          },
          onDismissed: () {
            // Refresh on failure too
            _safeAddEvent(const CommunityLoadRequested(forceRefresh: true));
          },
        ),
      ),
    );
  }

  void _showPolicyBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<CommunityBloc>(),
        child: PolicyBottomSheet(
          onPolicyAccepted: () {
            Navigator.pop(context);
            // Refresh the view after policy acceptance
            _safeAddEvent(const CommunityLoadRequested(forceRefresh: true));
          },
        ),
      ),
    );
  }

  void _editQuestion(Question question) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: EditQuestionBottomSheet(
          question: question,
          onQuestionUpdated: () {
            _safeAddEvent(const CommunityLoadRequested(forceRefresh: true));
          },
        ),
      ),
    );
  }

  Future<void> _deleteQuestion(Question question) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف السؤال'),
        content: const Text(
          'هل أنت متأكد من حذف هذا السؤال؟ هذا الإجراء لا يمكن التراجع عنه.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      // Show loading
      context.showSnackBar('جاري حذف السؤال...');

      // Delete question via API
      final questionService = sl<QuestionService>();
      final success = await questionService.deleteQuestion(question.id);

      if (!mounted) return;

      if (success) {
        // Show success message
        context.showSuccessSnackBar('تم حذف السؤال بنجاح');

        // Refresh list
        _safeAddEvent(const CommunityLoadRequested(forceRefresh: true));
      } else {
        throw Exception('فشل في حذف السؤال');
      }
    } catch (e) {
      if (!mounted) return;
      context.showErrorSnackBar(_getErrorMessage(e));
    }
  }

  Future<void> _closeQuestion(Question question) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إغلاق السؤال'),
        content: const Text(
          'هل أنت متأكد من إغلاق هذا السؤال؟ لن يتمكن الأعضاء من إرسال رسائل جديدة.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      // Show loading
      context.showSnackBar('جاري إغلاق السؤال...');

      // Close question via API
      final questionService = sl<QuestionService>();
      final success = await questionService.closeQuestion(question.id);

      if (!mounted) return;

      if (success) {
        // Show success message
        context.showSuccessSnackBar('تم إغلاق السؤال بنجاح');

        // Refresh list
        _safeAddEvent(const CommunityLoadRequested(forceRefresh: true));
      } else {
        throw Exception('فشل في إغلاق السؤال');
      }
    } catch (e) {
      if (!mounted) return;
      context.showErrorSnackBar(_getErrorMessage(e));
    }
  }

  void _showComingSoonSnackbar(String feature) {
    context.showInfoSnackBar('$feature قريباً!');
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

// ✨ Sticky Tab Bar Delegate
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyTabBarDelegate({required this.child});

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
