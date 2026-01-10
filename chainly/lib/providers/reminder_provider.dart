import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/service_locator.dart';
import '../../services/reminder_service.dart';
import '../../models/reminder.dart';

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
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteReminder(String id) async {
    try {
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
