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

/// Reminder Priority Enum
enum ReminderPriority {
  low,
  normal,
  high;

  static ReminderPriority fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'low':
        return ReminderPriority.low;
      case 'high':
        return ReminderPriority.high;
      case 'normal':
      default:
        return ReminderPriority.normal;
    }
  }

  String toDbString() {
    return name.toLowerCase();
  }
}

/// Reminder Status Enum
enum ReminderStatus {
  overdue,
  dueSoon,
  upcoming,
  disabled;
}

/// Reminder Model
class Reminder {
  final String? id;
  final String userId;
  final String bikeId;
  final String? maintenanceId; // Optional link to maintenance record
  final String title;
  final String? description;
  final ReminderType type;
  
  // Time-based fields
  final int? intervalDays;
  final DateTime? dueDate;
  final DateTime? lastCompletedDate;
  
  // Usage-based fields
  final double? intervalDistance;
  final double? lastCompletedMileage;
  
  // Common fields
  final bool isEnabled;
  final bool isRecurring;
  final String category;
  final ReminderPriority priority;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Reminder({
    this.id,
    required this.userId,
    required this.bikeId,
    this.maintenanceId,
    required this.title,
    this.description,
    required this.type,
    this.intervalDays,
    this.dueDate,
    this.lastCompletedDate,
    this.intervalDistance,
    this.lastCompletedMileage,
    this.isEnabled = true,
    this.isRecurring = false,
    this.category = 'service',
    this.priority = ReminderPriority.normal,
    this.createdAt,
    this.updatedAt,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String?,
      userId: json['user_id'] as String? ?? '',
      bikeId: json['bike_id'] as String? ?? '',
      maintenanceId: json['maintenance_id'] as String?,
      title: json['title'] as String? ?? 'Untitled',
      description: json['description'] as String?,
      type: ReminderType.fromString(json['reminder_type'] as String?),
      intervalDays: json['interval_days'] as int?,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      lastCompletedDate: json['last_completed_date'] != null
          ? DateTime.parse(json['last_completed_date'] as String)
          : null,
      intervalDistance: (json['interval_distance'] as num?)?.toDouble(),
      lastCompletedMileage: (json['last_completed_mileage'] as num?)?.toDouble(),
      isEnabled: json['is_enabled'] as bool? ?? true,
      isRecurring: json['is_recurring'] as bool? ?? false,
      category: json['category'] as String? ?? 'service',
      priority: ReminderPriority.fromString(json['priority'] as String?),
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
      'user_id': userId,
      'bike_id': bikeId,
      if (maintenanceId != null) 'maintenance_id': maintenanceId,
      'title': title,
      if (description != null) 'description': description,
      'reminder_type': type.toDbString(),
      if (intervalDays != null) 'interval_days': intervalDays,
      if (dueDate != null) 'due_date': dueDate!.toIso8601String(),
      if (lastCompletedDate != null) 'last_completed_date': lastCompletedDate!.toIso8601String(),
      if (intervalDistance != null) 'interval_distance': intervalDistance,
      if (lastCompletedMileage != null) 'last_completed_mileage': lastCompletedMileage,
      'is_enabled': isEnabled,
      'is_recurring': isRecurring,
      'category': category,
      'priority': priority.toDbString(),
    };
  }

  Reminder copyWith({
    String? id,
    String? userId,
    String? bikeId,
    String? maintenanceId,
    String? title,
    String? description,
    ReminderType? type,
    int? intervalDays,
    DateTime? dueDate,
    DateTime? lastCompletedDate,
    double? intervalDistance,
    double? lastCompletedMileage,
    bool? isEnabled,
    bool? isRecurring,
    String? category,
    ReminderPriority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bikeId: bikeId ?? this.bikeId,
      maintenanceId: maintenanceId ?? this.maintenanceId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      intervalDays: intervalDays ?? this.intervalDays,
      dueDate: dueDate ?? this.dueDate,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      intervalDistance: intervalDistance ?? this.intervalDistance,
      lastCompletedMileage: lastCompletedMileage ?? this.lastCompletedMileage,
      isEnabled: isEnabled ?? this.isEnabled,
      isRecurring: isRecurring ?? this.isRecurring,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calculate the reminder status based on current bike mileage
  ReminderStatus getStatus(double? currentBikeMileage) {
    if (!isEnabled) return ReminderStatus.disabled;

    if (type == ReminderType.timeBased) {
      if (dueDate == null) return ReminderStatus.upcoming;
      
      final now = DateTime.now();
      if (dueDate!.isBefore(now)) {
        return ReminderStatus.overdue;
      } else if (dueDate!.difference(now).inDays <= 7) {
        return ReminderStatus.dueSoon;
      } else {
        return ReminderStatus.upcoming;
      }
    } else {
      // Usage-based
      if (intervalDistance == null || currentBikeMileage == null) {
        return ReminderStatus.upcoming;
      }

      final lastMileage = lastCompletedMileage ?? 0.0;
      final kmRemaining = intervalDistance! - (currentBikeMileage - lastMileage);
      
      if (kmRemaining <= 0) {
        return ReminderStatus.overdue;
      } else if (kmRemaining <= intervalDistance! * 0.1) {
        return ReminderStatus.dueSoon;
      } else {
        return ReminderStatus.upcoming;
      }
    }
  }

  /// Get a user-friendly string showing remaining time or distance
  String getRemainingString(double? currentBikeMileage) {
    if (!isEnabled) return 'Disabled';

    if (type == ReminderType.timeBased) {
      if (dueDate == null) return 'No due date set';
      
      final now = DateTime.now();
      final days = dueDate!.difference(now).inDays;
      
      if (days < 0) {
        return '${-days} days overdue';
      } else if (days == 0) {
        return 'Due today';
      } else if (days == 1) {
        return 'Due tomorrow';
      } else {
        return 'Due in $days days';
      }
    } else {
      // Usage-based
      if (intervalDistance == null || currentBikeMileage == null) {
        return 'No mileage data';
      }

      final lastMileage = lastCompletedMileage ?? 0.0;
      final kmRemaining = intervalDistance! - (currentBikeMileage - lastMileage);
      
      if (kmRemaining <= 0) {
        return '${(-kmRemaining).toStringAsFixed(1)} km overdue';
      } else {
        return '${kmRemaining.toStringAsFixed(1)} km remaining';
      }
    }
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
  String toString() => 'Reminder(id: $id, title: $title, type: $type, status: ${isEnabled ? "enabled" : "disabled"})';
}
