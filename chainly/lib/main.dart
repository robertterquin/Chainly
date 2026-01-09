import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils/theme.dart';
import 'utils/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://zeyzmdtnknxztnyzhfro.supabase.co',
    anonKey: 'sb_publishable_RTdlDo0ERIupx61lHGScVg_ScONbwkq',
  );
  
  runApp(const ChainlyApp());
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
