import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/maintenance.dart';

/// Maintenance Service
/// Handles all maintenance-related CRUD operations with Supabase
class MaintenanceService {
  final SupabaseClient _client;
  static const String _tableName = 'maintenance';

  MaintenanceService(this._client);

  String? get _userId => _client.auth.currentUser?.id;

  /// Get all maintenance records for the current user
  Future<List<Maintenance>> getMaintenanceRecords() async {
    if (_userId == null) throw Exception('User not logged in');

    final response = await _client
        .from(_tableName)
        .select()
        .eq('user_id', _userId!)
        .order('date', ascending: false);

    return (response as List).map((json) => Maintenance.fromJson(json)).toList();
  }

  /// Get maintenance records for a specific bike
  Future<List<Maintenance>> getMaintenanceByBike(String bikeId) async {
    if (_userId == null) throw Exception('User not logged in');

    final response = await _client
        .from(_tableName)
        .select()
        .eq('user_id', _userId!)
        .eq('bike_id', bikeId)
        .order('date', ascending: false);

    return (response as List).map((json) => Maintenance.fromJson(json)).toList();
  }

  /// Get maintenance records by status
  Future<List<Maintenance>> getMaintenanceByStatus(MaintenanceStatus status) async {
    if (_userId == null) throw Exception('User not logged in');

    final response = await _client
        .from(_tableName)
        .select()
        .eq('user_id', _userId!)
        .eq('status', status.name)
        .order('date', ascending: false);

    return (response as List).map((json) => Maintenance.fromJson(json)).toList();
  }

  /// Get a single maintenance record by ID
  Future<Maintenance?> getMaintenanceById(String id) async {
    if (_userId == null) throw Exception('User not logged in');

    final response = await _client
        .from(_tableName)
        .select()
        .eq('id', id)
        .eq('user_id', _userId!)
        .maybeSingle();

    return response != null ? Maintenance.fromJson(response) : null;
  }

  /// Create a new maintenance record
  Future<Maintenance> createMaintenance(Maintenance maintenance) async {
    if (_userId == null) throw Exception('User not logged in');

    final data = maintenance.toJson();
    data['user_id'] = _userId;
    data['created_at'] = DateTime.now().toIso8601String();
    data['updated_at'] = DateTime.now().toIso8601String();

    final response = await _client
        .from(_tableName)
        .insert(data)
        .select()
        .single();

    return Maintenance.fromJson(response);
  }

  /// Update an existing maintenance record
  Future<Maintenance> updateMaintenance(Maintenance maintenance) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not logged in');
    if (maintenance.id == null) throw Exception('Maintenance ID is required for update');

    final data = maintenance.toJson();
    data['updated_at'] = DateTime.now().toIso8601String();

    final response = await _client
        .from(_tableName)
        .update(data)
        .eq('id', maintenance.id!)
        .eq('user_id', userId)
        .select()
        .single();

    return Maintenance.fromJson(response);
  }

  /// Toggle maintenance status
  Future<Maintenance> toggleStatus(String id) async {
    if (_userId == null) throw Exception('User not logged in');

    final current = await getMaintenanceById(id);
    if (current == null) throw Exception('Maintenance record not found');

    final newStatus = current.status == MaintenanceStatus.due
        ? MaintenanceStatus.done
        : MaintenanceStatus.due;

    final response = await _client
        .from(_tableName)
        .update({
          'status': newStatus.name,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .eq('user_id', _userId!)
        .select()
        .single();

    return Maintenance.fromJson(response);
  }

  /// Delete a maintenance record
  Future<void> deleteMaintenance(String id) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not logged in');

    await _client
        .from(_tableName)
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }

  /// Get total maintenance cost
  Future<double> getTotalCost() async {
    if (_userId == null) throw Exception('User not logged in');

    final response = await _client
        .from(_tableName)
        .select('cost')
        .eq('user_id', _userId!);

    double total = 0;
    for (var record in response) {
      total += (record['cost'] as num?)?.toDouble() ?? 0;
    }
    return total;
  }

  /// Get maintenance count
  Future<int> getMaintenanceCount() async {
    if (_userId == null) throw Exception('User not logged in');

    final response = await _client
        .from(_tableName)
        .select('id')
        .eq('user_id', _userId!);

    return response.length;
  }
}
