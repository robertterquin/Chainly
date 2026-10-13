/// Maintenance Status Enum
enum MaintenanceStatus {
  due,
  done;

  static MaintenanceStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'due':
        return MaintenanceStatus.due;
      case 'done':
      default:
        return MaintenanceStatus.done;
    }
  }
}

/// Maintenance Category Enum
enum MaintenanceCategory {
  chain,
  brakes,
  tires,
  service,
  other;

  static MaintenanceCategory fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'chain':
        return MaintenanceCategory.chain;
      case 'brakes':
        return MaintenanceCategory.brakes;
      case 'tires':
        return MaintenanceCategory.tires;
      case 'service':
        return MaintenanceCategory.service;
      default:
        return MaintenanceCategory.other;
    }
  }
}

/// Maintenance Model
class Maintenance {
  final String? id;
  final String? userId;
  final String bikeId;
  final String title;
  final MaintenanceCategory category;
  final DateTime date;
  final double cost;
  final String? notes;
  final MaintenanceStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Maintenance({
    this.id,
    this.userId,
    required this.bikeId,
    required this.title,
    required this.category,
    required this.date,
    this.cost = 0,
    this.notes,
    this.status = MaintenanceStatus.done,
    this.createdAt,
    this.updatedAt,
  });

  factory Maintenance.fromJson(Map<String, dynamic> json) {
    return Maintenance(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      bikeId: json['bike_id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled',
      category: MaintenanceCategory.fromString(json['category'] as String?),
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      cost: (json['cost'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String?,
      status: MaintenanceStatus.fromString(json['status'] as String?),
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
      'category': category.name,
      'date': date.toIso8601String().split('T')[0],
      'cost': cost,
      if (notes != null) 'notes': notes,
      'status': status.name,
    };
  }

  Maintenance copyWith({
    String? id,
    String? userId,
    String? bikeId,
    String? title,
    MaintenanceCategory? category,
    DateTime? date,
    double? cost,
    String? notes,
    MaintenanceStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Maintenance(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bikeId: bikeId ?? this.bikeId,
      title: title ?? this.title,
      category: category ?? this.category,
      date: date ?? this.date,
      cost: cost ?? this.cost,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isDue => status == MaintenanceStatus.due;
  bool get isDone => status == MaintenanceStatus.done;

  @override
  String toString() => 'Maintenance(id: $id, title: $title, status: $status)';
}
