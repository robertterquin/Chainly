/// Bike Model
class Bike {
  final String? id;
  final String? userId;
  final String name;
  final String? type;
  final String? brand;
  final String? model;
  final double? totalMileage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Bike({
    this.id,
    this.userId,
    required this.name,
    this.type,
    this.brand,
    this.model,
    this.totalMileage,
    this.createdAt,
    this.updatedAt,
  });

  factory Bike.fromJson(Map<String, dynamic> json) {
    return Bike(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      name: json['name'] as String? ?? 'Unknown Bike',
      type: json['type'] as String?,
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      totalMileage: (json['total_mileage'] as num?)?.toDouble(),
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
      'name': name,
      if (type != null) 'type': type,
      if (brand != null) 'brand': brand,
      if (model != null) 'model': model,
      if (totalMileage != null) 'total_mileage': totalMileage,
    };
  }

  Bike copyWith({
    String? id,
    String? userId,
    String? name,
    String? type,
    String? brand,
    String? model,
    double? totalMileage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Bike(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      totalMileage: totalMileage ?? this.totalMileage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Bike(id: $id, name: $name, type: $type)';
}
