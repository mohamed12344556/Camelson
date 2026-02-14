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

// Sample data
final sampleTeacher = TeacherModel(
  id: 'teacher_1',
  name: 'Mr Ahmed',
  subject: 'English Teacher',
  profileImage: 'assets/images/teacher.png',
  studentsEnrolled: 50,
  rating: 4.9,
  description:
      'Lorem ipsum dolor sit amet consectetur. Consectetur bibendum sem eros nisl sem ut sed nunc. Porttitor sit in quis malesuada egestas elit vitae. Sed nam donec habitasse neque tortor augue vel. Eleifend nam quis in eu cras elementum.',
  grades: ['1 Secondary', '2 Secondary', '3 Secondary'],
  yearsOfExperience: 10, // Added field
  verified: true, // Added field
  courses: [
    TeacherCourse(
      id: 'course_3_sec',
      grade: '3 Secondary',
      price: '499\$',
      totalVideos: 20,
      studentProgress: 45.0, // للطلاب المسجلين فقط
      lessons: [
        CourseLessonItem(
          id: '1',
          title: 'Basic Grammars',
          subtitle: 'Learning Basic Drawing letters',
          isFree: true,
          isLocked: false,
          thumbnailUrl: 'assets/images/video_thumb.png',
        ),
        CourseLessonItem(
          id: '2',
          title: 'Basic Grammars',
          subtitle: 'Learning Basic Drawing letters',
          isFree: false,
          isLocked: false,
          thumbnailUrl: 'assets/images/video_thumb.png',
        ),
        // Add more lessons...
      ],
    ),
  ],
  reviews: [
    TeacherReview(
      id: '1',
      studentName: 'Mohamed',
      studentImage: '',
      studentGrade: '1 secondary',
      rating: 5,
      comment: 'Best Teacher',
      datePosted: DateTime.now().subtract(Duration(days: 7)),
    ),
    TeacherReview(
      id: '2',
      studentName: 'Mohamed',
      studentImage: '',
      studentGrade: '2 secondary',
      rating: 4,
      comment: 'Best Teacher',
      datePosted: DateTime.now().subtract(Duration(days: 14)),
    ),
    // Add more reviews...
  ],
);
