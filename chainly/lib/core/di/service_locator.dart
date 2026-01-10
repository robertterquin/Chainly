import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import '../../services/bike_service.dart';
import '../../services/maintenance_service.dart';
import '../../services/ride_service.dart';
import '../../services/reminder_service.dart';

/// Global service locator instance
final getIt = GetIt.instance;

/// Initialize all dependencies
Future<void> setupServiceLocator() async {
  // Register Supabase client
  getIt.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );

  // Register Services
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<BikeService>(
    () => BikeService(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<MaintenanceService>(
    () => MaintenanceService(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<RideService>(
    () => RideService(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<ReminderService>(
    () => ReminderService(getIt<SupabaseClient>()),
  );
}
