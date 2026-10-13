import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bike.dart';

/// Bike Service
/// Handles all bike-related CRUD operations with Supabase
class BikeService {
  final SupabaseClient _client;
  static const String _tableName = 'bikes';

  BikeService(this._client);

  String? get _userId => _client.auth.currentUser?.id;

  /// Get all bikes for the current user
  Future<List<Bike>> getBikes() async {
    if (_userId == null) throw Exception('User not logged in');

    final response = await _client
        .from(_tableName)
        .select()
        .eq('user_id', _userId!)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Bike.fromJson(json)).toList();
  }

  /// Get a single bike by ID
  Future<Bike?> getBikeById(String id) async {
    if (_userId == null) throw Exception('User not logged in');

    final response = await _client
        .from(_tableName)
        .select()
        .eq('id', id)
        .eq('user_id', _userId!)
        .maybeSingle();

    return response != null ? Bike.fromJson(response) : null;
  }

  /// Get bikes as a map (id -> name) for dropdowns
  Future<Map<String, String>> getBikeNamesMap() async {
    if (_userId == null) throw Exception('User not logged in');

    final response = await _client
        .from(_tableName)
        .select('id, name')
        .eq('user_id', _userId!);

    return {
      for (var bike in response) bike['id'] as String: bike['name'] as String
    };
  }

  /// Create a new bike
  Future<Bike> createBike(Bike bike) async {
    if (_userId == null) throw Exception('User not logged in');

    final data = bike.toJson();
    data['user_id'] = _userId;
    data['created_at'] = DateTime.now().toIso8601String();
    data['updated_at'] = DateTime.now().toIso8601String();

    final response = await _client
        .from(_tableName)
        .insert(data)
        .select()
        .single();

    return Bike.fromJson(response);
  }

  /// Update an existing bike
  Future<Bike> updateBike(Bike bike) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not logged in');
    if (bike.id == null) throw Exception('Bike ID is required for update');

    final data = bike.toJson();
    data['updated_at'] = DateTime.now().toIso8601String();

    final response = await _client
        .from(_tableName)
        .update(data)
        .eq('id', bike.id!)
        .eq('user_id', userId)
        .select()
        .single();

    return Bike.fromJson(response);
  }

  /// Delete a bike
  Future<void> deleteBike(String id) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not logged in');

    await _client
        .from(_tableName)
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }

  /// Update bike mileage
  Future<void> updateMileage(String bikeId, double additionalMileage) async {
    if (_userId == null) throw Exception('User not logged in');

    final bike = await getBikeById(bikeId);
    if (bike == null) throw Exception('Bike not found');

    final newMileage = (bike.totalMileage ?? 0) + additionalMileage;

    await _client
        .from(_tableName)
        .update({
          'total_mileage': newMileage,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', bikeId)
        .eq('user_id', _userId!);
  }
}
