/// Reminder Type Enum
enum ReminderType {
  timeBased,
  usageBased;

  static ReminderType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'usage_based':
      case 'usagebased':
        return ReminderType.usageBased;
      case 'time_based':
      case 'timebased':
      default:
        return ReminderType.timeBased;
    }
  }

  String toDbString() {
    switch (this) {
      case ReminderType.timeBased:
        return 'time_based';
      case ReminderType.usageBased:
        return 'usage_based';
    }
  }
}

/// Reminder Model
class Reminder {
  final String? id;
  final String? userId;
  final String bikeId;
  final String title;
  final ReminderType type;
  final DateTime? dueDate;
  final double? dueMileage;
  final String? interval; // e.g., "2 weeks", "500 km"
  final bool isEnabled;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Reminder({
    this.id,
    this.userId,
    required this.bikeId,
    required this.title,
    required this.type,
    this.dueDate,
    this.dueMileage,
    this.interval,
    this.isEnabled = true,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      bikeId: json['bike_id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled',
      type: ReminderType.fromString(json['type'] as String?),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      dueMileage: (json['due_mileage'] as num?)?.toDouble(),
      interval: json['interval'] as String?,
      isEnabled: json['is_enabled'] as bool? ?? true,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'bike_id': bikeId,
      'title': title,
      'type': type.toDbString(),
      if (dueDate != null) 'due_date': dueDate!.toIso8601String().split('T')[0],
      if (dueMileage != null) 'due_mileage': dueMileage,
      if (interval != null) 'interval': interval,
      'is_enabled': isEnabled,
      if (notes != null) 'notes': notes,
    };
  }

  Reminder copyWith({
    String? id,
    String? userId,
    String? bikeId,
    String? title,
    ReminderType? type,
    DateTime? dueDate,
    double? dueMileage,
    String? interval,
    bool? isEnabled,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bikeId: bikeId ?? this.bikeId,
      title: title ?? this.title,
      type: type ?? this.type,
      dueDate: dueDate ?? this.dueDate,
      dueMileage: dueMileage ?? this.dueMileage,
      interval: interval ?? this.interval,
      isEnabled: isEnabled ?? this.isEnabled,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isOverdue {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  int get daysUntilDue {
    if (dueDate == null) return 0;
    return dueDate!.difference(DateTime.now()).inDays;
  }

  @override
  String toString() => 'Reminder(id: $id, title: $title, type: $type)';
}
