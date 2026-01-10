import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/service_locator.dart';
import '../../services/ride_service.dart';
import '../../models/ride.dart';

/// Ride Service Provider
final rideServiceProvider = Provider<RideService>((ref) {
  return getIt<RideService>();
});

/// Rides State
class RidesState {
  final List<Ride> rides;
  final bool isLoading;
  final String? error;
  final String? selectedBikeId;

  const RidesState({
    this.rides = const [],
    this.isLoading = false,
    this.error,
    this.selectedBikeId,
  });

  RidesState copyWith({
    List<Ride>? rides,
    bool? isLoading,
    String? error,
    String? selectedBikeId,
    bool clearBikeFilter = false,
  }) {
    return RidesState(
      rides: rides ?? this.rides,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedBikeId: clearBikeFilter ? null : (selectedBikeId ?? this.selectedBikeId),
    );
  }

  /// Get filtered rides by selected bike
  List<Ride> get filteredRides {
    if (selectedBikeId == null) return rides;
    return rides.where((r) => r.bikeId == selectedBikeId).toList();
  }
}

/// Rides Notifier
class RidesNotifier extends StateNotifier<RidesState> {
  final RideService _rideService;

  RidesNotifier(this._rideService) : super(const RidesState()) {
    loadRides();
  }

  Future<void> loadRides() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final rides = await _rideService.getRides();
      state = state.copyWith(rides: rides, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadRidesByBike(String bikeId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final rides = await _rideService.getRidesByBike(bikeId);
      state = state.copyWith(rides: rides, isLoading: false, selectedBikeId: bikeId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setBikeFilter(String? bikeId) {
    if (bikeId == null) {
      state = state.copyWith(clearBikeFilter: true);
    } else {
      state = state.copyWith(selectedBikeId: bikeId);
    }
  }

  Future<void> addRide(Ride ride) async {
    try {
      final newRide = await _rideService.createRide(ride);
      state = state.copyWith(rides: [newRide, ...state.rides]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> updateRide(Ride ride) async {
    try {
      final updated = await _rideService.updateRide(ride);
      final rides = state.rides.map((r) {
        return r.id == ride.id ? updated : r;
      }).toList();
      state = state.copyWith(rides: rides);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteRide(String id) async {
    try {
      await _rideService.deleteRide(id);
      final rides = state.rides.where((r) => r.id != id).toList();
      state = state.copyWith(rides: rides);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Rides Notifier Provider
final ridesNotifierProvider = StateNotifierProvider<RidesNotifier, RidesState>((ref) {
  return RidesNotifier(ref.watch(rideServiceProvider));
});

/// All Rides Provider (convenience)
final ridesProvider = Provider<List<Ride>>((ref) {
  return ref.watch(ridesNotifierProvider).rides;
});

/// Filtered Rides Provider
final filteredRidesProvider = Provider<List<Ride>>((ref) {
  return ref.watch(ridesNotifierProvider).filteredRides;
});

/// Rides Loading Provider
final ridesLoadingProvider = Provider<bool>((ref) {
  return ref.watch(ridesNotifierProvider).isLoading;
});

/// Rides Error Provider
final ridesErrorProvider = Provider<String?>((ref) {
  return ref.watch(ridesNotifierProvider).error;
});

/// Total Rides Count Provider
final totalRidesCountProvider = Provider<int>((ref) {
  return ref.watch(ridesProvider).length;
});

/// Total Distance Provider (in km)
final totalDistanceProvider = Provider<double>((ref) {
  final rides = ref.watch(ridesProvider);
  return rides.fold(0.0, (sum, r) => sum + r.distance);
});

/// Monthly Distance Provider
final monthlyDistanceProvider = Provider<double>((ref) {
  final rides = ref.watch(ridesProvider);
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  
  return rides
      .where((r) => r.date.isAfter(startOfMonth) || r.date.isAtSameMomentAs(startOfMonth))
      .fold(0.0, (sum, r) => sum + r.distance);
});

/// Weekly Distance Provider
final weeklyDistanceProvider = Provider<double>((ref) {
  final rides = ref.watch(ridesProvider);
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final weekStart = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
  
  return rides
      .where((r) => r.date.isAfter(weekStart) || r.date.isAtSameMomentAs(weekStart))
      .fold(0.0, (sum, r) => sum + r.distance);
});

/// Recent Rides Provider (last 5)
final recentRidesProvider = Provider<List<Ride>>((ref) {
  final rides = ref.watch(ridesProvider);
  return rides.take(5).toList();
});
