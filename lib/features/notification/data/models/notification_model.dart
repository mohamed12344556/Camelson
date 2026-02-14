import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final IconData icon;
  final String title;
  final String subtitle;
  final DateTime createdAt;
  bool isNew;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.createdAt,
    this.isNew = false,
    this.isRead = false,
  });

  NotificationModel copyWith({
    String? id,
    IconData? icon,
    String? title,
    String? subtitle,
    DateTime? createdAt,
    bool? isNew,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      createdAt: createdAt ?? this.createdAt,
      isNew: isNew ?? this.isNew,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'icon': icon.codePoint,
      'title': title,
      'subtitle': subtitle,
      'createdAt': createdAt.toIso8601String(),
      'isNew': isNew,
      'isRead': isRead,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      title: json['title'],
      subtitle: json['subtitle'],
      createdAt: DateTime.parse(json['createdAt']),
      isNew: json['isNew'] ?? false,
      isRead: json['isRead'] ?? false,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, subtitle: $subtitle, createdAt: $createdAt, isNew: $isNew, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel &&
        other.id == id &&
        other.icon == icon &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.createdAt == createdAt &&
        other.isNew == isNew &&
        other.isRead == isRead;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        icon.hashCode ^
        title.hashCode ^
        subtitle.hashCode ^
        createdAt.hashCode ^
        isNew.hashCode ^
        isRead.hashCode;
  }
}
