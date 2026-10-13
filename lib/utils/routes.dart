import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/main/main_navigation_screen.dart';
import '../screens/profile/notification_settings_screen.dart';
import '../screens/notifications/notifications_history_screen.dart';

/// Named routes for the Chainly app
class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String onboarding = '/onboarding';
  static const String main = '/main';
  static const String notificationSettings = '/notification-settings';
  static const String notificationsHistory = '/notifications-history';

  // Route map
  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        welcome: (context) => const WelcomeScreen(),
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),
        forgotPassword: (context) => const ForgotPasswordScreen(),
        main: (context) => const MainNavigationScreen(),
        notificationSettings: (context) => const NotificationSettingsScreen(),
        notificationsHistory: (context) => const NotificationsHistoryScreen(),
      };

  // Navigation helpers
  static void navigateTo(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  static void navigateAndReplace(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  static void navigateAndClearStack(BuildContext context, String routeName) {
    Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
  }

  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}
