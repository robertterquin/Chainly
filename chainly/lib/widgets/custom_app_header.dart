import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// Custom App Header
/// Reusable header component for all pages with title, description,
/// optional back button, and optional action button
class CustomAppHeader extends StatelessWidget {
  final String title;
  final String? description;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? action;
  final String? greeting;

  const CustomAppHeader({
    super.key,
    required this.title,
    this.description,
    this.showBackButton = false,
    this.onBackPressed,
    this.action,
    this.greeting,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Back button (optional)
        if (showBackButton)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: onBackPressed ?? () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ChainlyTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
                  boxShadow: ChainlyTheme.cardShadow,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: ChainlyTheme.textPrimary,
                ),
              ),
            ),
          ),

        // Title and description
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (greeting != null) ...[
                Text(
                  greeting!,
                  style: TextStyle(
                    fontSize: 14,
                    color: ChainlyTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: ChainlyTheme.textPrimary,
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 4),
                Text(
                  description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: ChainlyTheme.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Action button (optional)
        if (action != null) action!,
      ],
    );
  }
}
