import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/service_locator.dart';
import '../../services/reminder_service.dart';
import '../../services/notification_service.dart';
import '../../models/reminder.dart';
import '../../models/bike.dart';
import '../../utils/maintenance_recommendations.dart';
import 'bike_provider.dart';

/// Reminder Service Provider
final reminderServiceProvider = Provider<ReminderService>((ref) {
  return getIt<ReminderService>();
});

/// Reminders State
class RemindersState {
  final List<Reminder> reminders;
  final bool isLoading;
  final String? error;
  final String selectedFilter;

  const RemindersState({
    this.reminders = const [],
    this.isLoading = false,
    this.error,
    this.selectedFilter = 'All',
  });

  RemindersState copyWith({
    List<Reminder>? reminders,
    bool? isLoading,
    String? error,
    String? selectedFilter,
  }) {
    return RemindersState(
      reminders: reminders ?? this.reminders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  /// Get filtered reminders based on selected filter
  List<Reminder> get filteredReminders {
    switch (selectedFilter) {
      case 'Active':
        return reminders.where((r) => r.isEnabled && !r.isOverdue).toList();
      case 'Overdue':
        return reminders.where((r) => r.isOverdue).toList();
      case 'Disabled':
        return reminders.where((r) => !r.isEnabled).toList();
      case 'Time-based':
        return reminders.where((r) => r.type == ReminderType.timeBased).toList();
      case 'Usage-based':
        return reminders.where((r) => r.type == ReminderType.usageBased).toList();
      default:
        return reminders;
    }
  }
}

/// Reminders Notifier
class RemindersNotifier extends StateNotifier<RemindersState> {
  final ReminderService _reminderService;

  RemindersNotifier(this._reminderService) : super(const RemindersState()) {
    loadReminders();
  }

  Future<void> loadReminders() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final reminders = await _reminderService.getReminders();
      state = state.copyWith(reminders: reminders, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  Future<void> addReminder(Reminder reminder) async {
    try {
      final newReminder = await _reminderService.createReminder(reminder);
      state = state.copyWith(reminders: [newReminder, ...state.reminders]);
      
      // Schedule notification for the new reminder
      if (newReminder.isEnabled && newReminder.dueDate != null) {
        await NotificationService().scheduleReminderNotification(newReminder);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> updateReminder(Reminder reminder) async {
    try {
      final updated = await _reminderService.updateReminder(reminder);
      final reminders = state.reminders.map((r) {
        return r.id == reminder.id ? updated : r;
      }).toList();
      state = state.copyWith(reminders: reminders);
      
      // Update scheduled notification
      await NotificationService().cancelReminderNotification(updated);
      if (updated.isEnabled && updated.dueDate != null) {
        await NotificationService().scheduleReminderNotification(updated);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> toggleEnabled(String id) async {
    try {
      final updated = await _reminderService.toggleEnabled(id);
      final reminders = state.reminders.map((r) {
        return r.id == id ? updated : r;
      }).toList();
      state = state.copyWith(reminders: reminders);
      
      // Update notification based on enabled state
      if (updated.isEnabled && updated.dueDate != null) {
        await NotificationService().scheduleReminderNotification(updated);
      } else {
        await NotificationService().cancelReminderNotification(updated);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> snoozeReminder(String id, int days) async {
    try {
      final updated = await _reminderService.snoozeReminder(id, days);
      final reminders = state.reminders.map((r) {
        return r.id == id ? updated : r;
      }).toList();
      state = state.copyWith(reminders: reminders);
      
      // Reschedule notification with new date
      await NotificationService().cancelReminderNotification(updated);
      if (updated.isEnabled && updated.dueDate != null) {
        await NotificationService().scheduleReminderNotification(updated);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Complete a reminder (marks it as done, resets for recurring)
  Future<void> completeReminder(String id, {double? currentBikeMileage}) async {
    try {
      final updated = await _reminderService.completeReminder(id, currentBikeMileage: currentBikeMileage);
      final reminders = state.reminders.map((r) {
        return r.id == id ? updated : r;
      }).toList();
      state = state.copyWith(reminders: reminders);
      
      // Update scheduled notification for recurring reminders
      await NotificationService().cancelReminderNotification(updated);
      if (updated.isEnabled && updated.dueDate != null && updated.isRecurring) {
        await NotificationService().scheduleReminderNotification(updated);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Get reminders that are due based on bike mileage
  List<Reminder> getDueUsageReminders(String bikeId, double currentMileage) {
    return state.reminders.where((r) {
      if (!r.isEnabled || r.type != ReminderType.usageBased) return false;
      if (r.bikeId != bikeId) return false;
      if (r.intervalDistance == null) return false;
      
      final lastMileage = r.lastCompletedMileage ?? 0.0;
      final kmSinceLast = currentMileage - lastMileage;
      return kmSinceLast >= r.intervalDistance!;
    }).toList();
  }

  /// Get reminders for a specific bike
  List<Reminder> getRemindersByBike(String bikeId) {
    return state.reminders.where((r) => r.bikeId == bikeId).toList();
  }

  Future<void> deleteReminder(String id) async {
    try {
      // Cancel notification before deleting
      final reminderToDelete = state.reminders.firstWhere(
        (r) => r.id == id,
        orElse: () => throw Exception('Reminder not found'),
      );
      await NotificationService().cancelReminderNotification(reminderToDelete);
      
      await _reminderService.deleteReminder(id);
      final reminders = state.reminders.where((r) => r.id != id).toList();
      state = state.copyWith(reminders: reminders);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Reminders Notifier Provider
final remindersNotifierProvider =
    StateNotifierProvider<RemindersNotifier, RemindersState>((ref) {
  return RemindersNotifier(ref.watch(reminderServiceProvider));
});

/// All Reminders Provider (convenience)
final remindersProvider = Provider<List<Reminder>>((ref) {
  return ref.watch(remindersNotifierProvider).reminders;
});

/// Filtered Reminders Provider
final filteredRemindersProvider = Provider<List<Reminder>>((ref) {
  return ref.watch(remindersNotifierProvider).filteredReminders;
});

/// Reminders Loading Provider
final remindersLoadingProvider = Provider<bool>((ref) {
  return ref.watch(remindersNotifierProvider).isLoading;
});

/// Reminders Error Provider
final remindersErrorProvider = Provider<String?>((ref) {
  return ref.watch(remindersNotifierProvider).error;
});

/// Selected Filter Provider
final reminderFilterProvider = Provider<String>((ref) {
  return ref.watch(remindersNotifierProvider).selectedFilter;
});

/// Active Reminders Provider
final activeRemindersProvider = Provider<List<Reminder>>((ref) {
  final reminders = ref.watch(remindersProvider);
  return reminders.where((r) => r.isEnabled && !r.isOverdue).toList();
});

/// Overdue Reminders Provider
final overdueRemindersProvider = Provider<List<Reminder>>((ref) {
  final reminders = ref.watch(remindersProvider);
  return reminders.where((r) => r.isOverdue).toList();
});

/// Overdue Count Provider
final overdueCountProvider = Provider<int>((ref) {
  return ref.watch(overdueRemindersProvider).length;
});

/// Upcoming Reminders Provider (next 7 days)
final upcomingRemindersProvider = Provider<List<Reminder>>((ref) {
  final reminders = ref.watch(remindersProvider);
  final now = DateTime.now();
  final nextWeek = now.add(const Duration(days: 7));
  
  return reminders.where((r) {
    if (!r.isEnabled || r.dueDate == null) return false;
    return r.dueDate!.isAfter(now) && r.dueDate!.isBefore(nextWeek);
  }).toList();
});

/// Next Reminder Provider
final nextReminderProvider = Provider<Reminder?>((ref) {
  final reminders = ref.watch(activeRemindersProvider);
  if (reminders.isEmpty) return null;
  
  // Sort by due date and return the first
  final sorted = List<Reminder>.from(reminders)
    ..sort((a, b) {
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });
  
  return sorted.first;
});

/// Reminders by Bike Provider
final remindersByBikeProvider = Provider.family<List<Reminder>, String>((ref, bikeId) {
  final reminders = ref.watch(remindersProvider);
  return reminders.where((r) => r.bikeId == bikeId).toList();
});

/// Usage-based Reminders by Bike Provider
final usageRemindersByBikeProvider = Provider.family<List<Reminder>, String>((ref, bikeId) {
  final reminders = ref.watch(remindersProvider);
  return reminders.where((r) => 
    r.bikeId == bikeId && 
    r.type == ReminderType.usageBased && 
    r.isEnabled
  ).toList();
});

/// Due Usage Reminders Provider (takes bikeId and currentMileage)
/// Returns reminders that are due based on current bike mileage
final dueUsageRemindersProvider = Provider.family<List<Reminder>, ({String bikeId, double mileage})>((ref, params) {
  final reminders = ref.watch(usageRemindersByBikeProvider(params.bikeId));
  
  return reminders.where((r) {
    if (r.intervalDistance == null) return false;
    final lastMileage = r.lastCompletedMileage ?? 0.0;
    final kmSinceLast = params.mileage - lastMileage;
    return kmSinceLast >= r.intervalDistance!;
  }).toList();
});

/// Due Soon Usage Reminders Provider (within 10% of interval)
final dueSoonUsageRemindersProvider = Provider.family<List<Reminder>, ({String bikeId, double mileage})>((ref, params) {
  final reminders = ref.watch(usageRemindersByBikeProvider(params.bikeId));
  
  return reminders.where((r) {
    if (r.intervalDistance == null) return false;
    final lastMileage = r.lastCompletedMileage ?? 0.0;
    final kmSinceLast = params.mileage - lastMileage;
    final remaining = r.intervalDistance! - kmSinceLast;
    // Due soon if within 10% of the interval
    return remaining > 0 && remaining <= r.intervalDistance! * 0.1;
  }).toList();
});

/// Get reminder status with current mileage
final reminderStatusProvider = Provider.family<ReminderStatus, ({Reminder reminder, double? mileage})>((ref, params) {
  return params.reminder.getStatus(params.mileage);
});

/// All overdue reminders (time-based + usage-based combined)
final allOverdueRemindersProvider = Provider.family<List<Reminder>, Map<String, double>>((ref, bikeMileageMap) {
  final reminders = ref.watch(remindersProvider);
  
  return reminders.where((r) {
    if (!r.isEnabled) return false;
    
    if (r.type == ReminderType.timeBased) {
      return r.isOverdue;
    } else {
      // Usage-based
      final currentMileage = bikeMileageMap[r.bikeId] ?? 0.0;
      return r.getStatus(currentMileage) == ReminderStatus.overdue;
    }
  }).toList();
});

/// Missing Recommendations Provider
/// Returns maintenance recommendations that the user hasn't set up reminders for
final missingRecommendationsProvider = Provider.family<List<MaintenanceRecommendation>, String>((ref, bikeId) {
  final bikeReminders = ref.watch(remindersByBikeProvider(bikeId));
  final bike = ref.watch(bikeByIdProvider(bikeId));
  final bikeMileage = bike?.totalMileage ?? 0.0;
  
  final existingTitles = bikeReminders.map((r) => r.title).toList();
  
  return getMissingRecommendations(
    bikeMileage: bikeMileage,
    existingReminderTitles: existingTitles,
  );
});

/// Bikes Needing Reminder Setup Provider
/// Returns bikes that have significant mileage but missing recommended reminders
final bikesNeedingReminderSetupProvider = Provider<List<({Bike bike, int missingCount, int overdueCount})>>((ref) {
  final bikes = ref.watch(bikesProvider);
  final List<({Bike bike, int missingCount, int overdueCount})> result = [];
  
  for (final bike in bikes) {
    if (bike.id == null) continue;
    
    final missing = ref.watch(missingRecommendationsProvider(bike.id!));
    final mileage = bike.totalMileage ?? 0.0;
    
    // Count how many recommendations would already be overdue
    final overdueCount = missing.where((rec) => mileage >= rec.intervalKm).length;
    
    if (missing.isNotEmpty && mileage >= 50) { // Only suggest if bike has some mileage
      result.add((bike: bike, missingCount: missing.length, overdueCount: overdueCount));
    }
  }
  
  // Sort by overdue count (most urgent first)
  result.sort((a, b) => b.overdueCount.compareTo(a.overdueCount));
  
  return result;
});
