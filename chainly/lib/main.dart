import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils/theme.dart';
import 'utils/routes.dart';
import 'core/di/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://zeyzmdtnknxztnyzhfro.supabase.co',
    anonKey: 'sb_publishable_RTdlDo0ERIupx61lHGScVg_ScONbwkq',
  );
  
  // Setup GetIt service locator (dependency injection)
  await setupServiceLocator();
  
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
