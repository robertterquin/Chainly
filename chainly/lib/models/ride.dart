/// Ride Model
class Ride {
  final String? id;
  final String? userId;
  final String bikeId;
  final DateTime date;
  final double distance; // in km
  final Duration? duration;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Ride({
    this.id,
    this.userId,
    required this.bikeId,
    required this.date,
    required this.distance,
    this.duration,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      bikeId: json['bike_id'] as String? ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      distance: (json['distance'] as num?)?.toDouble() ?? 0,
      duration: json['duration_minutes'] != null
          ? Duration(minutes: json['duration_minutes'] as int)
          : null,
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
      'date': date.toIso8601String().split('T')[0],
      'distance': distance,
      if (duration != null) 'duration_minutes': duration!.inMinutes,
      if (notes != null) 'notes': notes,
    };
  }

  Ride copyWith({
    String? id,
    String? userId,
    String? bikeId,
    DateTime? date,
    double? distance,
    Duration? duration,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Ride(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bikeId: bikeId ?? this.bikeId,
      date: date ?? this.date,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedDuration {
    if (duration == null) return '-';
    final hours = duration!.inHours;
    final minutes = duration!.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String get formattedDistance => '${distance.toStringAsFixed(1)} km';

  @override
  String toString() => 'Ride(id: $id, date: $date, distance: $distance)';
}
