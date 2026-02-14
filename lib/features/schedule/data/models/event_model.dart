import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

part 'event_model.g.dart';

@HiveType(typeId: 1)
class Event {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime startTime;

  @HiveField(3)
  final DateTime endTime;

  @HiveField(4)
  final String place;

  @HiveField(5)
  final String notes;

  @HiveField(6)
  final EventType type;

  @HiveField(7)
  final bool isCompleted;

  @HiveField(8)
  final int colorValue;

  Event({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.place,
    required this.notes,
    required this.type,
    this.isCompleted = false,
    required this.colorValue,
  });

  Color get backgroundColor => Color(colorValue);

  Event copyWith({
    String? id,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? place,
    String? notes,
    EventType? type,
    bool? isCompleted,
    int? colorValue,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      place: place ?? this.place,
      notes: notes ?? this.notes,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}

@HiveType(typeId: 2)
enum EventType {
  @HiveField(0)
  user,
  @HiveField(1)
  system,
}
