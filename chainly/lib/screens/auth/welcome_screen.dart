import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../utils/routes.dart';

/// Welcome/Get Started Screen
/// Shown after splash, before login/register
/// Modern design with gradient accent and call-to-action
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: ChainlyTheme.backgroundColor,
        child: SafeArea(
          child: Column(
            children: [
              // Top section with illustration
              Expanded(
                flex: 3,
                child: _buildTopSection(size),
              ),
              // Bottom section with buttons
              Expanded(
                flex: 2,
                child: _buildBottomSection(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection(Size size) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: ChainlyTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Logo
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipOval(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.directions_bike_rounded,
                      size: 60,
                      color: ChainlyTheme.primaryColor,
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // App name
          const Text(
            'Chainly',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          // Tagline
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Track maintenance, set reminders,\nand keep your bikes in top shape',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
          const Spacer(),
          // Feature highlights
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFeatureChip(Icons.build_rounded, 'Maintenance'),
                _buildFeatureChip(Icons.notifications_rounded, 'Reminders'),
                _buildFeatureChip(Icons.analytics_rounded, 'Analytics'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          // Get Started button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => AppRoutes.navigateTo(context, AppRoutes.register),
              style: ElevatedButton.styleFrom(
                backgroundColor: ChainlyTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Login button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () => AppRoutes.navigateTo(context, AppRoutes.login),
              style: OutlinedButton.styleFrom(
                foregroundColor: ChainlyTheme.primaryColor,
                side: const BorderSide(
                  color: ChainlyTheme.primaryColor,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'I already have an account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Terms text
          Text(
            'By continuing, you agree to our Terms of Service\nand Privacy Policy',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ChainlyTheme.textLight,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
