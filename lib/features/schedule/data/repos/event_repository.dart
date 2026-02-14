import 'package:hive_ce/hive.dart';

import '../models/event_model.dart';

class EventRepository {
  static const String _boxName = 'events';

  Future<Box<Event>> get _box async => await Hive.openBox<Event>(_boxName);

  Future<List<Event>> getEvents() async {
    final box = await _box;
    return box.values.toList();
  }

  Future<List<Event>> getEventsByType(EventType type) async {
    final box = await _box;
    return box.values.where((event) => event.type == type).toList();
  }

  Future<List<Event>> getEventsByDate(DateTime date) async {
    final box = await _box;
    return box.values
        .where(
          (event) =>
              event.startTime.year == date.year &&
              event.startTime.month == date.month &&
              event.startTime.day == date.day,
        )
        .toList();
  }

  Future<void> addEvent(Event event) async {
    final box = await _box;
    await box.put(event.id, event);
  }

  Future<void> updateEvent(Event event) async {
    final box = await _box;
    await box.put(event.id, event);
  }

  Future<void> deleteEvent(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  Future<void> clearEvents() async {
    final box = await _box;
    await box.clear();
  }

  // Dummy data for testing with current dates
  Future<void> addDummyData() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dayAfterTomorrow = today.add(const Duration(days: 2));

    final dummyEvents = [
      // Today's events
      Event(
        id: 'user_1',
        title: 'Meeting With A New Client',
        startTime: today.add(const Duration(hours: 10)),
        endTime: today.add(const Duration(hours: 12)),
        place: 'Conference Room',
        notes: 'Project discussion',
        type: EventType.user,
        colorValue: 0xFF2F98D7, // primary color
      ),
      Event(
        id: 'user_2',
        title: 'Meeting With A New Client',
        startTime: today.add(const Duration(hours: 10)),
        endTime: today.add(const Duration(hours: 12)),
        place: 'Conference Room',
        notes: 'Project discussion',
        type: EventType.user,
        colorValue: 0xFF2F98D7, // primary color
      ),
      Event(
        id: 'user_3',
        title: 'Meeting With A New Client',
        startTime: today.add(const Duration(hours: 10)),
        endTime: today.add(const Duration(hours: 12)),
        place: 'Conference Room',
        notes: 'Project discussion',
        type: EventType.user,
        colorValue: 0xFF2F98D7, // primary color
      ),
      Event(
        id: 'user_4',
        title: 'Meeting With A New Client',
        startTime: today.add(const Duration(hours: 10)),
        endTime: today.add(const Duration(hours: 12)),
        place: 'Conference Room',
        notes: 'Project discussion',
        type: EventType.user,
        colorValue: 0xFF2F98D7, // primary color
      ),
      Event(
        id: 'user_5',
        title: 'Meeting With A New Client',
        startTime: today.add(const Duration(hours: 10)),
        endTime: today.add(const Duration(hours: 12)),
        place: 'Conference Room',
        notes: 'Project discussion',
        type: EventType.user,
        colorValue: 0xFF2F98D7, // primary color
      ),
      Event(
        id: 'user_6',
        title: 'Meeting With A New Client',
        startTime: today.add(const Duration(hours: 10)),
        endTime: today.add(const Duration(hours: 12)),
        place: 'Conference Room',
        notes: 'Project discussion',
        type: EventType.user,
        colorValue: 0xFF2F98D7, // primary color
      ),
      Event(
        id: 'user_7',
        title: 'Team Standup',
        startTime: today.add(const Duration(hours: 8)),
        endTime: today.add(const Duration(hours: 9)),
        place: 'Office',
        notes: 'Daily standup meeting',
        type: EventType.user,
        colorValue: 0xFF539DF3, // light color
      ),
      Event(
        id: 'system_1',
        title: 'Math Test',
        startTime: today.add(const Duration(hours: 9)),
        endTime: today.add(const Duration(hours: 11)),
        place: 'Classroom A',
        notes: 'Final exam - Chapter 1-5',
        type: EventType.system,
        colorValue: 0xFFFFDB7A, // test color
      ),
      Event(
        id: 'system_2',
        title: 'English Course',
        startTime: today.add(const Duration(hours: 14)),
        endTime: today.add(const Duration(hours: 16)),
        place: 'Language Lab',
        notes: 'Grammar lesson',
        type: EventType.system,
        colorValue: 0xFFFB7772, // course color
      ),

      // Tomorrow's events
      Event(
        id: 'user_8',
        title: 'Project Review',
        startTime: tomorrow.add(const Duration(hours: 16)),
        endTime: tomorrow.add(const Duration(hours: 17)),
        place: 'Meeting Room',
        notes: 'Weekly project review',
        type: EventType.user,
        colorValue: 0xFF2F98D7,
      ),
      Event(
        id: 'system_3',
        title: 'Science Lab',
        startTime: tomorrow.add(const Duration(hours: 13)),
        endTime: tomorrow.add(const Duration(hours: 15)),
        place: 'Laboratory',
        notes: 'Chemistry experiment',
        type: EventType.system,
        colorValue: 0xFFFFDB7A,
      ),

      // Day after tomorrow
      Event(
        id: 'user_9',
        title: 'History Presentation',
        startTime: dayAfterTomorrow.add(const Duration(hours: 11)),
        endTime: dayAfterTomorrow.add(const Duration(hours: 12)),
        place: 'Auditorium',
        notes: 'World War II presentation',
        type: EventType.user,
        colorValue: 0xFF539DF3,
      ),
    ];

    for (final event in dummyEvents) {
      await addEvent(event);
    }
  }
}
