import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../utils/routes.dart';

/// Welcome/Get Started Screen
/// Clean, minimal design inspired by modern app onboarding
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF), // Light blue-tinted background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo
              _buildLogo(),
              const SizedBox(height: 32),
              // App name
              const Text(
                'Chainly',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: ChainlyTheme.primaryColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              // Tagline
              Text(
                'Track, Maintain, Ride with Confidence.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: ChainlyTheme.textSecondary,
                  height: 1.5,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(flex: 3),
              // Create account button
              _buildPrimaryButton(
                context,
                text: 'Create an account',
                onPressed: () => AppRoutes.navigateTo(context, AppRoutes.register),
              ),
              const SizedBox(height: 16),
              // Login button
              _buildSecondaryButton(
                context,
                text: 'I already have an account',
                onPressed: () => AppRoutes.navigateTo(context, AppRoutes.login),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/chainly_logo.png',
      width: 220,
      height: 220,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.directions_bike_rounded,
          size: 220,
          color: ChainlyTheme.primaryColor,
        );
      },
    );
  }

  Widget _buildPrimaryButton(
    BuildContext context, {
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          gradient: ChainlyTheme.primaryGradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: ChainlyTheme.primaryColor.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(
    BuildContext context, {
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: ChainlyTheme.primaryColor,
          side: const BorderSide(
            color: ChainlyTheme.primaryColor,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: Colors.white,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
