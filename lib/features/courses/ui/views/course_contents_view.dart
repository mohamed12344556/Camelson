import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class CourseContentsView extends StatefulWidget {
  const CourseContentsView({super.key});

  @override
  State<CourseContentsView> createState() => _CourseContentsViewState();
}

class _CourseContentsViewState extends State<CourseContentsView>
    with SingleTickerProviderStateMixin {
  late TabController _mainTabController;

  // Medical lecture data - Pathology Course
  final List<Map<String, dynamic>> _lectures = [
    {
      'title': 'Cell Injury & Adaptation',
      'description':
          'Understanding cellular responses to stress, including hypertrophy, hyperplasia, atrophy, metaplasia, and the mechanisms of reversible vs irreversible cell injury.',
      'image': 'assets/images/learning.png',
      'duration': '45 mins',
      'keyPoints': [
        'Cellular adaptation mechanisms: hypertrophy, hyperplasia, atrophy, and metaplasia',
        'Reversible cell injury: cellular swelling, fatty change, and ultrastructural changes',
        'Irreversible cell injury: necrosis vs apoptosis pathways',
        'Common causes: hypoxia, toxins, infections, immunologic reactions',
        'Clinical correlations: myocardial infarction, hepatic steatosis, tissue atrophy',
      ],
      'resources': [
        {
          'title': 'Robbins Basic Pathology - Chapter 1',
          'type': 'PDF',
          'size': '4.2 MB',
          'description': 'Comprehensive overview of cell injury mechanisms',
        },
        {
          'title': 'Cell Injury Lecture Slides',
          'type': 'PDF',
          'size': '2.8 MB',
          'description': 'Annotated slides with histological images',
        },
        {
          'title': 'Necrosis vs Apoptosis Flowchart',
          'type': 'PDF',
          'size': '1.1 MB',
          'description': 'Visual guide to distinguish pathways',
        },
      ],
      'usmleQuestions': 12,
    },
    {
      'title': 'Inflammation & Repair',
      'description':
          'Exploring acute and chronic inflammation processes, cellular mediators, inflammatory patterns, and tissue healing mechanisms including regeneration and fibrosis.',
      'image': 'assets/images/learning.png',
      'duration': '52 mins',
      'keyPoints': [
        'Acute inflammation: vascular changes, leukocyte recruitment, and chemical mediators',
        'Cardinal signs: rubor, tumor, calor, dolor, and functio laesa',
        'Chronic inflammation: macrophages, lymphocytes, and granulomatous patterns',
        'Wound healing: hemostasis, inflammation, proliferation, and remodeling phases',
        'Clinical examples: pneumonia, tuberculosis, chronic gastritis, keloid formation',
      ],
      'resources': [
        {
          'title': 'Inflammation Pathways Guide',
          'type': 'PDF',
          'size': '3.5 MB',
          'description': 'Detailed molecular mechanisms and mediators',
        },
        {
          'title': 'Granulomatous Diseases Atlas',
          'type': 'PDF',
          'size': '5.1 MB',
          'description': 'Histological images of various granulomas',
        },
        {
          'title': 'Wound Healing Stages',
          'type': 'PDF',
          'size': '2.3 MB',
          'description': 'Timeline and cellular components',
        },
      ],
      'usmleQuestions': 18,
    },
    {
      'title': 'Hemodynamic Disorders',
      'description':
          'Study of edema, hyperemia, hemorrhage, thrombosis, embolism, infarction, and shock. Understanding the pathophysiology of fluid balance and circulatory disturbances.',
      'image': 'assets/images/learning.png',
      'duration': '38 mins',
      'keyPoints': [
        'Edema: pathophysiology, localized vs generalized, pitting vs non-pitting',
        'Thrombosis: Virchow\'s triad, arterial vs venous thrombi',
        'Embolism: types (thromboembolism, fat, air, amniotic fluid)',
        'Infarction: red vs white, common sites (MI, stroke, bowel, pulmonary)',
        'Shock: cardiogenic, hypovolemic, septic, anaphylactic, and neurogenic types',
      ],
      'resources': [
        {
          'title': 'Hemodynamics Clinical Cases',
          'type': 'PDF',
          'size': '3.8 MB',
          'description': 'Real-world scenarios with radiological findings',
        },
        {
          'title': 'Thrombosis & Embolism Guide',
          'type': 'PDF',
          'size': '2.9 MB',
          'description': 'Pathogenesis and clinical manifestations',
        },
        {
          'title': 'Shock Management Protocol',
          'type': 'PDF',
          'size': '1.7 MB',
          'description': 'Recognition and emergency treatment',
        },
      ],
      'usmleQuestions': 15,
    },
    {
      'title': 'Neoplasia Fundamentals',
      'description':
          'Introduction to tumor biology, benign vs malignant characteristics, nomenclature, grading, staging, carcinogenesis, and tumor immunology.',
      'image': 'assets/images/learning.png',
      'duration': '58 mins',
      'keyPoints': [
        'Tumor nomenclature: benign (-oma) vs malignant (carcinoma, sarcoma)',
        'Hallmarks of cancer: sustained proliferation, evading growth suppressors, resisting cell death',
        'Metastasis: invasion, lymphatic and hematogenous spread',
        'Grading (differentiation) vs staging (TNM system)',
        'Carcinogens: chemical, radiation, viral (HPV, EBV, HBV, HCV)',
      ],
      'resources': [
        {
          'title': 'Cancer Biology Overview',
          'type': 'PDF',
          'size': '6.4 MB',
          'description': 'Molecular mechanisms and genetic alterations',
        },
        {
          'title': 'TNM Staging System',
          'type': 'PDF',
          'size': '2.1 MB',
          'description': 'Comprehensive staging for common cancers',
        },
        {
          'title': 'Tumor Markers Reference',
          'type': 'PDF',
          'size': '1.9 MB',
          'description': 'Diagnostic and prognostic biomarkers',
        },
      ],
      'usmleQuestions': 22,
    },
    {
      'title': 'Immunopathology',
      'description':
          'Understanding hypersensitivity reactions (Types I-IV), autoimmune diseases, immunodeficiency disorders, and transplant rejection mechanisms.',
      'image': 'assets/images/learning.png',
      'duration': '48 mins',
      'keyPoints': [
        'Type I hypersensitivity: IgE-mediated allergic reactions, anaphylaxis',
        'Type II: antibody-mediated cytotoxic reactions (ABO incompatibility, Graves)',
        'Type III: immune complex-mediated (SLE, serum sickness)',
        'Type IV: T-cell mediated delayed hypersensitivity (TB, contact dermatitis)',
        'Autoimmune disorders: SLE, rheumatoid arthritis, type 1 diabetes, Hashimoto\'s',
      ],
      'resources': [
        {
          'title': 'Hypersensitivity Reactions Chart',
          'type': 'PDF',
          'size': '2.6 MB',
          'description': 'Comparison table with examples',
        },
        {
          'title': 'Autoimmune Disease Atlas',
          'type': 'PDF',
          'size': '4.7 MB',
          'description': 'Pathology and clinical features',
        },
        {
          'title': 'Immunodeficiency Syndromes',
          'type': 'PDF',
          'size': '3.2 MB',
          'description': 'Primary and secondary disorders',
        },
      ],
      'usmleQuestions': 16,
    },
    {
      'title': 'Infectious Diseases',
      'description':
          'Bacterial, viral, fungal, and parasitic infections. Host-pathogen interactions, transmission, pathogenesis, and tissue injury patterns in infectious diseases.',
      'image': 'assets/images/learning.png',
      'duration': '55 mins',
      'keyPoints': [
        'Bacterial infections: Streptococcus, Staphylococcus, Mycobacterium tuberculosis',
        'Viral infections: HIV, hepatitis viruses, influenza, COVID-19',
        'Fungal infections: Candida, Aspergillus, Cryptococcus',
        'Parasitic diseases: malaria, amebiasis, helminthic infections',
        'Tissue reaction patterns: suppurative, granulomatous, cytopathic effects',
      ],
      'resources': [
        {
          'title': 'Microbiology & Pathology Integration',
          'type': 'PDF',
          'size': '7.2 MB',
          'description': 'Organism characteristics and tissue pathology',
        },
        {
          'title': 'Infectious Disease Case Studies',
          'type': 'PDF',
          'size': '4.5 MB',
          'description': 'Clinical presentations with histology',
        },
        {
          'title': 'Antimicrobial Resistance Guide',
          'type': 'PDF',
          'size': '2.8 MB',
          'description': 'Mechanisms and clinical implications',
        },
      ],
      'usmleQuestions': 20,
    },
  ];

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: isArabic ? 'مبادئ الأمراض' : 'Principles of Disease',
        onBackPressed: () {
          context.setNavBarVisible(true);
          Navigator.pop(context);
        },
      ),
      body: Column(
        children: [
          // Breadcrumb
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  'Courses',
                  style: TextStyle(
                    color: AppColors.text.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
                Text(
                  ' / ',
                  style: TextStyle(
                    color: AppColors.text.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  'Principles of Disease',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Principles of Disease',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ),
          ),

          SizedBox(height: 16),

          // Main Tabs (Overview, Lectures, Book)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.text.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: TabBar(
              controller: _mainTabController,
              labelColor: Color(0xFFF4B400),
              unselectedLabelColor: AppColors.text.withValues(alpha: 0.6),
              indicatorColor: Color(0xFFF4B400),
              indicatorWeight: 3,
              labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              unselectedLabelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              tabs: [
                Tab(text: 'Overview'),
                Tab(text: 'Lectures'),
                Tab(text: 'Book'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _mainTabController,
              children: [
                _buildOverviewTab(),
                _buildLecturesTab(),
                _buildBookTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About This Course',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Principles of Disease is a comprehensive pathology course designed for medical students preparing for USMLE Step 1. This course covers fundamental disease mechanisms, tissue responses to injury, and clinical correlations essential for understanding systemic pathology.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.text.withValues(alpha: 0.7),
              height: 1.6,
            ),
          ),
          SizedBox(height: 32),
          Text(
            'Course Statistics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.play_circle_outline,
                  label: 'Video Lectures',
                  value: '${_lectures.length}',
                  color: Color(0xFFF4B400),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.access_time,
                  label: 'Total Duration',
                  value: _calculateTotalDuration(),
                  color: Color(0xFF4285F4),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.quiz,
                  label: 'USMLE Questions',
                  value: '${_calculateTotalQuestions()}',
                  color: Color(0xFF34A853),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.description,
                  label: 'Resources',
                  value: '${_calculateTotalResources()}',
                  color: Color(0xFFEA4335),
                ),
              ),
            ],
          ),
          SizedBox(height: 32),
          Text(
            'Learning Objectives',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 16),
          _buildObjectivePoint(
            'Master fundamental pathological processes and disease mechanisms',
          ),
          _buildObjectivePoint(
            'Understand cellular and tissue responses to injury and stress',
          ),
          _buildObjectivePoint(
            'Correlate pathological findings with clinical presentations',
          ),
          _buildObjectivePoint(
            'Prepare effectively for USMLE Step 1 pathology questions',
          ),
          _buildObjectivePoint(
            'Develop diagnostic reasoning skills through case-based learning',
          ),
          SizedBox(height: 32),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF4B400).withValues(alpha: 0.1),
                  Color(0xFFF4B400).withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color(0xFFF4B400).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFFF4B400)),
                    SizedBox(width: 8),
                    Text(
                      'Course Format',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  'Each lecture includes video content, detailed summaries, downloadable resources, and USMLE-style practice questions to reinforce your understanding and exam preparation.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.text.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.text.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildObjectivePoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 6),
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Color(0xFFF4B400),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, size: 12, color: Colors.white),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.text.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateTotalDuration() {
    int totalMinutes = 0;
    for (var lecture in _lectures) {
      final duration = lecture['duration'] as String;
      final minutes =
          int.tryParse(duration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      totalMinutes += minutes;
    }
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    return '${hours}h ${mins}m';
  }

  int _calculateTotalQuestions() {
    int total = 0;
    for (var lecture in _lectures) {
      total += (lecture['usmleQuestions'] as int? ?? 0);
    }
    return total;
  }

  int _calculateTotalResources() {
    int total = 0;
    for (var lecture in _lectures) {
      final resources = lecture['resources'] as List<dynamic>? ?? [];
      total += resources.length;
    }
    return total;
  }

  Widget _buildLecturesTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.50,
      ),
      itemCount: _lectures.length,
      itemBuilder: (context, index) {
        final lecture = _lectures[index];
        return _buildLectureCard(lecture, index);
      },
    );
  }

  Widget _buildLectureCard(Map<String, dynamic> lecture, int index) {
    return GestureDetector(
      onTap: () {
        // Navigate to lecture detail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LectureDetailView(lecture: lecture),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF4B400),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.text.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF4B400),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lecture['title'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        lecture['description'],
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.text.withValues(alpha: 0.6),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  LectureDetailView(lecture: lecture),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Color(0xFFF4B400)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 6),
                        ),
                        child: Text(
                          'View Content ${index + 1}',
                          style: TextStyle(
                            color: Color(0xFFF4B400),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book,
            size: 80,
            color: AppColors.text.withValues(alpha: 0.4),
          ),
          SizedBox(height: 16),
          Text(
            'Book content coming soon',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.text.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// Lecture Detail View (Like the 3rd image)
class LectureDetailView extends StatefulWidget {
  final Map<String, dynamic> lecture;

  const LectureDetailView({super.key, required this.lecture});

  @override
  State<LectureDetailView> createState() => _LectureDetailViewState();
}

class _LectureDetailViewState extends State<LectureDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late VideoPlayerController _videoPlayerController;
  late CustomVideoPlayerController _customVideoPlayerController;
  bool _isVideoInitialized = false;

  final CustomVideoPlayerSettings
  _customVideoPlayerSettings = CustomVideoPlayerSettings(
    showSeekButtons: true,
    alwaysShowThumbnailOnVideoPaused: true,
    controlBarDecoration: const BoxDecoration(color: Colors.transparent),
    customAspectRatio: 16 / 9,
    customVideoPlayerProgressBarSettings: CustomVideoPlayerProgressBarSettings(
      backgroundColor: Color(0xff494b4c),
      bufferedColor: Color(0xffbdbdbd).withValues(alpha: 0.5),
      progressBarBorderRadius: 4,
      progressBarHeight: 8,
      progressColor: Color(0xFFF4B400),
    ),
    durationPlayedTextStyle: TextStyle(
      color: AppColors.background,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    durationRemainingTextStyle: TextStyle(
      color: AppColors.background,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    playbackButtonTextStyle: TextStyle(
      color: AppColors.background,
      fontSize: 12,
    ),
    placeholderWidget: Center(child: CircularProgressIndicator.adaptive()),
    pauseButton: Icon(Icons.pause, size: 25, color: AppColors.background),
    playButton: Icon(Icons.play_arrow, size: 25, color: AppColors.background),
    thumbnailWidget: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/learning.png'),
          fit: BoxFit.cover,
        ),
      ),
    ),
    settingsButton: Icon(Icons.settings, size: 25, color: AppColors.background),
  );

  @override
  void initState() {
    super.initState();
    _videoPlayerController =
        VideoPlayerController.networkUrl(
            Uri.parse(
              'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
            ),
          )
          ..initialize().then((_) {
            setState(() {});
          });

    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isVideoInitialized) {
      _customVideoPlayerController = CustomVideoPlayerController(
        context: context,
        videoPlayerController: _videoPlayerController,
        customVideoPlayerSettings: _customVideoPlayerSettings,
      );
      _isVideoInitialized = true;
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _customVideoPlayerController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: widget.lecture['title'] ?? 'Lecture',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Column(
        children: [
          // // Breadcrumb
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          //   child: Row(
          //     children: [
          //       Text(
          //         'Courses',
          //         style: TextStyle(color: AppColors.text.withValues(alpha: 0.6), fontSize: 14),
          //       ),
          //       Text(' / ', style: TextStyle(color: AppColors.text.withValues(alpha: 0.6))),
          //       Text(
          //         'Principles of Disease',
          //         style: TextStyle(color: AppColors.text.withValues(alpha: 0.6), fontSize: 14),
          //       ),
          //       Text(' / ', style: TextStyle(color: AppColors.text.withValues(alpha: 0.6))),
          //       Text(
          //         'Cell Injury and Death',
          //         style: TextStyle(
          //           color: AppColors.text,
          //           fontSize: 14,
          //           fontWeight: FontWeight.w500,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.lecture['title'],
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ),
          ),

          SizedBox(height: 16),

          // Tabs (Slides, Summary, Resources, Usmle, Video)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.text.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Color(0xFFF4B400),
              unselectedLabelColor: AppColors.text.withValues(alpha: 0.6),
              indicatorColor: Color(0xFFF4B400),
              indicatorWeight: 3,
              labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              unselectedLabelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              tabs: [
                Tab(text: 'Slides'),
                Tab(text: 'Summary'),
                Tab(text: 'Resources'),
                Tab(text: 'Usmle'),
                Tab(text: 'Video'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSlidesTab(),
                _buildSummaryTab(),
                _buildResourcesTab(),
                _buildUsmleTab(),
                _buildVideoTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlidesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.slideshow,
            size: 80,
            color: AppColors.text.withValues(alpha: 0.4),
          ),
          SizedBox(height: 16),
          Text(
            'Lecture slides will appear here',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.text.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    final keyPoints = widget.lecture['keyPoints'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lecture Summary',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 16),
          Text(
            widget.lecture['description'] ?? '',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.text.withValues(alpha: 0.7),
              height: 1.6,
            ),
          ),
          SizedBox(height: 32),
          Text(
            'Key Learning Points:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 16),
          ...keyPoints.map((point) => _buildKeyPoint(point.toString())),
          SizedBox(height: 32),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFF4B400).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color(0xFFF4B400).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.quiz_outlined, color: Color(0xFFF4B400), size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'USMLE Practice Questions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${widget.lecture['usmleQuestions'] ?? 0} questions available for this lecture',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.text.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Color(0xFFF4B400),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.text.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesTab() {
    final resources = widget.lecture['resources'] as List<dynamic>? ?? [];

    if (resources.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 80,
              color: AppColors.text.withValues(alpha: 0.4),
            ),
            SizedBox(height: 16),
            Text(
              'No resources available',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.text.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final resource = resources[index] as Map<String, dynamic>;
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0xFFF4B400).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.picture_as_pdf,
                    color: Color(0xFFF4B400),
                    size: 28,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resource['title'] ?? 'Resource ${index + 1}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${resource['type'] ?? 'PDF'} Document - ${resource['size'] ?? '0 MB'}',
                        style: TextStyle(
                          color: AppColors.text.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                      ),
                      if (resource['description'] != null) ...[
                        SizedBox(height: 4),
                        Text(
                          resource['description'],
                          style: TextStyle(
                            color: AppColors.text.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Color(0xFFF4B400)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'View',
                    style: TextStyle(color: Color(0xFFF4B400)),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUsmleTab() {
    final questionCount = widget.lecture['usmleQuestions'] ?? 0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF4B400).withValues(alpha: 0.2),
                  Color(0xFFF4B400).withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Color(0xFFF4B400).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFF4B400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.quiz, size: 40, color: Colors.white),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'USMLE Practice Questions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '$questionCount questions available',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.text.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Question Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 16),
          _buildQuestionCategory(
            'Pathophysiology',
            (questionCount * 0.4).round(),
            Icons.science,
          ),
          _buildQuestionCategory(
            'Clinical Correlation',
            (questionCount * 0.3).round(),
            Icons.medical_services,
          ),
          _buildQuestionCategory(
            'Diagnosis',
            (questionCount * 0.2).round(),
            Icons.assessment,
          ),
          _buildQuestionCategory(
            'Management',
            (questionCount * 0.1).round(),
            Icons.healing,
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF4B400),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Start Practice Questions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCategory(String title, int count, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.text.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFF4B400).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Color(0xFFF4B400), size: 24),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0xFFF4B400).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count Qs',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF4B400),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoTab() {
    return Container(
      color: AppColors.text,
      child: Center(
        child: _videoPlayerController.value.isInitialized
            ? CustomVideoPlayer(
                customVideoPlayerController: _customVideoPlayerController,
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}
