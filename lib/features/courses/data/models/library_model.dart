class LibraryModel {
  final String id;
  final String title;
  final String description;
  final String year; // e.g., "First Year", "Second Year"
  final int subscribersCount;
  final double price;
  final String imageUrl;
  final List<LectureModel> lectures;

  LibraryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.year,
    required this.subscribersCount,
    required this.price,
    required this.imageUrl,
    this.lectures = const [],
  });
}

class LectureModel {
  final String id;
  final String title;
  final String description;
  final String type; // "Intro", "Core", "Case Study", "Q&A"
  final String duration;
  final bool isCompleted;

  LectureModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.duration,
    this.isCompleted = false,
  });
}
