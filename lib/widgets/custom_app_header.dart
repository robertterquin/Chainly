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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: ChainlyTheme.accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          greeting!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: ChainlyTheme.textSecondary,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: ChainlyTheme.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: ChainlyTheme.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: ChainlyTheme.primaryColor.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: ChainlyTheme.textSecondary,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Action button (optional)
            if (action != null) action!,
          ],
        ),
        
        // Accent underline
        const SizedBox(height: 12),
        Container(
          height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                ChainlyTheme.primaryColor,
                ChainlyTheme.primaryColor.withValues(alpha: 0.5),
                ChainlyTheme.accentColor.withValues(alpha: 0.3),
                Colors.transparent,
              ],
              stops: const [0.0, 0.3, 0.6, 1.0],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
