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

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.rating,
    required this.thumbnailUrl,
    required this.sections,
    required this.price,
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
    };
  }
}

final graphicDesignCourseData = {
  'id': 'gd-101',
  'title': 'Graphic Design Fundamentals',
  'description':
      'Learn the basics of graphic design and apply them to real projects,Learn the basics of graphic design and apply them to real projects,Learn the basics of graphic design and apply them to real projects,Learn the basics of graphic design and apply them to real projects,Learn the basics of graphic design and apply them to real projects',
  'instructor': 'محمد أحمد',
  'rating': 4.5,
  'thumbnailUrl': 'assets/images/arabic.png',
  'price': 12.0,
  'sections': [
    {
      'id': '01',
      'title': 'Introduction',
      'totalDurationMinutes': 25,
      'lessons': [
        {
          'id': '01',
          'title': 'Why Using Graphic Design',
          'durationMinutes': 15,
          'isCompleted': false,
          'videoUrl': 'assets/videos/intro_why.mp4',
        },
        {
          'id': '02',
          'title': 'Setup Your Graphic Design Environment',
          'durationMinutes': 10,
          'isCompleted': false,
          'videoUrl': 'assets/videos/intro_setup.mp4',
        },
      ],
    },
    {
      'id': '02',
      'title': 'Solve Quizes',
      'totalDurationMinutes': 55,
      'lessons': [
        {
          'id': '01',
          'title': 'Solve Quizes',
          'durationMinutes': 55,
          'isCompleted': false,
          'videoUrl': 'assets/videos/quiz.mp4',
        },
        {
          'id': '02',
          'title': 'Solve Quizes',
          'durationMinutes': 55,
          'isCompleted': false,
          'videoUrl': 'assets/videos/quiz.mp4',
        },
        {
          'id': '03',
          'title': 'Solve Quizes',
          'durationMinutes': 55,
          'isCompleted': false,
          'videoUrl': 'assets/videos/quiz.mp4',
        },
      ],
    },
  ],
};
