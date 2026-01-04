import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../utils/routes.dart';
import 'widgets/auth_input_field.dart';
import 'widgets/auth_button.dart';

/// Forgot Password Screen
/// Allows users to reset their password via email
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleResetPassword() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // TODO: Implement actual password reset logic
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _emailSent = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChainlyTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Back button
                _buildBackButton(context),
                const SizedBox(height: 40),
                // Content
                _emailSent ? _buildSuccessContent() : _buildFormContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => AppRoutes.goBack(context),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: ChainlyTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: ChainlyTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            size: 40,
            color: ChainlyTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        // Header
        const Text(
          'Forgot Password?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: ChainlyTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Don't worry! It happens. Please enter the email address associated with your account.",
          style: TextStyle(
            fontSize: 16,
            color: ChainlyTheme.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 40),
        // Form
        Form(
          key: _formKey,
          child: AuthInputField(
            controller: _emailController,
            label: 'Email',
            hint: 'Enter your email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 32),
        // Submit button
        AuthButton(
          text: 'Send Reset Link',
          onPressed: _handleResetPassword,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 24),
        // Back to login
        Center(
          child: TextButton(
            onPressed: () => AppRoutes.navigateAndReplace(context, AppRoutes.login),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back_rounded,
                  size: 18,
                  color: ChainlyTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Back to Sign In',
                  style: TextStyle(
                    color: ChainlyTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        // Success icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: ChainlyTheme.successColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            size: 60,
            color: ChainlyTheme.successColor,
          ),
        ),
        const SizedBox(height: 32),
        // Success message
        const Text(
          'Check Your Email',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: ChainlyTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'We have sent a password reset link to\n${_emailController.text}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: ChainlyTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 48),
        // Back to login button
        AuthButton(
          text: 'Back to Sign In',
          onPressed: () => AppRoutes.navigateAndReplace(context, AppRoutes.login),
        ),
        const SizedBox(height: 24),
        // Resend link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Didn't receive the email? ",
              style: TextStyle(
                color: ChainlyTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() => _emailSent = false);
              },
              child: const Text(
                'Resend',
                style: TextStyle(
                  color: ChainlyTheme.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
