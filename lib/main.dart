import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'utils/theme.dart';
import 'utils/routes.dart';
import 'core/di/service_locator.dart';
import 'services/notification_service.dart';

/// Background message handler - must be top-level
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (not for web - need Firebase config first)
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } catch (e) {
      debugPrint('Firebase initialization failed: $e');
      debugPrint('Note: You need to add google-services.json (Android) or GoogleService-Info.plist (iOS)');
    }
  }
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://zeyzmdtnknxztnyzhfro.supabase.co',
    anonKey: 'sb_publishable_RTdlDo0ERIupx61lHGScVg_ScONbwkq',
  );
  
  // Setup GetIt service locator (dependency injection)
  await setupServiceLocator();
  
  // Initialize notification service
  try {
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Notification service initialization failed: $e');
  }
  
  // Wrap app with ProviderScope for Riverpod
  runApp(
    const ProviderScope(
      child: ChainlyApp(),
    ),
  );
}

class ChainlyApp extends StatelessWidget {
  const ChainlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chainly',
      debugShowCheckedModeBanner: false,
      theme: ChainlyTheme.lightTheme,
      darkTheme: ChainlyTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
