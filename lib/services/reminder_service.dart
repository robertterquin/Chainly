import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reminder.dart';

/// Reminder Service
/// Handles all reminder-related CRUD operations with Supabase
class ReminderService {
  final SupabaseClient _client;
  static const String _tableName = 'reminders';

  ReminderService(this._client);

  String? get _userId => _client.auth.currentUser?.id;

  /// Get all reminders for the current user
  Future<List<Reminder>> getReminders() async {
    if (_userId == null) throw Exception('User not logged in');

    final response = await _client
        .from(_tableName)
        .select()
        .eq('user_id', _userId!)
        .order('due_date', ascending: true);

    return (response as List).map((json) => Reminder.fromJson(json)).toList();
  }

  /// Get active reminders (enabled)
  Future<List<Reminder>> getActiveReminders() async {
    if (_userId == null) throw Exception('User not logged in');

    final response = await _client
        .from(_tableName)
        .select()
        .eq('user_id', _userId!)
        .eq('is_enabled', true)
        .order('due_date', ascending: true);

    return (response as List).map((json) => Reminder.fromJson(json)).toList();
  }

  /// Get overdue reminders
  Future<List<Reminder>> getOverdueReminders() async {
    if (_userId == null) throw Exception('User not logged in');

    final now = DateTime.now().toIso8601String().split('T')[0];

    final response = await _client
        .from(_tableName)
        .select()
        .eq('user_id', _userId!)
        .eq('is_enabled', true)
        .lt('due_date', now)
        .order('due_date', ascending: true);

    return (response as List).map((json) => Reminder.fromJson(json)).toList();
  }

  /// Get reminders for a specific bike
  Future<List<Reminder>> getRemindersByBike(String bikeId) async {
    if (_userId == null) throw Exception('User not logged in');

    final response = await _client
        .from(_tableName)
        .select()
        .eq('user_id', _userId!)
        .eq('bike_id', bikeId)
        .order('due_date', ascending: true);

    return (response as List).map((json) => Reminder.fromJson(json)).toList();
  }

  /// Get a single reminder by ID
  Future<Reminder?> getReminderById(String id) async {
    if (_userId == null) throw Exception('User not logged in');

    final response = await _client
        .from(_tableName)
        .select()
        .eq('id', id)
        .eq('user_id', _userId!)
        .maybeSingle();

    return response != null ? Reminder.fromJson(response) : null;
  }

  /// Create a new reminder
  Future<Reminder> createReminder(Reminder reminder) async {
    if (_userId == null) throw Exception('User not logged in');

    final data = reminder.toJson();
    data['user_id'] = _userId;
    data['created_at'] = DateTime.now().toIso8601String();
    data['updated_at'] = DateTime.now().toIso8601String();

    final response = await _client
        .from(_tableName)
        .insert(data)
        .select()
        .single();

    return Reminder.fromJson(response);
  }

  /// Update an existing reminder
  Future<Reminder> updateReminder(Reminder reminder) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not logged in');
    if (reminder.id == null) throw Exception('Reminder ID is required for update');

    final data = reminder.toJson();
    data['updated_at'] = DateTime.now().toIso8601String();

    final response = await _client
        .from(_tableName)
        .update(data)
        .eq('id', reminder.id!)
        .eq('user_id', userId)
        .select()
        .single();

    return Reminder.fromJson(response);
  }

  /// Toggle reminder enabled status
  Future<Reminder> toggleEnabled(String id) async {
    if (_userId == null) throw Exception('User not logged in');

    final current = await getReminderById(id);
    if (current == null) throw Exception('Reminder not found');

    final response = await _client
        .from(_tableName)
        .update({
          'is_enabled': !current.isEnabled,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .eq('user_id', _userId!)
        .select()
        .single();

    return Reminder.fromJson(response);
  }

  /// Snooze a reminder by a number of days
  Future<Reminder> snoozeReminder(String id, int days) async {
    if (_userId == null) throw Exception('User not logged in');

    final current = await getReminderById(id);
    if (current == null) throw Exception('Reminder not found');

    final newDueDate = DateTime.now().add(Duration(days: days));

    final response = await _client
        .from(_tableName)
        .update({
          'due_date': newDueDate.toIso8601String().split('T')[0],
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .eq('user_id', _userId!)
        .select()
        .single();

    return Reminder.fromJson(response);
  }

  /// Delete a reminder
  Future<void> deleteReminder(String id) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not logged in');

    await _client
        .from(_tableName)
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }

  /// Get active reminder count
  Future<int> getActiveReminderCount() async {
    if (_userId == null) throw Exception('User not logged in');

    final response = await _client
        .from(_tableName)
        .select('id')
        .eq('user_id', _userId!)
        .eq('is_enabled', true);

    return response.length;
  }

  /// Complete a reminder (for recurring, reset based on type)
  Future<Reminder> completeReminder(String id, {double? currentBikeMileage}) async {
    if (_userId == null) throw Exception('User not logged in');

    final current = await getReminderById(id);
    if (current == null) throw Exception('Reminder not found');

    final now = DateTime.now();
    Map<String, dynamic> updateData = {
      'last_completed_date': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    // If usage-based, update last completed mileage
    if (current.type == ReminderType.usageBased && currentBikeMileage != null) {
      updateData['last_completed_mileage'] = currentBikeMileage;
    }

    // If recurring, calculate next due date
    if (current.isRecurring) {
      if (current.type == ReminderType.timeBased && current.intervalDays != null) {
        final nextDueDate = now.add(Duration(days: current.intervalDays!));
        updateData['due_date'] = nextDueDate.toIso8601String().split('T')[0];
      }
      // For usage-based, the status is calculated dynamically from mileage
    }

    final response = await _client
        .from(_tableName)
        .update(updateData)
        .eq('id', id)
        .eq('user_id', _userId!)
        .select()
        .single();

    return Reminder.fromJson(response);
  }

  /// Get usage-based reminders for a specific bike that are due
  Future<List<Reminder>> getDueUsageReminders(String bikeId, double currentMileage) async {
    if (_userId == null) throw Exception('User not logged in');

    final response = await _client
        .from(_tableName)
        .select()
        .eq('user_id', _userId!)
        .eq('bike_id', bikeId)
        .eq('reminder_type', 'usage_based')
        .eq('is_enabled', true);

    final reminders = (response as List).map((json) => Reminder.fromJson(json)).toList();
    
    // Filter reminders that are due based on current mileage
    return reminders.where((reminder) {
      if (reminder.intervalDistance == null) return false;
      final lastMileage = reminder.lastCompletedMileage ?? 0.0;
      final kmSinceLast = currentMileage - lastMileage;
      return kmSinceLast >= reminder.intervalDistance!;
    }).toList();
  }

  /// Get all usage-based reminders for a specific bike
  Future<List<Reminder>> getUsageRemindersByBike(String bikeId) async {
    if (_userId == null) throw Exception('User not logged in');

    final response = await _client
        .from(_tableName)
        .select()
        .eq('user_id', _userId!)
        .eq('bike_id', bikeId)
        .eq('reminder_type', 'usage_based')
        .eq('is_enabled', true);

    return (response as List).map((json) => Reminder.fromJson(json)).toList();
  }
}
