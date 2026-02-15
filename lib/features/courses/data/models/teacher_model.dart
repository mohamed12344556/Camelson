class TeacherModel {
  final String id;
  final String name;
  final String subject;
  final String profileImage;
  final int studentsEnrolled;
  final double rating;
  final String description;
  final List<String> grades; // ['1 Secondary', '2 Secondary', '3 Secondary']
  final List<TeacherCourse> courses;
  final List<TeacherReview> reviews;
  final int? yearsOfExperience; // Added field
  final bool? verified; // Added field

  TeacherModel({
    required this.id,
    required this.name,
    required this.subject,
    required this.profileImage,
    required this.studentsEnrolled,
    required this.rating,
    required this.description,
    required this.grades,
    required this.courses,
    required this.reviews,
    this.yearsOfExperience, // Added parameter
    this.verified, // Added parameter
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      subject: json['subject'] ?? '',
      profileImage: json['profileImage'] ?? '',
      studentsEnrolled: json['studentsEnrolled'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      grades: List<String>.from(json['grades'] ?? []),
      courses:
          (json['courses'] as List? ?? [])
              .map((course) => TeacherCourse.fromJson(course))
              .toList(),
      reviews:
          (json['reviews'] as List? ?? [])
              .map((review) => TeacherReview.fromJson(review))
              .toList(),
      yearsOfExperience: json['yearsOfExperience'], // Added field
      verified: json['verified'], // Added field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subject': subject,
      'profileImage': profileImage,
      'studentsEnrolled': studentsEnrolled,
      'rating': rating,
      'description': description,
      'grades': grades,
      'courses': courses.map((course) => course.toJson()).toList(),
      'reviews': reviews.map((review) => review.toJson()).toList(),
      'yearsOfExperience': yearsOfExperience, // Added field
      'verified': verified, // Added field
    };
  }
}

class TeacherCourse {
  final String id;
  final String grade; // e.g., '3 Secondary'
  final String price;
  final int totalVideos;
  final List<CourseLessonItem> lessons;
  final double studentProgress; // Progress percentage for enrolled students

  TeacherCourse({
    required this.id,
    required this.grade,
    required this.price,
    required this.totalVideos,
    required this.lessons,
    this.studentProgress = 0.0,
  });

  factory TeacherCourse.fromJson(Map<String, dynamic> json) {
    return TeacherCourse(
      id: json['id'] ?? '',
      grade: json['grade'] ?? '',
      price: json['price'] ?? '',
      totalVideos: json['totalVideos'] ?? 0,
      lessons:
          (json['lessons'] as List? ?? [])
              .map((lesson) => CourseLessonItem.fromJson(lesson))
              .toList(),
      studentProgress: (json['studentProgress'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'grade': grade,
      'price': price,
      'totalVideos': totalVideos,
      'lessons': lessons.map((lesson) => lesson.toJson()).toList(),
      'studentProgress': studentProgress,
    };
  }
}

class CourseLessonItem {
  final String id;
  final String title;
  final String subtitle;
  final bool isFree;
  final bool isLocked;
  final String? videoUrl;
  final String thumbnailUrl;

  CourseLessonItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.isFree,
    required this.isLocked,
    this.videoUrl,
    required this.thumbnailUrl,
  });

  factory CourseLessonItem.fromJson(Map<String, dynamic> json) {
    return CourseLessonItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      isFree: json['isFree'] ?? false,
      isLocked: json['isLocked'] ?? true,
      videoUrl: json['videoUrl'],
      thumbnailUrl: json['thumbnailUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'isFree': isFree,
      'isLocked': isLocked,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
    };
  }
}

// Extended Review Model for Teacher
class TeacherReview {
  final String id;
  final String studentName;
  final String studentImage;
  final String studentGrade; // e.g., '1 secondary'
  final double rating;
  final String comment;
  final DateTime datePosted;

  TeacherReview({
    required this.id,
    required this.studentName,
    required this.studentImage,
    required this.studentGrade,
    required this.rating,
    required this.comment,
    required this.datePosted,
  });

  factory TeacherReview.fromJson(Map<String, dynamic> json) {
    return TeacherReview(
      id: json['id'] ?? '',
      studentName: json['studentName'] ?? '',
      studentImage: json['studentImage'] ?? '',
      studentGrade: json['studentGrade'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      comment: json['comment'] ?? '',
      datePosted: DateTime.parse(
        json['datePosted'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentName': studentName,
      'studentImage': studentImage,
      'studentGrade': studentGrade,
      'rating': rating,
      'comment': comment,
      'datePosted': datePosted.toIso8601String(),
    };
  }
}

// Sample data - Medical Professor
final sampleTeacher = TeacherModel(
  id: 'teacher_1',
  name: 'Prof. Ahmed Hassan',
  subject: 'Anatomy Professor',
  profileImage: 'assets/images/person2.png',
  studentsEnrolled: 2500,
  rating: 4.9,
  description:
      'Professor of Human Anatomy with over 20 years of experience in medical education. Specialized in neuroanatomy, clinical anatomy, and surgical anatomy. Published numerous research papers and textbooks on anatomical sciences. Passionate about teaching medical students through interactive lectures and clinical correlations.',
  grades: ['First Year', 'Second Year', 'Third Year'],
  yearsOfExperience: 20,
  verified: true,
  courses: [
    TeacherCourse(
      id: 'course_anatomy_1st',
      grade: 'First Year',
      price: '850 EGP',
      totalVideos: 45,
      studentProgress: 65.0, // للطلاب المسجلين فقط
      lessons: [
        CourseLessonItem(
          id: '1',
          title: 'Introduction to Human Anatomy',
          subtitle: 'Overview of anatomical terminology and body systems',
          isFree: true,
          isLocked: false,
          thumbnailUrl: 'assets/images/learning.png',
        ),
        CourseLessonItem(
          id: '2',
          title: 'Skeletal System - Part 1',
          subtitle: 'Axial skeleton: Skull and vertebral column',
          isFree: false,
          isLocked: false,
          thumbnailUrl: 'assets/images/learning.png',
        ),
        CourseLessonItem(
          id: '3',
          title: 'Muscular System',
          subtitle: 'Major muscle groups and their clinical significance',
          isFree: false,
          isLocked: true,
          thumbnailUrl: 'assets/images/learning.png',
        ),
        CourseLessonItem(
          id: '4',
          title: 'Cardiovascular System',
          subtitle: 'Heart anatomy and major blood vessels',
          isFree: false,
          isLocked: true,
          thumbnailUrl: 'assets/images/learning.png',
        ),
      ],
    ),
  ],
  reviews: [
    TeacherReview(
      id: '1',
      studentName: 'Ahmed Mohamed',
      studentImage: '',
      studentGrade: 'First Year Medical Student',
      rating: 5,
      comment: 'Excellent professor! His lectures make anatomy easy to understand with great clinical correlations.',
      datePosted: DateTime.now().subtract(Duration(days: 7)),
    ),
    TeacherReview(
      id: '2',
      studentName: 'Sarah Ali',
      studentImage: '',
      studentGrade: 'Second Year Medical Student',
      rating: 5,
      comment: 'Best anatomy professor I have ever had. Very detailed explanations and helpful exam preparation.',
      datePosted: DateTime.now().subtract(Duration(days: 14)),
    ),
    TeacherReview(
      id: '3',
      studentName: 'Youssef Ibrahim',
      studentImage: '',
      studentGrade: 'First Year Medical Student',
      rating: 4.5,
      comment: 'Great teaching style with practical examples. Highly recommend his courses!',
      datePosted: DateTime.now().subtract(Duration(days: 21)),
    ),
  ],
);
