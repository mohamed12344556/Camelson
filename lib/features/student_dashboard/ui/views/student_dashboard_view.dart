import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:boraq/features/profile/ui/logic/profle/profile_cubit.dart';
import 'package:boraq/features/profile/ui/logic/profle/profile_state.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class StudentDashboardView extends StatelessWidget {
  const StudentDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDarkMode
          ? const Color(0xFF1A1A1A)
          : Colors.white,
      appBar: CustomAppBar(
        title: context.isArabic
            ? 'اللوحة الرئيسية للطالب'
            : 'Student Dashboard',
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header
                    _buildProfileHeader(context, state),
                    const SizedBox(height: 24),

                    // Current Course Progress
                    _buildCurrentCourseCard(context),
                    const SizedBox(height: 24),

                    // Mini Games Section
                    _buildMiniGamesSection(),
                    const SizedBox(height: 24),

                    // In Progress Section
                    _buildInProgressSection(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ProfileState state) {
    final userData = state.userData;
    final isLoading = state.status == ProfileStatus.loading && userData == null;

    return Row(
      children: [
        // Avatar with yellow circle background
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.yellow[100],
            shape: BoxShape.circle,
            border: Border.all(color: Colors.orange, width: 2),
          ),
          child: ClipOval(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : userData?.profileImageUrl != null &&
                      userData!.profileImageUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: userData.profileImageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.orange,
                    ),
                  )
                : const Icon(Icons.person, size: 30, color: Colors.orange),
          ),
        ),
        const SizedBox(width: 12),

        // Name and Badge
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isLoading
                    ? (context.isArabic ? 'جاري التحميل...' : 'Loading...')
                    : userData?.name ?? (context.isArabic ? 'طالب' : 'Student'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isLoading
                      ? '...'
                      : userData?.role ??
                            (context.isArabic ? 'طالب' : 'Student'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        // // Notification and Settings Icons
        // Container(
        //   width: 40,
        //   height: 40,
        //   decoration: BoxDecoration(
        //     color: Colors.blue,
        //     borderRadius: BorderRadius.circular(12),
        //   ),
        //   child: const Icon(Icons.notifications, color: Colors.white, size: 20),
        // ),
        // const SizedBox(width: 8),
        // Container(
        //   width: 40,
        //   height: 40,
        //   decoration: BoxDecoration(
        //     border: Border.all(color: Colors.grey[300]!),
        //     borderRadius: BorderRadius.circular(12),
        //   ),
        //   child: const Icon(Icons.settings, color: Colors.black, size: 20),
        // ),
      ],
    );
  }

  Widget _buildCurrentCourseCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.pink[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.medical_services,
                  color: Colors.pink[300],
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Human Anatomy - Cardiovascular System',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'د. أحمد حسن محمد',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '80%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.8,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
          const SizedBox(height: 12),

          // Chapter and Level
          Row(
            children: [
              Icon(Icons.book, size: 16, color: Colors.grey[400]),
              const SizedBox(width: 4),
              const Text(
                'Chapter 5: Heart & Blood Vessels',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Year 1',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniGamesSection() {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildGameCard('Flashcards', Colors.purple, Icons.style),
              const SizedBox(width: 12),
              _buildGameCard('Quiz', Colors.pink[200]!, Icons.quiz),
              const SizedBox(width: 12),
              _buildGameCard(
                'MCQ Practice',
                Colors.deepPurple,
                Icons.question_answer,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGameCard(String title, Color color, IconData icon) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInProgressSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'In process',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'View all',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 3,
          width: 80,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),

        // Course 1
        _buildInProgressCourseCard(
          icon: Icons.biotech,
          iconColor: Colors.orange,
          title: 'Medical Biochemistry - Metabolism & Enzymes',
          progress: 0.62,
          progressColor: Colors.orange,
          percentage: '62%',
          subtitle: 'Chapter 4',
          subtitleIcon: Icons.layers,
          isCompleted: false,
        ),
        const SizedBox(height: 12),

        // Course 2
        _buildInProgressCourseCard(
          icon: Icons.healing,
          iconColor: Colors.blue,
          title: 'Principles of Disease - Cell Pathology',
          progress: 1.0,
          progressColor: Colors.blue,
          percentage: '',
          subtitle: 'Completed',
          subtitleIcon: Icons.emoji_events,
          isCompleted: true,
        ),
      ],
    );
  }

  Widget _buildInProgressCourseCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required double progress,
    required Color progressColor,
    required String percentage,
    required String subtitle,
    required IconData subtitleIcon,
    required bool isCompleted,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              if (!isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    percentage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (isCompleted)
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 18),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 12),

          // Subtitle and Button
          Row(
            children: [
              Icon(subtitleIcon, size: 16, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Learn now',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
