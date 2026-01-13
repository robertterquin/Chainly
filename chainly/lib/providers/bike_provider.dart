import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/service_locator.dart';
import '../../services/bike_service.dart';
import '../../models/bike.dart';

/// Bike Service Provider
final bikeServiceProvider = Provider<BikeService>((ref) {
  return getIt<BikeService>();
});

/// Bikes List State
class BikesState {
  final List<Bike> bikes;
  final bool isLoading;
  final String? error;

  const BikesState({
    this.bikes = const [],
    this.isLoading = false,
    this.error,
  });

  BikesState copyWith({
    List<Bike>? bikes,
    bool? isLoading,
    String? error,
  }) {
    return BikesState(
      bikes: bikes ?? this.bikes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Bikes Notifier
class BikesNotifier extends StateNotifier<BikesState> {
  final BikeService _bikeService;

  BikesNotifier(this._bikeService) : super(const BikesState()) {
    loadBikes();
  }

  Future<void> loadBikes() async {
    debugPrint('BikesNotifier: Loading bikes...');
    state = state.copyWith(isLoading: true, error: null);
    try {
      final bikes = await _bikeService.getBikes();
      debugPrint('BikesNotifier: Loaded ${bikes.length} bikes');
      for (var b in bikes) {
        debugPrint('  - ${b.name} (id: ${b.id}, mileage: ${b.totalMileage})');
      }
      state = state.copyWith(bikes: bikes, isLoading: false);
    } catch (e) {
      debugPrint('BikesNotifier: Error loading - $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addBike(Bike bike) async {
    try {
      final newBike = await _bikeService.createBike(bike);
      state = state.copyWith(bikes: [...state.bikes, newBike]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> updateBike(Bike bike) async {
    try {
      final updatedBike = await _bikeService.updateBike(bike);
      final bikes = state.bikes.map((b) {
        return b.id == bike.id ? updatedBike : b;
      }).toList();
      state = state.copyWith(bikes: bikes);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteBike(String id) async {
    try {
      await _bikeService.deleteBike(id);
      final bikes = state.bikes.where((b) => b.id != id).toList();
      state = state.copyWith(bikes: bikes);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Bikes Notifier Provider
final bikesNotifierProvider = StateNotifierProvider<BikesNotifier, BikesState>((ref) {
  return BikesNotifier(ref.watch(bikeServiceProvider));
});

/// Bikes List Provider (convenience)
final bikesProvider = Provider<List<Bike>>((ref) {
  return ref.watch(bikesNotifierProvider).bikes;
});

final bikeNamesMapProvider = Provider<Map<String, String>>((ref) {
  final bikes = ref.watch(bikesProvider);
  return {
    for (var bike in bikes)
      if (bike.id != null) bike.id!: bike.name
  };
});

/// Single Bike Provider
final bikeByIdProvider = Provider.family<Bike?, String>((ref, id) {
  final bikes = ref.watch(bikesProvider);
  try {
    return bikes.firstWhere((b) => b.id == id);
  } catch (_) {
    return null;
  }
});

/// Bikes Loading Provider
final bikesLoadingProvider = Provider<bool>((ref) {
  return ref.watch(bikesNotifierProvider).isLoading;
});

/// Bikes Error Provider
final bikesErrorProvider = Provider<String?>((ref) {
  return ref.watch(bikesNotifierProvider).error;
});
