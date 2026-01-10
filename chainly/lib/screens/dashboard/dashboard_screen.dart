import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/custom_app_header.dart';

/// Dashboard (Home) Screen
/// Shows bike status summary, last maintenance, upcoming reminders,
/// quick actions, and cycling tips
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good Morning';
  if (hour < 18) return 'Good Afternoon';
  return 'Good Evening';
}

  @override
  Widget build(BuildContext context) {

  final user = Supabase.instance.client.auth.currentUser;
  final String greetingName =
  user?.userMetadata?['full_name'] ?? 'Rider';
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              CustomAppHeader(
                title: 'Dashboard',
                greeting:  '${getGreeting()}, $greetingName 👋',
                action: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ChainlyTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
                    boxShadow: ChainlyTheme.cardShadow,
                  ),
                  child: Badge(
                    label: const Text('2'),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: ChainlyTheme.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Bike Status Card
              _buildBikeStatusCard(),
              const SizedBox(height: 20),

              // Last Maintenance Info
              _buildLastMaintenanceCard(),
              const SizedBox(height: 20),

              // Upcoming Reminders
              _buildUpcomingRemindersSection(),
              const SizedBox(height: 20),

              // Quick Actions
              _buildQuickActionsSection(),
              const SizedBox(height: 20),

              // Cycling Tips
              _buildCyclingTipsSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBikeStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: ChainlyTheme.primaryGradient,
        borderRadius: BorderRadius.circular(ChainlyTheme.radiusLarge),
        boxShadow: ChainlyTheme.buttonShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Bike',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Good Condition',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.pedal_bike, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Canyon Aeroad CF',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Road Bike • 2,450 km total',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBikeStatItem('Total Distance', '2,450 km'),
              _buildBikeStatItem('Last Service', '4 days ago'),
              _buildBikeStatItem('Reminders', '3 active'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBikeStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildLastMaintenanceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ChainlyTheme.surfaceColor,
        borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
        boxShadow: ChainlyTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Last Maintenance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ChainlyTheme.textPrimary,
                ),
              ),
              Text(
                'View All',
                style: TextStyle(
                  fontSize: 14,
                  color: ChainlyTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ChainlyTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ChainlyTheme.radiusSmall),
                ),
                child: Icon(
                  Icons.link,
                  color: ChainlyTheme.successColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chain Lubrication',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: ChainlyTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Completed on Jan 5, 2026',
                      style: TextStyle(
                        fontSize: 13,
                        color: ChainlyTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: ChainlyTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ChainlyTheme.successColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingRemindersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Reminders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ChainlyTheme.textPrimary,
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: ChainlyTheme.textSecondary),
          ],
        ),
        const SizedBox(height: 12),
        _buildReminderItem(
          icon: Icons.tire_repair,
          title: 'Tire Inspection',
          subtitle: 'Due in 3 days',
          color: ChainlyTheme.warningColor,
        ),
        const SizedBox(height: 10),
        _buildReminderItem(
          icon: Icons.settings,
          title: 'Brake Pad Check',
          subtitle: 'Due in 7 days',
          color: ChainlyTheme.primaryColor,
        ),
      ],
    );
  }

  Widget _buildReminderItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ChainlyTheme.surfaceColor,
        borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
        boxShadow: ChainlyTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ChainlyTheme.radiusSmall),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ChainlyTheme.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: ChainlyTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: ChainlyTheme.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ChainlyTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.add_circle_outline,
                label: 'Add\nMaintenance',
                color: ChainlyTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.notifications_active,
                label: 'Set\nReminder',
                color: ChainlyTheme.accentColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.pedal_bike,
                label: 'My\nBikes',
                color: ChainlyTheme.successColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.bar_chart,
                label: 'View\nStats',
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: ChainlyTheme.surfaceColor,
        borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
        boxShadow: ChainlyTheme.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ChainlyTheme.textPrimary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCyclingTipsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ChainlyTheme.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
        border: Border.all(
          color: ChainlyTheme.accentColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ChainlyTheme.accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(ChainlyTheme.radiusSmall),
            ),
            child: Icon(
              Icons.lightbulb_outline,
              color: ChainlyTheme.accentColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tip of the Day',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ChainlyTheme.accentDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Clean your chain every 200-300km to extend its lifespan and maintain smooth shifting.',
                  style: TextStyle(
                    fontSize: 13,
                    color: ChainlyTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
