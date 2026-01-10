## Dependency Injection Setup

This folder contains the GetIt service locator configuration for Chainly.

### Files

- **service_locator.dart** - Registers all services and dependencies
- **services.dart** - Provides convenient getter functions for easy service access

### How to Use Services

#### Option 1: Using Service Getters (Recommended - Simplest)

```dart
import 'package:chainly/core/di/services.dart';

// Access any service directly
final bikes = await bikeService.getBikes();
final maintenance = await maintenanceService.getMaintenanceRecords();
await authService.signOut();
```

#### Option 2: Using GetIt Directly

```dart
import 'package:chainly/core/di/services.dart';

// Same thing, more explicit
final service = getIt<BikeService>();
final bikes = await service.getBikes();
```

#### Option 3: Using Riverpod Providers (In Widgets)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chainly/providers/bike_provider.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bikes = ref.watch(bikesProvider);
    // Use bikes
  }
}
```

### Available Services

| Service | File | Methods |
|---------|------|---------|
| **AuthService** | auth_service.dart | signInWithEmailPassword, signUpWithEmailPassword, resetPassword, signOut, currentUser |
| **BikeService** | bike_service.dart | getBikes, getBikeById, createBike, updateBike, deleteBike, updateMileage |
| **MaintenanceService** | maintenance_service.dart | getMaintenanceRecords, createMaintenance, updateMaintenance, toggleStatus, deleteMaintenance |
| **RideService** | ride_service.dart | getRides, getRidesByBike, createRide, updateRide, deleteRide |
| **ReminderService** | reminder_service.dart | getReminders, createReminder, toggleEnabled, snoozeReminder, deleteReminder |

### Architecture Overview

```
┌─────────────────────────────────────────┐
│  Service Locator (GetIt)                │
│  - Singleton pattern                    │
│  - One instance per service             │
│  - Auto-initialized in main.dart        │
└──────────────┬──────────────────────────┘
               │
       ┌───────┴─────────┐
       │                 │
   ┌───▼──────┐    ┌────▼────┐
   │ Services │    │ Riverpod │
   │ (GetIt)  │    │Providers │
   └──────────┘    └──────────┘
```

### Initialization

Services are automatically initialized in `main.dart`:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(...);
  await setupServiceLocator(); // ← Initializes all services
  
  runApp(const ProviderScope(child: ChainlyApp()));
}
```

### Best Practices

✅ **DO:**
- Use service getters in service-to-service calls
- Use Riverpod providers in widgets
- Register services as lazy singletons
- Keep services stateless

❌ **DON'T:**
- Use services directly in widgets (use providers instead)
- Create new instances of services
- Store service references in state
