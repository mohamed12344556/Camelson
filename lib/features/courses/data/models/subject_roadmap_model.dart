// // Models for the roadmap
// import 'package:flutter/material.dart';

// class SubjectRoadmap {
//   final String id;
//   final String subjectName;
//   final String subjectImage;
//   final int totalChapters;
//   final int completedChapters;
//   final List<ChapterModel> chapters;
//   final double overallProgress;

//   SubjectRoadmap({
//     required this.id,
//     required this.subjectName,
//     required this.subjectImage,
//     required this.totalChapters,
//     required this.completedChapters,
//     required this.chapters,
//     required this.overallProgress,
//   });

//   factory SubjectRoadmap.fromJson(Map<String, dynamic> json) {
//     return SubjectRoadmap(
//       id: json['id'],
//       subjectName: json['subjectName'],
//       subjectImage: json['subjectImage'],
//       totalChapters: json['totalChapters'],
//       completedChapters: json['completedChapters'],
//       chapters:
//           (json['chapters'] as List)
//               .map((chapter) => ChapterModel.fromJson(chapter))
//               .toList(),
//       overallProgress: json['overallProgress'].toDouble(),
//     );
//   }
// }

// class ChapterModel {
//   final String id;
//   final String title;
//   final String description;
//   final int chapterNumber;
//   final List<LessonModel> lessons;
//   final bool isLocked;
//   final bool isCompleted;
//   final double progress;
//   final String thumbnailUrl;
//   final Color chapterColor;

//   ChapterModel({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.chapterNumber,
//     required this.lessons,
//     required this.isLocked,
//     required this.isCompleted,
//     required this.progress,
//     required this.thumbnailUrl,
//     required this.chapterColor,
//   });

//   // Add the missing getter for currentLesson
//   int get currentLesson {
//     // Find the current lesson number, or return the next incomplete lesson
//     for (var lesson in lessons) {
//       if (lesson.isCurrent) {
//         return lesson.lessonNumber;
//       }
//     }

//     // If no current lesson, find the first incomplete lesson
//     for (var lesson in lessons) {
//       if (!lesson.isCompleted) {
//         return lesson.lessonNumber;
//       }
//     }

//     // If all lessons are completed, return the last lesson number
//     return lessons.isNotEmpty ? lessons.last.lessonNumber : 1;
//   }

//   // Add the missing getter for chapterName (alias for title)
//   String get chapterName => title;

//   factory ChapterModel.fromJson(Map<String, dynamic> json) {
//     return ChapterModel(
//       id: json['id'],
//       title: json['title'],
//       description: json['description'],
//       chapterNumber: json['chapterNumber'],
//       lessons:
//           (json['lessons'] as List)
//               .map((lesson) => LessonModel.fromJson(lesson))
//               .toList(),
//       isLocked: json['isLocked'] ?? false,
//       isCompleted: json['isCompleted'] ?? false,
//       progress: json['progress']?.toDouble() ?? 0.0,
//       thumbnailUrl: json['thumbnailUrl'] ?? '',
//       chapterColor: Color(json['chapterColor'] ?? 0xFF167F71),
//     );
//   }
// }

// class LessonModel {
//   final String id;
//   final String title;
//   final String description;
//   final int lessonNumber;
//   final int durationMinutes;
//   final bool isCompleted;
//   final bool isLocked;
//   final bool isCurrent;
//   final String? videoUrl;
//   final String thumbnailUrl;
//   final LessonType type;

//   LessonModel({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.lessonNumber,
//     required this.durationMinutes,
//     required this.isCompleted,
//     required this.isLocked,
//     required this.isCurrent,
//     this.videoUrl,
//     required this.thumbnailUrl,
//     required this.type,
//   });

//   factory LessonModel.fromJson(Map<String, dynamic> json) {
//     return LessonModel(
//       id: json['id'],
//       title: json['title'],
//       description: json['description'],
//       lessonNumber: json['lessonNumber'],
//       durationMinutes: json['durationMinutes'],
//       isCompleted: json['isCompleted'] ?? false,
//       isLocked: json['isLocked'] ?? false,
//       isCurrent: json['isCurrent'] ?? false,
//       videoUrl: json['videoUrl'],
//       thumbnailUrl: json['thumbnailUrl'] ?? '',
//       type: LessonType.values[json['type'] ?? 0],
//     );
//   }
// }

// enum LessonType { video, quiz, assignment, reading }

// // Sample data
// final sampleRoadmapData = SubjectRoadmap(
//   id: 'english-roadmap',
//   subjectName: 'English',
//   subjectImage: 'assets/images/english_subject.png',
//   totalChapters: 3,
//   completedChapters: 1,
//   overallProgress: 70.0,
//   chapters: [
//     ChapterModel(
//       id: 'ch1',
//       title: 'Chapter One - Grammar Basics',
//       description: 'Learn the fundamentals of English grammar',
//       chapterNumber: 1,
//       isLocked: false,
//       isCompleted: true,
//       progress: 100.0,
//       thumbnailUrl: 'assets/images/chapter1.png',
//       chapterColor: Color(0xFF4CAF50),
//       lessons: [
//         LessonModel(
//           id: 'l1',
//           title: 'Introduction to Grammar',
//           description: 'Basic concepts and rules',
//           lessonNumber: 1,
//           durationMinutes: 15,
//           isCompleted: true,
//           isLocked: false,
//           isCurrent: false,
//           thumbnailUrl: 'assets/images/lesson1.png',
//           type: LessonType.video,
//         ),
//         LessonModel(
//           id: 'l2',
//           title: 'Parts of Speech',
//           description: 'Nouns, verbs, adjectives and more',
//           lessonNumber: 2,
//           durationMinutes: 20,
//           isCompleted: true,
//           isLocked: false,
//           isCurrent: false,
//           thumbnailUrl: 'assets/images/lesson2.png',
//           type: LessonType.video,
//         ),
//         LessonModel(
//           id: 'l3',
//           title: 'Grammar Quiz',
//           description: 'Test your knowledge',
//           lessonNumber: 3,
//           durationMinutes: 10,
//           isCompleted: true,
//           isLocked: false,
//           isCurrent: false,
//           thumbnailUrl: 'assets/images/quiz.png',
//           type: LessonType.quiz,
//         ),
//       ],
//     ),
//     ChapterModel(
//       id: 'ch2',
//       title: 'Chapter Two - Vocabulary Building',
//       description: 'Expand your English vocabulary',
//       chapterNumber: 2,
//       isLocked: false,
//       isCompleted: false,
//       progress: 66.6,
//       thumbnailUrl: 'assets/images/chapter2.png',
//       chapterColor: Color(0xFF2196F3),
//       lessons: [
//         LessonModel(
//           id: 'l4',
//           title: 'Common Words',
//           description: '1000 most used words',
//           lessonNumber: 1,
//           durationMinutes: 25,
//           isCompleted: true,
//           isLocked: false,
//           isCurrent: false,
//           thumbnailUrl: 'assets/images/lesson4.png',
//           type: LessonType.video,
//         ),
//         LessonModel(
//           id: 'l5',
//           title: 'Synonyms & Antonyms',
//           description: 'Expand your word choices',
//           lessonNumber: 2,
//           durationMinutes: 30,
//           isCompleted: true,
//           isLocked: false,
//           isCurrent: true,
//           thumbnailUrl: 'assets/images/lesson5.png',
//           type: LessonType.video,
//         ),
//         LessonModel(
//           id: 'l6',
//           title: 'Vocabulary Practice',
//           description: 'Interactive exercises',
//           lessonNumber: 3,
//           durationMinutes: 15,
//           isCompleted: false,
//           isLocked: false,
//           isCurrent: false,
//           thumbnailUrl: 'assets/images/practice.png',
//           type: LessonType.assignment,
//         ),
//       ],
//     ),
//     ChapterModel(
//       id: 'ch3',
//       title: 'Chapter Three - Speaking Skills',
//       description: 'Improve your English speaking',
//       chapterNumber: 3,
//       isLocked: true,
//       isCompleted: false,
//       progress: 0.0,
//       thumbnailUrl: 'assets/images/chapter3.png',
//       chapterColor: Color(0xFFFF9800),
//       lessons: [
//         LessonModel(
//           id: 'l7',
//           title: 'Pronunciation Guide',
//           description: 'Master English sounds',
//           lessonNumber: 1,
//           durationMinutes: 35,
//           isCompleted: false,
//           isLocked: true,
//           isCurrent: false,
//           thumbnailUrl: 'assets/images/lesson7.png',
//           type: LessonType.video,
//         ),
//         LessonModel(
//           id: 'l8',
//           title: 'Conversation Practice',
//           description: 'Real-life dialogues',
//           lessonNumber: 2,
//           durationMinutes: 40,
//           isCompleted: false,
//           isLocked: true,
//           isCurrent: false,
//           thumbnailUrl: 'assets/images/lesson8.png',
//           type: LessonType.video,
//         ),
//       ],
//     ),
//   ],
// );


import 'package:flutter/material.dart';

class SubjectRoadmap {
  final String subjectName;
  final double overallProgress;
  final List<ChapterModel> chapters;
  final String? description;
  final String? imageUrl;
  final int? totalLessons;
  final int? completedLessons;
  final DateTime? lastAccessed;
  final int? totalXp;
  final int? earnedXp;

  SubjectRoadmap({
    required this.subjectName,
    required this.overallProgress,
    required this.chapters,
    this.description,
    this.imageUrl,
    this.totalLessons,
    this.completedLessons,
    this.lastAccessed,
    this.totalXp,
    this.earnedXp,
  });

  // Calculate total lessons dynamically
  int get calculatedTotalLessons {
    return chapters.fold(0, (sum, chapter) => sum + chapter.lessons.length);
  }

  // Calculate completed lessons dynamically
  int get calculatedCompletedLessons {
    return chapters.fold(
      0,
      (sum, chapter) =>
          sum + chapter.lessons.where((lesson) => lesson.isCompleted).length,
    );
  }

  // Calculate total XP dynamically
  int get calculatedTotalXp {
    return chapters.fold(
      0,
      (sum, chapter) =>
          sum +
          chapter.lessons.fold(
            0,
            (lessonSum, lesson) => lessonSum + lesson.xpReward,
          ),
    );
  }

  // Calculate earned XP dynamically
  int get calculatedEarnedXp {
    return chapters.fold(
      0,
      (sum, chapter) =>
          sum +
          chapter.lessons
              .where((lesson) => lesson.isCompleted)
              .fold(0, (lessonSum, lesson) => lessonSum + lesson.xpReward),
    );
  }

  // Get current chapter
  ChapterModel? get currentChapter {
    return chapters.firstWhere(
      (chapter) => !chapter.isCompleted && !chapter.isLocked,
      orElse: () => chapters.last,
    );
  }

  // Get current lesson
  LessonModel? get currentLesson {
    for (var chapter in chapters) {
      final currentLesson = chapter.lessons.firstWhere(
        (lesson) => lesson.isCurrent,
        orElse: () => LessonModel.empty(),
      );
      if (currentLesson.lessonNumber != 0) return currentLesson;
    }
    return null;
  }

  SubjectRoadmap copyWith({
    String? subjectName,
    double? overallProgress,
    List<ChapterModel>? chapters,
    String? description,
    String? imageUrl,
    int? totalLessons,
    int? completedLessons,
    DateTime? lastAccessed,
    int? totalXp,
    int? earnedXp,
  }) {
    return SubjectRoadmap(
      subjectName: subjectName ?? this.subjectName,
      overallProgress: overallProgress ?? this.overallProgress,
      chapters: chapters ?? this.chapters,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      totalLessons: totalLessons ?? this.totalLessons,
      completedLessons: completedLessons ?? this.completedLessons,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      totalXp: totalXp ?? this.totalXp,
      earnedXp: earnedXp ?? this.earnedXp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectName': subjectName,
      'overallProgress': overallProgress,
      'chapters': chapters.map((x) => x.toJson()).toList(),
      'description': description,
      'imageUrl': imageUrl,
      'totalLessons': totalLessons,
      'completedLessons': completedLessons,
      'lastAccessed': lastAccessed?.toIso8601String(),
      'totalXp': totalXp,
      'earnedXp': earnedXp,
    };
  }

  factory SubjectRoadmap.fromJson(Map<String, dynamic> json) {
    return SubjectRoadmap(
      subjectName: json['subjectName'],
      overallProgress: json['overallProgress']?.toDouble() ?? 0.0,
      chapters: List<ChapterModel>.from(
        json['chapters']?.map((x) => ChapterModel.fromJson(x)) ?? [],
      ),
      description: json['description'],
      imageUrl: json['imageUrl'],
      totalLessons: json['totalLessons'],
      completedLessons: json['completedLessons'],
      lastAccessed:
          json['lastAccessed'] != null
              ? DateTime.parse(json['lastAccessed'])
              : null,
      totalXp: json['totalXp'],
      earnedXp: json['earnedXp'],
    );
  }
}

class ChapterModel {
  final int chapterNumber;
  final String chapterName;
  final String title;
  final String description;
  final Color chapterColor;
  final double progress;
  final int currentLesson;
  final bool isCompleted;
  final bool isLocked;
  final List<LessonModel> lessons;
  final String? imageUrl;
  final int? estimatedDuration;
  final List<String>? prerequisites;
  final List<String>? learningObjectives;
  final ChapterDifficulty? difficulty;

  ChapterModel({
    required this.chapterNumber,
    required this.chapterName,
    required this.title,
    required this.description,
    required this.chapterColor,
    required this.progress,
    required this.currentLesson,
    required this.isCompleted,
    required this.isLocked,
    required this.lessons,
    this.imageUrl,
    this.estimatedDuration,
    this.prerequisites,
    this.learningObjectives,
    this.difficulty,
  });

  // Calculate progress based on completed lessons
  double get calculatedProgress {
    if (lessons.isEmpty) return 0.0;
    final completedCount = lessons.where((lesson) => lesson.isCompleted).length;
    return (completedCount / lessons.length) * 100;
  }

  // Get total duration of all lessons
  int get totalDuration {
    return lessons.fold(0, (sum, lesson) => sum + lesson.durationMinutes);
  }

  // Get total XP for chapter
  int get totalXp {
    return lessons.fold(0, (sum, lesson) => sum + lesson.xpReward);
  }

  // Get earned XP for chapter
  int get earnedXp {
    return lessons
        .where((lesson) => lesson.isCompleted)
        .fold(0, (sum, lesson) => sum + lesson.xpReward);
  }

  ChapterModel copyWith({
    int? chapterNumber,
    String? chapterName,
    String? title,
    String? description,
    Color? chapterColor,
    double? progress,
    int? currentLesson,
    bool? isCompleted,
    bool? isLocked,
    List<LessonModel>? lessons,
    String? imageUrl,
    int? estimatedDuration,
    List<String>? prerequisites,
    List<String>? learningObjectives,
    ChapterDifficulty? difficulty,
  }) {
    return ChapterModel(
      chapterNumber: chapterNumber ?? this.chapterNumber,
      chapterName: chapterName ?? this.chapterName,
      title: title ?? this.title,
      description: description ?? this.description,
      chapterColor: chapterColor ?? this.chapterColor,
      progress: progress ?? this.progress,
      currentLesson: currentLesson ?? this.currentLesson,
      isCompleted: isCompleted ?? this.isCompleted,
      isLocked: isLocked ?? this.isLocked,
      lessons: lessons ?? this.lessons,
      imageUrl: imageUrl ?? this.imageUrl,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      prerequisites: prerequisites ?? this.prerequisites,
      learningObjectives: learningObjectives ?? this.learningObjectives,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapterNumber': chapterNumber,
      'chapterName': chapterName,
      'title': title,
      'description': description,
      'chapterColor': chapterColor.value,
      'progress': progress,
      'currentLesson': currentLesson,
      'isCompleted': isCompleted,
      'isLocked': isLocked,
      'lessons': lessons.map((x) => x.toJson()).toList(),
      'imageUrl': imageUrl,
      'estimatedDuration': estimatedDuration,
      'prerequisites': prerequisites,
      'learningObjectives': learningObjectives,
      'difficulty': difficulty?.toString(),
    };
  }

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      chapterNumber: json['chapterNumber'],
      chapterName: json['chapterName'],
      title: json['title'],
      description: json['description'],
      chapterColor: Color(json['chapterColor'] ?? Colors.blue.value),
      progress: json['progress']?.toDouble() ?? 0.0,
      currentLesson: json['currentLesson'] ?? 1,
      isCompleted: json['isCompleted'] ?? false,
      isLocked: json['isLocked'] ?? false,
      lessons: List<LessonModel>.from(
        json['lessons']?.map((x) => LessonModel.fromJson(x)) ?? [],
      ),
      imageUrl: json['imageUrl'],
      estimatedDuration: json['estimatedDuration'],
      prerequisites:
          json['prerequisites'] != null
              ? List<String>.from(json['prerequisites'])
              : null,
      learningObjectives:
          json['learningObjectives'] != null
              ? List<String>.from(json['learningObjectives'])
              : null,
      difficulty:
          json['difficulty'] != null
              ? ChapterDifficulty.values.firstWhere(
                (e) => e.toString() == json['difficulty'],
                orElse: () => ChapterDifficulty.beginner,
              )
              : null,
    );
  }
}

class LessonModel {
  final int lessonNumber;
  final String title;
  final LessonType type;
  final int durationMinutes;
  final bool isCompleted;
  final bool isLocked;
  final bool isCurrent;
  final String? description;
  final String? videoUrl;
  final String? thumbnailUrl;
  final List<String>? resources;
  final int xpReward;
  final LessonDifficulty? difficulty;
  final List<String>? tags;
  final DateTime? completedAt;
  final double? progress;

  LessonModel({
    required this.lessonNumber,
    required this.title,
    required this.type,
    required this.durationMinutes,
    required this.isCompleted,
    required this.isLocked,
    required this.isCurrent,
    this.description,
    this.videoUrl,
    this.thumbnailUrl,
    this.resources,
    int? xpReward,
    this.difficulty,
    this.tags,
    this.completedAt,
    this.progress,
  }) : xpReward = xpReward ?? _getDefaultXpReward(type);

  static int _getDefaultXpReward(LessonType type) {
    switch (type) {
      case LessonType.video:
        return 50;
      case LessonType.quiz:
        return 100;
      case LessonType.assignment:
        return 150;
      case LessonType.reading:
        return 75;
    }
  }

  // Empty constructor for default values
  LessonModel.empty()
    : lessonNumber = 0,
      title = '',
      type = LessonType.video,
      durationMinutes = 0,
      isCompleted = false,
      isLocked = false,
      isCurrent = false,
      description = null,
      videoUrl = null,
      thumbnailUrl = null,
      resources = null,
      xpReward = 0,
      difficulty = null,
      tags = null,
      completedAt = null,
      progress = null;

  LessonModel copyWith({
    int? lessonNumber,
    String? title,
    LessonType? type,
    int? durationMinutes,
    bool? isCompleted,
    bool? isLocked,
    bool? isCurrent,
    String? description,
    String? videoUrl,
    String? thumbnailUrl,
    List<String>? resources,
    int? xpReward,
    LessonDifficulty? difficulty,
    List<String>? tags,
    DateTime? completedAt,
    double? progress,
  }) {
    return LessonModel(
      lessonNumber: lessonNumber ?? this.lessonNumber,
      title: title ?? this.title,
      type: type ?? this.type,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      isLocked: isLocked ?? this.isLocked,
      isCurrent: isCurrent ?? this.isCurrent,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      resources: resources ?? this.resources,
      xpReward: xpReward ?? this.xpReward,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      completedAt: completedAt ?? this.completedAt,
      progress: progress ?? this.progress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonNumber': lessonNumber,
      'title': title,
      'type': type.toString(),
      'durationMinutes': durationMinutes,
      'isCompleted': isCompleted,
      'isLocked': isLocked,
      'isCurrent': isCurrent,
      'description': description,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'resources': resources,
      'xpReward': xpReward,
      'difficulty': difficulty?.toString(),
      'tags': tags,
      'completedAt': completedAt?.toIso8601String(),
      'progress': progress,
    };
  }

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      lessonNumber: json['lessonNumber'],
      title: json['title'],
      type: LessonType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => LessonType.video,
      ),
      durationMinutes: json['durationMinutes'],
      isCompleted: json['isCompleted'] ?? false,
      isLocked: json['isLocked'] ?? false,
      isCurrent: json['isCurrent'] ?? false,
      description: json['description'],
      videoUrl: json['videoUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      resources:
          json['resources'] != null
              ? List<String>.from(json['resources'])
              : null,
      xpReward: json['xpReward'],
      difficulty:
          json['difficulty'] != null
              ? LessonDifficulty.values.firstWhere(
                (e) => e.toString() == json['difficulty'],
                orElse: () => LessonDifficulty.beginner,
              )
              : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      completedAt:
          json['completedAt'] != null
              ? DateTime.parse(json['completedAt'])
              : null,
      progress: json['progress']?.toDouble(),
    );
  }
}

enum LessonType { video, quiz, assignment, reading }

enum ChapterDifficulty { beginner, intermediate, advanced, expert }

enum LessonDifficulty { beginner, intermediate, advanced, expert }

// Extension methods for better UX
extension LessonTypeExtension on LessonType {
  String get displayName {
    switch (this) {
      case LessonType.video:
        return 'Video Lesson';
      case LessonType.quiz:
        return 'Quiz Challenge';
      case LessonType.assignment:
        return 'Assignment Quest';
      case LessonType.reading:
        return 'Reading Material';
    }
  }

  String get gamingName {
    switch (this) {
      case LessonType.video:
        return 'WATCH';
      case LessonType.quiz:
        return 'BATTLE';
      case LessonType.assignment:
        return 'QUEST';
      case LessonType.reading:
        return 'STUDY';
    }
  }

  IconData get icon {
    switch (this) {
      case LessonType.video:
        return Icons.play_circle_filled;
      case LessonType.quiz:
        return Icons.psychology;
      case LessonType.assignment:
        return Icons.emoji_events;
      case LessonType.reading:
        return Icons.auto_stories;
    }
  }

  Color get color {
    switch (this) {
      case LessonType.video:
        return Colors.blue;
      case LessonType.quiz:
        return Colors.orange;
      case LessonType.assignment:
        return Colors.purple;
      case LessonType.reading:
        return Colors.green;
    }
  }
}

extension ChapterDifficultyExtension on ChapterDifficulty {
  String get displayName {
    switch (this) {
      case ChapterDifficulty.beginner:
        return 'Beginner';
      case ChapterDifficulty.intermediate:
        return 'Intermediate';
      case ChapterDifficulty.advanced:
        return 'Advanced';
      case ChapterDifficulty.expert:
        return 'Expert';
    }
  }

  Color get color {
    switch (this) {
      case ChapterDifficulty.beginner:
        return Colors.green;
      case ChapterDifficulty.intermediate:
        return Colors.yellow;
      case ChapterDifficulty.advanced:
        return Colors.orange;
      case ChapterDifficulty.expert:
        return Colors.red;
    }
  }

  int get stars {
    switch (this) {
      case ChapterDifficulty.beginner:
        return 1;
      case ChapterDifficulty.intermediate:
        return 2;
      case ChapterDifficulty.advanced:
        return 3;
      case ChapterDifficulty.expert:
        return 4;
    }
  }
}

extension LessonDifficultyExtension on LessonDifficulty {
  String get displayName {
    switch (this) {
      case LessonDifficulty.beginner:
        return 'Beginner';
      case LessonDifficulty.intermediate:
        return 'Intermediate';
      case LessonDifficulty.advanced:
        return 'Advanced';
      case LessonDifficulty.expert:
        return 'Expert';
    }
  }

  Color get color {
    switch (this) {
      case LessonDifficulty.beginner:
        return Colors.green;
      case LessonDifficulty.intermediate:
        return Colors.yellow;
      case LessonDifficulty.advanced:
        return Colors.orange;
      case LessonDifficulty.expert:
        return Colors.red;
    }
  }

  int get stars {
    switch (this) {
      case LessonDifficulty.beginner:
        return 1;
      case LessonDifficulty.intermediate:
        return 2;
      case LessonDifficulty.advanced:
        return 3;
      case LessonDifficulty.expert:
        return 4;
    }
  }
}

// Sample Data Generator
class RoadmapDataGenerator {
  static SubjectRoadmap generateSampleMathRoadmap() {
    return SubjectRoadmap(
      subjectName: 'Mathematics',
      overallProgress: 65.5,
      description:
          'Master the fundamentals of mathematics from basic algebra to advanced calculus',
      chapters: [
        ChapterModel(
          chapterNumber: 1,
          chapterName: 'Basic Algebra',
          title: 'Foundation of Algebra',
          description:
              'Learn the fundamentals of algebraic expressions, equations, and basic problem-solving techniques',
          chapterColor: Colors.blue,
          progress: 100.0,
          currentLesson: 4,
          isCompleted: true,
          isLocked: false,
          difficulty: ChapterDifficulty.beginner,
          estimatedDuration: 180,
          learningObjectives: [
            'Understand variables and constants',
            'Solve linear equations',
            'Work with algebraic expressions',
            'Apply basic algebraic principles',
          ],
          lessons: [
            LessonModel(
              lessonNumber: 1,
              title: 'Introduction to Variables',
              type: LessonType.video,
              durationMinutes: 15,
              isCompleted: true,
              isLocked: false,
              isCurrent: false,
              description:
                  'Learn what variables are and how to use them in mathematical expressions',
              xpReward: 50,
              difficulty: LessonDifficulty.beginner,
              tags: ['variables', 'basics', 'algebra'],
            ),
            LessonModel(
              lessonNumber: 2,
              title: 'Simple Equations',
              type: LessonType.video,
              durationMinutes: 20,
              isCompleted: true,
              isLocked: false,
              isCurrent: false,
              description: 'Solve basic linear equations step by step',
              xpReward: 50,
              difficulty: LessonDifficulty.beginner,
            ),
            LessonModel(
              lessonNumber: 3,
              title: 'Practice Quiz: Basic Algebra',
              type: LessonType.quiz,
              durationMinutes: 10,
              isCompleted: true,
              isLocked: false,
              isCurrent: false,
              description:
                  'Test your understanding of basic algebraic concepts',
              xpReward: 100,
              difficulty: LessonDifficulty.beginner,
            ),
            LessonModel(
              lessonNumber: 4,
              title: 'Algebraic Expressions',
              type: LessonType.reading,
              durationMinutes: 25,
              isCompleted: true,
              isLocked: false,
              isCurrent: false,
              description:
                  'Deep dive into algebraic expressions and their properties',
              xpReward: 75,
              difficulty: LessonDifficulty.intermediate,
            ),
          ],
        ),
        ChapterModel(
          chapterNumber: 2,
          chapterName: 'Quadratic Equations',
          title: 'Mastering Quadratics',
          description:
              'Explore quadratic equations, factoring, and the quadratic formula',
          chapterColor: Colors.purple,
          progress: 66.7,
          currentLesson: 3,
          isCompleted: false,
          isLocked: false,
          difficulty: ChapterDifficulty.intermediate,
          estimatedDuration: 240,
          prerequisites: ['Basic Algebra'],
          learningObjectives: [
            'Solve quadratic equations',
            'Factor quadratic expressions',
            'Use the quadratic formula',
            'Graph parabolas',
          ],
          lessons: [
            LessonModel(
              lessonNumber: 1,
              title: 'Introduction to Quadratics',
              type: LessonType.video,
              durationMinutes: 25,
              isCompleted: true,
              isLocked: false,
              isCurrent: false,
              description:
                  'Understanding the standard form of quadratic equations',
              xpReward: 60,
              difficulty: LessonDifficulty.intermediate,
            ),
            LessonModel(
              lessonNumber: 2,
              title: 'Factoring Quadratics',
              type: LessonType.video,
              durationMinutes: 30,
              isCompleted: true,
              isLocked: false,
              isCurrent: false,
              description:
                  'Learn different methods to factor quadratic expressions',
              xpReward: 60,
              difficulty: LessonDifficulty.intermediate,
            ),
            LessonModel(
              lessonNumber: 3,
              title: 'The Quadratic Formula',
              type: LessonType.video,
              durationMinutes: 20,
              isCompleted: false,
              isLocked: false,
              isCurrent: true,
              description: 'Master the quadratic formula and its applications',
              xpReward: 60,
              difficulty: LessonDifficulty.intermediate,
            ),
            LessonModel(
              lessonNumber: 4,
              title: 'Quadratic Applications',
              type: LessonType.assignment,
              durationMinutes: 45,
              isCompleted: false,
              isLocked: false,
              isCurrent: false,
              description:
                  'Solve real-world problems using quadratic equations',
              xpReward: 150,
              difficulty: LessonDifficulty.advanced,
            ),
            LessonModel(
              lessonNumber: 5,
              title: 'Chapter Quiz: Quadratics',
              type: LessonType.quiz,
              durationMinutes: 15,
              isCompleted: false,
              isLocked: true,
              isCurrent: false,
              description: 'Comprehensive quiz on quadratic equations',
              xpReward: 120,
              difficulty: LessonDifficulty.intermediate,
            ),
          ],
        ),
        ChapterModel(
          chapterNumber: 3,
          chapterName: 'Functions and Graphs',
          title: 'Understanding Functions',
          description:
              'Explore functions, their properties, and graphical representations',
          chapterColor: Colors.green,
          progress: 0.0,
          currentLesson: 1,
          isCompleted: false,
          isLocked: false,
          difficulty: ChapterDifficulty.intermediate,
          estimatedDuration: 300,
          prerequisites: ['Basic Algebra', 'Quadratic Equations'],
          learningObjectives: [
            'Define and identify functions',
            'Graph various types of functions',
            'Understand domain and range',
            'Transform functions',
          ],
          lessons: [
            LessonModel(
              lessonNumber: 1,
              title: 'What is a Function?',
              type: LessonType.video,
              durationMinutes: 20,
              isCompleted: false,
              isLocked: false,
              isCurrent: false,
              description:
                  'Introduction to the concept of mathematical functions',
              xpReward: 60,
              difficulty: LessonDifficulty.intermediate,
            ),
            LessonModel(
              lessonNumber: 2,
              title: 'Domain and Range',
              type: LessonType.video,
              durationMinutes: 25,
              isCompleted: false,
              isLocked: true,
              isCurrent: false,
              description: 'Understanding the domain and range of functions',
              xpReward: 60,
              difficulty: LessonDifficulty.intermediate,
            ),
            LessonModel(
              lessonNumber: 3,
              title: 'Graphing Functions',
              type: LessonType.video,
              durationMinutes: 30,
              isCompleted: false,
              isLocked: true,
              isCurrent: false,
              description: 'Learn to graph various types of functions',
              xpReward: 60,
              difficulty: LessonDifficulty.intermediate,
            ),
            LessonModel(
              lessonNumber: 4,
              title: 'Function Transformations',
              type: LessonType.reading,
              durationMinutes: 35,
              isCompleted: false,
              isLocked: true,
              isCurrent: false,
              description: 'Explore how functions can be transformed',
              xpReward: 80,
              difficulty: LessonDifficulty.advanced,
            ),
            LessonModel(
              lessonNumber: 5,
              title: 'Functions Challenge',
              type: LessonType.assignment,
              durationMinutes: 50,
              isCompleted: false,
              isLocked: true,
              isCurrent: false,
              description: 'Apply function concepts to solve complex problems',
              xpReward: 180,
              difficulty: LessonDifficulty.advanced,
            ),
          ],
        ),
        ChapterModel(
          chapterNumber: 4,
          chapterName: 'Calculus Basics',
          title: 'Introduction to Calculus',
          description:
              'Begin your journey into differential and integral calculus',
          chapterColor: Colors.red,
          progress: 0.0,
          currentLesson: 1,
          isCompleted: false,
          isLocked: true,
          difficulty: ChapterDifficulty.advanced,
          estimatedDuration: 400,
          prerequisites: ['Functions and Graphs'],
          learningObjectives: [
            'Understand limits and continuity',
            'Learn basic differentiation',
            'Introduction to integration',
            'Apply calculus to real problems',
          ],
          lessons: [
            LessonModel(
              lessonNumber: 1,
              title: 'Limits and Continuity',
              type: LessonType.video,
              durationMinutes: 30,
              isCompleted: false,
              isLocked: true,
              isCurrent: false,
              description: 'Introduction to the concept of limits',
              xpReward: 80,
              difficulty: LessonDifficulty.advanced,
            ),
            LessonModel(
              lessonNumber: 2,
              title: 'Introduction to Derivatives',
              type: LessonType.video,
              durationMinutes: 35,
              isCompleted: false,
              isLocked: true,
              isCurrent: false,
              description: 'Learn the basics of differentiation',
              xpReward: 80,
              difficulty: LessonDifficulty.advanced,
            ),
            LessonModel(
              lessonNumber: 3,
              title: 'Basic Integration',
              type: LessonType.video,
              durationMinutes: 35,
              isCompleted: false,
              isLocked: true,
              isCurrent: false,
              description: 'Introduction to integral calculus',
              xpReward: 80,
              difficulty: LessonDifficulty.advanced,
            ),
            LessonModel(
              lessonNumber: 4,
              title: 'Calculus Applications',
              type: LessonType.assignment,
              durationMinutes: 60,
              isCompleted: false,
              isLocked: true,
              isCurrent: false,
              description: 'Real-world applications of calculus',
              xpReward: 200,
              difficulty: LessonDifficulty.expert,
            ),
          ],
        ),
      ],
    );
  }

  static SubjectRoadmap generateSamplePhysicsRoadmap() {
    return SubjectRoadmap(
      subjectName: 'Physics',
      overallProgress: 30.2,
      description:
          'Explore the fundamental laws of physics from mechanics to quantum theory',
      chapters: [
        ChapterModel(
          chapterNumber: 1,
          chapterName: 'Classical Mechanics',
          title: 'Laws of Motion',
          description:
              'Understand Newton\'s laws and basic principles of motion',
          chapterColor: Colors.indigo,
          progress: 75.0,
          currentLesson: 4,
          isCompleted: false,
          isLocked: false,
          difficulty: ChapterDifficulty.intermediate,
          lessons: [
            LessonModel(
              lessonNumber: 1,
              title: 'Newton\'s First Law',
              type: LessonType.video,
              durationMinutes: 20,
              isCompleted: true,
              isLocked: false,
              isCurrent: false,
              xpReward: 60,
            ),
            LessonModel(
              lessonNumber: 2,
              title: 'Newton\'s Second Law',
              type: LessonType.video,
              durationMinutes: 25,
              isCompleted: true,
              isLocked: false,
              isCurrent: false,
              xpReward: 60,
            ),
            LessonModel(
              lessonNumber: 3,
              title: 'Newton\'s Third Law',
              type: LessonType.video,
              durationMinutes: 20,
              isCompleted: true,
              isLocked: false,
              isCurrent: false,
              xpReward: 60,
            ),
            LessonModel(
              lessonNumber: 4,
              title: 'Motion Problems',
              type: LessonType.assignment,
              durationMinutes: 40,
              isCompleted: false,
              isLocked: false,
              isCurrent: true,
              xpReward: 150,
            ),
          ],
        ),
        ChapterModel(
          chapterNumber: 2,
          chapterName: 'Thermodynamics',
          title: 'Heat and Energy',
          description: 'Study the relationships between heat, work, and energy',
          chapterColor: Colors.orange,
          progress: 0.0,
          currentLesson: 1,
          isCompleted: false,
          isLocked: false,
          difficulty: ChapterDifficulty.advanced,
          lessons: [
            LessonModel(
              lessonNumber: 1,
              title: 'Temperature and Heat',
              type: LessonType.video,
              durationMinutes: 25,
              isCompleted: false,
              isLocked: false,
              isCurrent: false,
              xpReward: 70,
            ),
            LessonModel(
              lessonNumber: 2,
              title: 'Laws of Thermodynamics',
              type: LessonType.reading,
              durationMinutes: 35,
              isCompleted: false,
              isLocked: true,
              isCurrent: false,
              xpReward: 80,
            ),
          ],
        ),
      ],
    );
  }
}
