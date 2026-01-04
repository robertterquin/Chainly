import 'package:flutter/material.dart';
import 'utils/theme.dart';
import 'utils/routes.dart';

void main() {
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
