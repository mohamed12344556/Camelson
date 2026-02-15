// import 'package:hive_ce/hive.dart';

// part 'course_section.g.dart';

// @HiveType(typeId: 0)
class CourseSection {
  final String id;
  final String title;
  final int totalDurationMinutes;
  final List<CourseLesson> lessons;

  CourseSection({
    required this.id,
    required this.title,
    required this.totalDurationMinutes,
    required this.lessons,
  });

  // للتحويل من JSON
  factory CourseSection.fromJson(Map<String, dynamic> json) {
    return CourseSection(
      id: json['id'],
      title: json['title'],
      totalDurationMinutes: json['totalDurationMinutes'],
      lessons:
          (json['lessons'] as List)
              .map((lesson) => CourseLesson.fromJson(lesson))
              .toList(),
    );
  }

  // للتحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'totalDurationMinutes': totalDurationMinutes,
      'lessons': lessons.map((lesson) => lesson.toJson()).toList(),
    };
  }
}

// نموذج للدرس داخل القسم
class CourseLesson {
  final String id;
  final String title;
  final int durationMinutes;
  final bool isCompleted;
  final String? videoUrl;

  CourseLesson({
    required this.id,
    required this.title,
    required this.durationMinutes,
    this.isCompleted = false,
    this.videoUrl,
  });

  // للتحويل من JSON
  factory CourseLesson.fromJson(Map<String, dynamic> json) {
    return CourseLesson(
      id: json['id'],
      title: json['title'],
      durationMinutes: json['durationMinutes'],
      isCompleted: json['isCompleted'] ?? false,
      videoUrl: json['videoUrl'],
    );
  }

  // للتحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'durationMinutes': durationMinutes,
      'isCompleted': isCompleted,
      'videoUrl': videoUrl,
    };
  }
}

// نموذج للدورة الكاملة
class Course {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final double rating;
  final String thumbnailUrl;
  final List<CourseSection> sections;
  final double price;
  final String subject; // Medical subject like "Anatomy", "Physiology", etc.

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.rating,
    required this.thumbnailUrl,
    required this.sections,
    required this.price,
    required this.subject,
  });

  // حساب إجمالي مدة الدورة بالدقائق
  int get totalDurationMinutes {
    return sections.fold(
      0,
      (sum, section) => sum + section.totalDurationMinutes,
    );
  }

  // حساب عدد الدروس الكلي
  int get totalLessons {
    return sections.fold(0, (sum, section) => sum + section.lessons.length);
  }

  // للتحويل من JSON
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      instructor: json['instructor'],
      rating: json['rating'].toDouble(),
      thumbnailUrl: json['thumbnailUrl'],
      sections:
          (json['sections'] as List)
              .map((section) => CourseSection.fromJson(section))
              .toList(),
      price: json['price'].toDouble(),
      subject: json['subject'] ?? 'Medical',
    );
  }

  // للتحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'instructor': instructor,
      'rating': rating,
      'thumbnailUrl': thumbnailUrl,
      'sections': sections.map((section) => section.toJson()).toList(),
      'price': price,
      'subject': subject,
    };
  }
}

final graphicDesignCourseData = {
  'id': 'med-anatomy-101',
  'title': 'Human Anatomy - Complete Course',
  'subject': 'Anatomy',
  'description':
      'Comprehensive human anatomy course covering all major body systems. Learn anatomical structures, functions, and clinical correlations essential for medical practice. Includes detailed lectures on skeletal, muscular, cardiovascular, respiratory, digestive, nervous, and reproductive systems with clinical case studies and examination preparation.',
  'instructor': 'Prof. Ahmed Hassan',
  'rating': 4.9,
  'thumbnailUrl': 'assets/images/learning.png',
  'price': 850.0,
  'sections': [
    {
      'id': '01',
      'title': 'Introduction to Anatomy',
      'totalDurationMinutes': 90,
      'lessons': [
        {
          'id': '01',
          'title': 'Anatomical Terminology and Body Planes',
          'durationMinutes': 45,
          'isCompleted': false,
          'videoUrl': 'assets/videos/anatomy_intro_terminology.mp4',
        },
        {
          'id': '02',
          'title': 'Basic Anatomical Structures and Systems Overview',
          'durationMinutes': 45,
          'isCompleted': false,
          'videoUrl': 'assets/videos/anatomy_intro_systems.mp4',
        },
      ],
    },
    {
      'id': '02',
      'title': 'Skeletal System',
      'totalDurationMinutes': 180,
      'lessons': [
        {
          'id': '01',
          'title': 'Axial Skeleton - Skull and Vertebral Column',
          'durationMinutes': 60,
          'isCompleted': false,
          'videoUrl': 'assets/videos/skeletal_axial.mp4',
        },
        {
          'id': '02',
          'title': 'Appendicular Skeleton - Upper Limb',
          'durationMinutes': 60,
          'isCompleted': false,
          'videoUrl': 'assets/videos/skeletal_upper.mp4',
        },
        {
          'id': '03',
          'title': 'Appendicular Skeleton - Lower Limb',
          'durationMinutes': 60,
          'isCompleted': false,
          'videoUrl': 'assets/videos/skeletal_lower.mp4',
        },
      ],
    },
    {
      'id': '03',
      'title': 'Muscular System',
      'totalDurationMinutes': 150,
      'lessons': [
        {
          'id': '01',
          'title': 'Muscle Types and Structure',
          'durationMinutes': 50,
          'isCompleted': false,
          'videoUrl': 'assets/videos/muscle_types.mp4',
        },
        {
          'id': '02',
          'title': 'Major Muscle Groups and Functions',
          'durationMinutes': 50,
          'isCompleted': false,
          'videoUrl': 'assets/videos/muscle_groups.mp4',
        },
        {
          'id': '03',
          'title': 'Clinical Correlations - Muscle Disorders',
          'durationMinutes': 50,
          'isCompleted': false,
          'videoUrl': 'assets/videos/muscle_clinical.mp4',
        },
      ],
    },
    {
      'id': '04',
      'title': 'Cardiovascular System',
      'totalDurationMinutes': 120,
      'lessons': [
        {
          'id': '01',
          'title': 'Heart Anatomy and Circulation',
          'durationMinutes': 60,
          'isCompleted': false,
          'videoUrl': 'assets/videos/cardio_heart.mp4',
        },
        {
          'id': '02',
          'title': 'Major Blood Vessels and Pathways',
          'durationMinutes': 60,
          'isCompleted': false,
          'videoUrl': 'assets/videos/cardio_vessels.mp4',
        },
      ],
    },
    {
      'id': '05',
      'title': 'Nervous System',
      'totalDurationMinutes': 200,
      'lessons': [
        {
          'id': '01',
          'title': 'Central Nervous System - Brain Anatomy',
          'durationMinutes': 70,
          'isCompleted': false,
          'videoUrl': 'assets/videos/neuro_brain.mp4',
        },
        {
          'id': '02',
          'title': 'Spinal Cord and Peripheral Nerves',
          'durationMinutes': 65,
          'isCompleted': false,
          'videoUrl': 'assets/videos/neuro_spinal.mp4',
        },
        {
          'id': '03',
          'title': 'Cranial Nerves and Clinical Testing',
          'durationMinutes': 65,
          'isCompleted': false,
          'videoUrl': 'assets/videos/neuro_cranial.mp4',
        },
      ],
    },
  ],
};
