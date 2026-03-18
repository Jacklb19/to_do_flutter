import 'package:flutter/material.dart';

class TaskAttachment {
  final String name;
  final String url;
  final String type; // 'image', 'pdf', 'document', etc.

  TaskAttachment({
    required this.name,
    required this.url,
    required this.type,
  });

  factory TaskAttachment.fromJson(Map<String, dynamic> json) {
    return TaskAttachment(
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      type: json['type'] ?? 'document',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'type': type,
    };
  }
}

class Task {
  final String? id;
  final String title;
  final String? description;
  final TimeOfDay? scheduledTime;
  final DateTime? scheduledDate;
  final String? category;
  final bool isCompleted;
  final DateTime createdAt;
  final List<TaskAttachment> attachments;

  Task({
    this.id,
    required this.title,
    this.description,
    this.scheduledTime,
    this.scheduledDate,
    this.category,
    this.isCompleted = false,
    DateTime? createdAt,
    List<TaskAttachment>? attachments,
  })  : createdAt = createdAt ?? DateTime.now(),
        attachments = attachments ?? [];

  factory Task.fromJson(Map<String, dynamic> json) {
    TimeOfDay? time;
    if (json['scheduled_time'] != null) {
      final parts = (json['scheduled_time'] as String).split(':');
      time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    List<TaskAttachment> attachments = [];
    if (json['attachments'] != null) {
      final attachmentList = json['attachments'];
      if (attachmentList is List) {
        attachments = attachmentList
            .map((a) => TaskAttachment.fromJson(a as Map<String, dynamic>))
            .toList();
      }
    }

    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      scheduledTime: time,
      scheduledDate: json['scheduled_date'] != null
          ? DateTime.parse(json['scheduled_date'])
          : null,
      category: json['category'],
      isCompleted: json['is_completed'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      attachments: attachments,
    );
  }

  Map<String, dynamic> toJson() {
    String? timeString;
    if (scheduledTime != null) {
      timeString =
          '${scheduledTime!.hour.toString().padLeft(2, '0')}:${scheduledTime!.minute.toString().padLeft(2, '0')}:00';
    }

    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'scheduled_time': timeString,
      'scheduled_date': scheduledDate?.toIso8601String().split('T')[0],
      'category': category,
      'is_completed': isCompleted,
      'attachments': attachments.map((a) => a.toJson()).toList(),
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TimeOfDay? scheduledTime,
    DateTime? scheduledDate,
    String? category,
    bool? isCompleted,
    DateTime? createdAt,
    List<TaskAttachment>? attachments,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      attachments: attachments ?? this.attachments,
    );
  }
}
