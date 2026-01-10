import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ride.dart';

/// Ride Service
/// Handles all ride-related CRUD operations with Supabase
class RideService {
  final SupabaseClient _client;
  static const String _tableName = 'rides';

  RideService(this._client);

  String? get _userId => _client.auth.currentUser?.id;

  /// Get all rides for the current user
  Future<List<Ride>> getRides() async {
    if (_userId == null) throw Exception('User not logged in');

    final response = await _client
        .from(_tableName)
        .select()
        .eq('user_id', _userId!)
        .order('date', ascending: false);

    return (response as List).map((json) => Ride.fromJson(json)).toList();
  }

  /// Get rides for a specific bike
  Future<List<Ride>> getRidesByBike(String bikeId) async {
    if (_userId == null) throw Exception('User not logged in');

    final response = await _client
        .from(_tableName)
        .select()
        .eq('user_id', _userId!)
        .eq('bike_id', bikeId)
        .order('date', ascending: false);

    return (response as List).map((json) => Ride.fromJson(json)).toList();
  }

  /// Get a single ride by ID
  Future<Ride?> getRideById(String id) async {
    if (_userId == null) throw Exception('User not logged in');

    final response = await _client
        .from(_tableName)
        .select()
        .eq('id', id)
        .eq('user_id', _userId!)
        .maybeSingle();

    return response != null ? Ride.fromJson(response) : null;
  }

  /// Create a new ride
  Future<Ride> createRide(Ride ride) async {
    if (_userId == null) throw Exception('User not logged in');

    final data = ride.toJson();
    data['user_id'] = _userId;
    data['created_at'] = DateTime.now().toIso8601String();
    data['updated_at'] = DateTime.now().toIso8601String();

    final response = await _client
        .from(_tableName)
        .insert(data)
        .select()
        .single();

    return Ride.fromJson(response);
  }

  /// Update an existing ride
  Future<Ride> updateRide(Ride ride) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not logged in');
    if (ride.id == null) throw Exception('Ride ID is required for update');

    final data = ride.toJson();
    data['updated_at'] = DateTime.now().toIso8601String();

    final response = await _client
        .from(_tableName)
        .update(data)
        .eq('id', ride.id!)
        .eq('user_id', userId)
        .select()
        .single();

    return Ride.fromJson(response);
  }

  /// Delete a ride
  Future<void> deleteRide(String id) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not logged in');

    await _client
        .from(_tableName)
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }

  /// Get total distance for all rides
  Future<double> getTotalDistance() async {
    if (_userId == null) throw Exception('User not logged in');

    final response = await _client
        .from(_tableName)
        .select('distance')
        .eq('user_id', _userId!);

    double total = 0;
    for (var record in response) {
      total += (record['distance'] as num?)?.toDouble() ?? 0;
    }
    return total;
  }

  /// Get total distance for this month
  Future<double> getMonthlyDistance() async {
    if (_userId == null) throw Exception('User not logged in');

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final response = await _client
        .from(_tableName)
        .select('distance')
        .eq('user_id', _userId!)
        .gte('date', startOfMonth.toIso8601String().split('T')[0]);

    double total = 0;
    for (var record in response) {
      total += (record['distance'] as num?)?.toDouble() ?? 0;
    }
    return total;
  }

  /// Get ride count
  Future<int> getRideCount() async {
    if (_userId == null) throw Exception('User not logged in');

    final response = await _client
        .from(_tableName)
        .select('id')
        .eq('user_id', _userId!);

    return response.length;
  }

  /// Get monthly ride count
  Future<int> getMonthlyRideCount() async {
    if (_userId == null) throw Exception('User not logged in');

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final response = await _client
        .from(_tableName)
        .select('id')
        .eq('user_id', _userId!)
        .gte('date', startOfMonth.toIso8601String().split('T')[0]);

    return response.length;
  }
}
