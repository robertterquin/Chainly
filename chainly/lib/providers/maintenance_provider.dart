import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/service_locator.dart';
import '../../services/maintenance_service.dart';
import '../../models/maintenance.dart';

/// Maintenance Service Provider
final maintenanceServiceProvider = Provider<MaintenanceService>((ref) {
  return getIt<MaintenanceService>();
});

/// Maintenance List State
class MaintenanceState {
  final List<Maintenance> records;
  final bool isLoading;
  final String? error;
  final String selectedFilter;

  const MaintenanceState({
    this.records = const [],
    this.isLoading = false,
    this.error,
    this.selectedFilter = 'All',
  });

  MaintenanceState copyWith({
    List<Maintenance>? records,
    bool? isLoading,
    String? error,
    String? selectedFilter,
  }) {
    return MaintenanceState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  /// Get filtered records based on selected filter
  List<Maintenance> get filteredRecords {
    if (selectedFilter == 'All') return records;
    if (selectedFilter == 'Due') {
      return records.where((r) => r.status == MaintenanceStatus.due).toList();
    }
    if (selectedFilter == 'Done') {
      return records.where((r) => r.status == MaintenanceStatus.done).toList();
    }
    // Filter by category
    return records
        .where((r) => r.category.name.toLowerCase() == selectedFilter.toLowerCase())
        .toList();
  }
}

/// Maintenance Notifier
class MaintenanceNotifier extends StateNotifier<MaintenanceState> {
  final MaintenanceService _maintenanceService;

  MaintenanceNotifier(this._maintenanceService) : super(const MaintenanceState()) {
    loadMaintenance();
  }

  Future<void> loadMaintenance() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final records = await _maintenanceService.getMaintenanceRecords();
      state = state.copyWith(records: records, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  Future<void> addMaintenance(Maintenance maintenance) async {
    try {
      final newRecord = await _maintenanceService.createMaintenance(maintenance);
      state = state.copyWith(records: [newRecord, ...state.records]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> updateMaintenance(Maintenance maintenance) async {
    try {
      final updated = await _maintenanceService.updateMaintenance(maintenance);
      final records = state.records.map((r) {
        return r.id == maintenance.id ? updated : r;
      }).toList();
      state = state.copyWith(records: records);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> toggleStatus(String id) async {
    try {
      final updated = await _maintenanceService.toggleStatus(id);
      final records = state.records.map((r) {
        return r.id == id ? updated : r;
      }).toList();
      state = state.copyWith(records: records);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteMaintenance(String id) async {
    try {
      await _maintenanceService.deleteMaintenance(id);
      final records = state.records.where((r) => r.id != id).toList();
      state = state.copyWith(records: records);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Maintenance Notifier Provider
final maintenanceNotifierProvider =
    StateNotifierProvider<MaintenanceNotifier, MaintenanceState>((ref) {
  return MaintenanceNotifier(ref.watch(maintenanceServiceProvider));
});

/// Maintenance Records Provider (convenience)
final maintenanceRecordsProvider = Provider<List<Maintenance>>((ref) {
  return ref.watch(maintenanceNotifierProvider).records;
});

/// Filtered Maintenance Records Provider
final filteredMaintenanceProvider = Provider<List<Maintenance>>((ref) {
  return ref.watch(maintenanceNotifierProvider).filteredRecords;
});

/// Maintenance Loading Provider
final maintenanceLoadingProvider = Provider<bool>((ref) {
  return ref.watch(maintenanceNotifierProvider).isLoading;
});

/// Maintenance Error Provider
final maintenanceErrorProvider = Provider<String?>((ref) {
  return ref.watch(maintenanceNotifierProvider).error;
});

/// Selected Filter Provider
final maintenanceFilterProvider = Provider<String>((ref) {
  return ref.watch(maintenanceNotifierProvider).selectedFilter;
});

/// Maintenance Count Provider
final maintenanceCountProvider = Provider<int>((ref) {
  return ref.watch(maintenanceRecordsProvider).length;
});

/// Due Maintenance Count Provider
final dueMaintenanceCountProvider = Provider<int>((ref) {
  final records = ref.watch(maintenanceRecordsProvider);
  return records.where((r) => r.status == MaintenanceStatus.due).length;
});

/// Total Maintenance Cost Provider
final totalMaintenanceCostProvider = Provider<double>((ref) {
  final records = ref.watch(maintenanceRecordsProvider);
  return records.fold(0.0, (sum, r) => sum + r.cost);
});
