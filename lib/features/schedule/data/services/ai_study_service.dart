import 'dart:math';

import 'package:flutter/material.dart';

import '../models/event_model.dart';
import '../models/study_preferences_model.dart';

class AIStudyService {
  static const List<String> _subjects = [
    'الرياضيات',
    'الفيزياء',
    'الكيمياء',
    'الأحياء',
    'اللغة العربية',
    'اللغة الإنجليزية',
    'التاريخ',
    'الجغرافيا',
    'الفلسفة والمنطق',
    'علم النفس والاجتماع',
  ];

  static const List<String> _examTypes = [
    'اختبار شهري',
    'اختبار نصف الترم',
    'امتحان نهائي',
    'اختبار سريع',
    'تقييم عملي',
  ];

  static const Map<String, Color> _subjectColors = {
    'الرياضيات': Color(0xFF2F98D7),
    'الفيزياء': Color(0xFF539DF3),
    'الكيمياء': Color(0xFFFFDB7A),
    'الأحياء': Color(0xFF4CAF50),
    'اللغة العربية': Color(0xFFFB7772),
    'اللغة الإنجليزية': Color(0xFF9C27B0),
    'التاريخ': Color(0xFF795548),
    'الجغرافيا': Color(0xFF607D8B),
    'الفلسفة والمنطق': Color(0xFF3F51B5),
    'علم النفس والاجتماع': Color(0xFFFF9800),
  };

  /// Generate AI-powered study plan based on student preferences
  static Future<List<Event>> generateStudyPlan(
    StudyPreferences preferences,
  ) async {
    // Simulate AI processing delay
    await Future.delayed(const Duration(seconds: 2));

    final random = Random();
    final events = <Event>[];
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    // Generate events for the next 7 days
    for (int day = 0; day < 7; day++) {
      final currentDay = startOfWeek.add(Duration(days: day));

      // Skip if it's Friday or Saturday (weekend)
      if (currentDay.weekday == 5 || currentDay.weekday == 6) {
        continue;
      }

      // Generate lessons based on preferences
      final dailyEvents = _generateDailyEvents(currentDay, preferences, random);

      events.addAll(dailyEvents);
    }

    return events;
  }

  static List<Event> _generateDailyEvents(
    DateTime date,
    StudyPreferences preferences,
    Random random,
  ) {
    final events = <Event>[];
    final usedTimes = <int>[];

    // Determine preferred study time slots based on preferences
    List<int> preferredHours;
    switch (preferences.preferredTimeToStudy) {
      case 'morning':
        preferredHours = [8, 9, 10, 11];
        break;
      case 'afternoon':
        preferredHours = [13, 14, 15, 16];
        break;
      case 'evening':
        preferredHours = [17, 18, 19, 20];
        break;
      default:
        preferredHours = [9, 10, 14, 15, 17, 18];
    }

    // Generate lessons based on subjectsPerDay preference
    final subjectsToday = _selectSubjectsForDay(preferences, random);

    for (final subject in subjectsToday) {
      // Find available time slot
      final availableHours =
          preferredHours.where((hour) => !usedTimes.contains(hour)).toList();

      if (availableHours.isEmpty) continue;

      final startHour = availableHours[random.nextInt(availableHours.length)];
      usedTimes.add(startHour);

      // Calculate duration based on subject and preferences
      final duration = _calculateLessonDuration(subject, preferences, random);

      final startTime = DateTime(date.year, date.month, date.day, startHour);
      final endTime = startTime.add(Duration(minutes: duration));

      events.add(
        Event(
          id:
              'lesson_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(10000)}',
          title: 'درس $subject',
          startTime: startTime,
          endTime: endTime,
          place: _generateLessonPlace(subject, random),
          notes: _generateLessonNotes(subject, preferences, random),
          type: EventType.system,
          colorValue: _subjectColors[subject]?.value ?? 0xFF2F98D7,
        ),
      );
    }

    // Occasionally add exams (20% chance per day)
    if (random.nextDouble() < 0.2) {
      final examEvent = _generateExamEvent(
        date,
        preferences,
        random,
        usedTimes,
      );
      if (examEvent != null) {
        events.add(examEvent);
      }
    }

    return events;
  }

  static List<String> _selectSubjectsForDay(
    StudyPreferences preferences,
    Random random,
  ) {
    if (preferences.studyAllSubjectsDaily) {
      // If student studies all subjects daily, pick 3-4 random subjects
      final shuffled = List<String>.from(_subjects)..shuffle(random);
      return shuffled.take(min(preferences.subjectsPerDay, 4)).toList();
    } else {
      // Focus on specific subjects based on preferences
      final subjects = <String>[];

      // Always include favorite subject
      if (preferences.favoriteSubject.isNotEmpty) {
        subjects.add(preferences.favoriteSubject);
      }

      // Include hardest subject more frequently for practice
      if (preferences.hardestSubject.isNotEmpty &&
          !subjects.contains(preferences.hardestSubject) &&
          random.nextDouble() < 0.7) {
        subjects.add(preferences.hardestSubject);
      }

      // Add random subjects to fill the day
      final remainingSubjects =
          _subjects.where((s) => !subjects.contains(s)).toList()
            ..shuffle(random);

      final targetCount = min(preferences.subjectsPerDay, 4);
      while (subjects.length < targetCount && remainingSubjects.isNotEmpty) {
        subjects.add(remainingSubjects.removeAt(0));
      }

      return subjects;
    }
  }

  static int _calculateLessonDuration(
    String subject,
    StudyPreferences preferences,
    Random random,
  ) {
    final baseMinutes = 60; // 1 hour base

    // Adjust based on subject difficulty and preferences
    if (subject == preferences.hardestSubject) {
      return baseMinutes + 30; // Extra 30 minutes for hard subjects
    }

    if (subject == preferences.timeConsumingSubject) {
      return baseMinutes + 45; // Extra 45 minutes for time-consuming subjects
    }

    if (preferences.hoursPerSubject.containsKey(subject)) {
      return (preferences.hoursPerSubject[subject]! * 60).round();
    }

    // Random variation
    return baseMinutes + random.nextInt(31); // 60-90 minutes
  }

  static String _generateLessonPlace(String subject, Random random) {
    const places = [
      'قاعة المحاضرات A',
      'المعمل العلمي',
      'مختبر الحاسوب',
      'قاعة الدراسة',
      'المكتبة',
      'قاعة المحاضرات B',
      'معمل اللغات',
    ];

    // Subject-specific places
    if (subject.contains('فيزياء') ||
        subject.contains('كيمياء') ||
        subject.contains('أحياء')) {
      return 'المعمل العلمي';
    }

    if (subject.contains('إنجليزية') || subject.contains('عربية')) {
      return 'معمل اللغات';
    }

    return places[random.nextInt(places.length)];
  }

  static String _generateLessonNotes(
    String subject,
    StudyPreferences preferences,
    Random random,
  ) {
    final notes = <String>[
      'مراجعة الفصل الثالث',
      'شرح مفاهيم جديدة',
      'حل تمارين تطبيقية',
      'تحضير للامتحان',
      'مراجعة شاملة',
      'أنشطة عملية',
      'مناقشة جماعية',
    ];

    if (subject == preferences.hardestSubject) {
      return 'تركيز إضافي - ${notes[random.nextInt(notes.length)]}';
    }

    return notes[random.nextInt(notes.length)];
  }

  static Event? _generateExamEvent(
    DateTime date,
    StudyPreferences preferences,
    Random random,
    List<int> usedTimes,
  ) {
    // Find available exam time (usually morning)
    final examHours = [9, 10, 11].where((h) => !usedTimes.contains(h)).toList();
    if (examHours.isEmpty) return null;

    final examHour = examHours[random.nextInt(examHours.length)];
    final subject = _subjects[random.nextInt(_subjects.length)];
    final examType = _examTypes[random.nextInt(_examTypes.length)];

    final startTime = DateTime(date.year, date.month, date.day, examHour);
    final endTime = startTime.add(const Duration(hours: 2));

    return Event(
      id:
          'exam_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(10000)}',
      title: '$examType - $subject',
      startTime: startTime,
      endTime: endTime,
      place: 'قاعة الامتحانات',
      notes: 'امتحان $examType في مادة $subject',
      type: EventType.system,
      colorValue: 0xFFFF5722, // Orange color for exams
    );
  }

  /// Generate study recommendations based on preferences
  static Map<String, dynamic> generateStudyRecommendations(
    StudyPreferences preferences,
  ) {
    final recommendations = <String, dynamic>{};

    // Time management recommendations
    if (preferences.hasTimeManagementDifficulty) {
      recommendations['timeManagement'] = [
        'استخدم تقنية الـ Pomodoro (25 دقيقة دراسة + 5 دقائق راحة)',
        'ضع جدولاً زمنياً ثابتاً والتزم به',
        'حدد أولوياتك وابدأ بالمواد الصعبة',
      ];
    }

    // Subject-specific recommendations
    if (preferences.hardestSubject.isNotEmpty) {
      recommendations['hardSubject'] = [
        'خصص وقتاً إضافياً لمادة ${preferences.hardestSubject}',
        'استخدم مصادر تعليمية متنوعة',
        'احرص على المراجعة اليومية',
      ];
    }

    // Study style recommendations
    recommendations['studyStyle'] =
        preferences.studyStyle == 'intensive'
            ? [
              'استمر في التركيز المكثف ولكن احرص على فترات الراحة',
              'نوع في طرق الدراسة لتجنب الملل',
            ]
            : [
              'التنويع بين المواد مفيد، احرص على التوازن',
              'خصص وقتاً كافياً لكل مادة',
            ];

    return recommendations;
  }
}
