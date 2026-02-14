class CourseModel {
  final String title;
  final String subject;
  final String instructor;
  final double rating;
  final int studentsCount;
  final String progress; // like "12/31"
  final bool isFree;
  final String image;

  CourseModel({
    required this.title,
    required this.subject,
    required this.instructor,
    required this.rating,
    required this.studentsCount,
    required this.progress,
    required this.isFree,
    required this.image,
  });
}