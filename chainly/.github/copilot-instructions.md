# Chainly - Flutter Project Instructions

## Project Overview
Chainly is a multi-platform Flutter application (Android, iOS, Web, Linux, macOS, Windows) currently in initial development stage with the default Flutter counter demo app.

## Architecture & Structure
- **Single-file app**: Currently [lib/main.dart](../lib/main.dart) contains the entire application
- **Standard Flutter structure**: Follows Flutter's default template with platform-specific folders (`android/`, `ios/`, `web/`, etc.)
- **No custom architecture yet**: As the app grows, expect to see common Flutter patterns like:
  - Feature-based organization in `lib/features/` or `lib/modules/`
  - Shared utilities in `lib/core/` or `lib/shared/`
  - State management solution (Provider, Riverpod, Bloc, etc.)

## Development Workflows

### Running the App
```bash
# Run on connected device/emulator
flutter run

# Run for specific platform
flutter run -d chrome          # Web
flutter run -d windows         # Windows desktop
flutter run -d <device-id>     # Specific device

# List available devices
flutter devices
```

### Testing
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

### Building
```bash
# Android APK
flutter build apk

# Android App Bundle (for Play Store)
flutter build appbundle

# iOS (requires macOS)
flutter build ios

# Web
flutter build web

# Windows
flutter build windows
```

### Code Quality
- **Linting**: Uses `flutter_lints` v6.0.0 (strict recommended lints)
- **Analysis**: Run `flutter analyze` to check for issues
- **Format code**: Run `dart format .` or `dart format lib/` before committing

## Dependencies
- **Flutter SDK**: Requires Dart SDK ^3.10.4
- **Core dependencies**: Only `cupertino_icons` for iOS-style icons
- **Dev dependencies**: `flutter_test` and `flutter_lints`
- **No state management yet**: When adding state, consider Provider, Riverpod, or Bloc based on complexity

## Conventions & Patterns

### Code Style
- Uses standard Flutter/Dart conventions (enforced by `flutter_lints`)
- Material Design widgets preferred (as seen in [lib/main.dart](../lib/main.dart))
- Widgets use `const` constructors where possible for performance

### File Organization
- **Main entry**: [lib/main.dart](../lib/main.dart)
- **Tests**: Mirror lib structure in `test/` directory
- **Assets**: Currently none defined; when adding, configure in [pubspec.yaml](../pubspec.yaml) under `flutter.assets`

### Widget Patterns
- StatelessWidget for static content (`MyApp`)
- StatefulWidget for interactive UI (`MyHomePage`)
- Use `setState()` for simple state changes
- Scaffold-AppBar-Body structure for screens

## Hot Reload & Hot Restart
- **Hot reload** (save file or `r` in terminal): Preserves app state, fast updates
- **Hot restart** (`R` in terminal): Resets state, rebuilds entire app
- After changing `main()`, assets, or dependencies, use hot restart or full restart

## Common Tasks

### Adding Dependencies
1. Add to [pubspec.yaml](../pubspec.yaml) under `dependencies`
2. Run `flutter pub get`
3. Import in Dart files: `import 'package:package_name/package_name.dart';`

### Creating New Screens
- Create StatefulWidget or StatelessWidget
- Use `Navigator.push()` for navigation
- Consider using named routes for larger apps

### Working with Assets
1. Add assets to project (e.g., `assets/images/`)
2. Declare in [pubspec.yaml](../pubspec.yaml):
   ```yaml
   flutter:
     assets:
       - assets/images/
   ```
3. Load with `Image.asset('assets/images/image.png')`

## Platform-Specific Notes
- **Android**: Gradle config in [android/app/build.gradle.kts](../android/app/build.gradle.kts)
- **iOS**: Xcode project in [ios/Runner.xcodeproj/](../ios/Runner.xcodeproj/)
- **Web**: Entry point is [web/index.html](../web/index.html)
- **Desktop**: CMake configs in respective platform folders

## Next Steps for Development
This is a greenfield project. Key decisions to make:
1. **State management**: Choose based on app complexity (Provider for simple, Riverpod/Bloc for complex)
2. **Architecture**: Consider Clean Architecture, MVVM, or feature-first structure
3. **Navigation**: Use Navigator 2.0/GoRouter for complex routing needs
4. **API integration**: Add `http` or `dio` for REST APIs
5. **Local storage**: Use `shared_preferences`, `hive`, or `sqflite` based on needs
