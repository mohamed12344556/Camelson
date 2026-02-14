import '../../data/models/subject_roadmap_model.dart';

// Data classes for roadmap items
class RoadmapItemData {
  final RoadmapItemType type;
  final ChapterModel? chapter;
  final LessonModel? lesson;

  RoadmapItemData({required this.type, this.chapter, this.lesson});
}

enum RoadmapItemType { chapter, lesson }