import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_app_header.dart';

/// Reminders Screen
/// Shows list of active reminders with time-based and usage-based types,
/// enable/disable toggles, and snooze functionality
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              CustomAppHeader(
                title: 'Reminders',
                description: 'Never miss maintenance',
                action: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ChainlyTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
                    boxShadow: ChainlyTheme.cardShadow,
                  ),
                  child: Icon(
                    Icons.settings_outlined,
                    color: ChainlyTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Active Reminders Stats
              _buildActiveRemindersCard(),
              const SizedBox(height: 24),

              // Upcoming Reminders Section
              _buildUpcomingReminders(),
              const SizedBox(height: 24),

              // Active Reminders Section
              _buildActiveRemindersList(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to Add Reminder
        },
        backgroundColor: ChainlyTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Reminder',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildActiveRemindersCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: ChainlyTheme.primaryGradient,
        borderRadius: BorderRadius.circular(ChainlyTheme.radiusLarge),
        boxShadow: ChainlyTheme.buttonShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Reminders',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.notifications_active, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'All Enabled',
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
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildReminderStatItem('8', 'Total'),
              _buildReminderStatItem('3', 'Due Soon'),
              _buildReminderStatItem('2', 'Overdue'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReminderStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingReminders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Due Soon',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ChainlyTheme.textPrimary,
              ),
            ),
            Text(
              '3 reminders',
              style: TextStyle(
                fontSize: 14,
                color: ChainlyTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildReminderCard(
          icon: Icons.tire_repair,
          title: 'Tire Inspection',
          bike: 'Canyon Aeroad CF',
          type: ReminderType.timeBased,
          dueInfo: 'Due in 3 days',
          isOverdue: false,
          isEnabled: true,
        ),
        const SizedBox(height: 10),
        _buildReminderCard(
          icon: Icons.settings,
          title: 'Brake Pad Check',
          bike: 'Canyon Aeroad CF',
          type: ReminderType.timeBased,
          dueInfo: 'Due in 7 days',
          isOverdue: false,
          isEnabled: true,
        ),
        const SizedBox(height: 10),
        _buildReminderCard(
          icon: Icons.link,
          title: 'Chain Lubrication',
          bike: 'Trek Domane',
          type: ReminderType.usageBased,
          dueInfo: '50 km remaining',
          isOverdue: false,
          isEnabled: true,
        ),
      ],
    );
  }

  Widget _buildActiveRemindersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'All Reminders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ChainlyTheme.textPrimary,
              ),
            ),
            Text(
              '8 total',
              style: TextStyle(
                fontSize: 14,
                color: ChainlyTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildReminderCard(
          icon: Icons.link,
          title: 'Chain Replacement',
          bike: 'Canyon Aeroad CF',
          type: ReminderType.usageBased,
          dueInfo: '2,000 km remaining',
          isOverdue: false,
          isEnabled: true,
        ),
        const SizedBox(height: 10),
        _buildReminderCard(
          icon: Icons.build,
          title: 'Full Service',
          bike: 'Canyon Aeroad CF',
          type: ReminderType.timeBased,
          dueInfo: 'Every 6 months',
          isOverdue: false,
          isEnabled: false,
        ),
        const SizedBox(height: 10),
        _buildReminderCard(
          icon: Icons.air,
          title: 'Tire Pressure Check',
          bike: 'Trek Domane',
          type: ReminderType.timeBased,
          dueInfo: 'Every 2 weeks',
          isOverdue: false,
          isEnabled: true,
        ),
        const SizedBox(height: 10),
        _buildReminderCard(
          icon: Icons.clean_hands,
          title: 'Deep Clean',
          bike: 'Trek Domane',
          type: ReminderType.timeBased,
          dueInfo: 'Overdue by 5 days',
          isOverdue: true,
          isEnabled: true,
        ),
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }

  Widget _buildReminderCard({
    required IconData icon,
    required String title,
    required String bike,
    required ReminderType type,
    required String dueInfo,
    required bool isOverdue,
    required bool isEnabled,
  }) {
    final statusColor = isOverdue 
        ? ChainlyTheme.errorColor 
        : ChainlyTheme.warningColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ChainlyTheme.surfaceColor,
        borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
        boxShadow: ChainlyTheme.cardShadow,
        border: isOverdue
            ? Border.all(color: ChainlyTheme.errorColor.withValues(alpha: 0.3), width: 2)
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ChainlyTheme.radiusSmall),
                ),
                child: Icon(icon, color: statusColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ChainlyTheme.textPrimary,
                            ),
                          ),
                        ),
                        Switch(
                          value: isEnabled,
                          onChanged: (value) {
                            setState(() {
                              // TODO: Toggle reminder
                            });
                          },
                          activeColor: ChainlyTheme.primaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.pedal_bike,
                          size: 14,
                          color: ChainlyTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          bike,
                          style: TextStyle(
                            fontSize: 13,
                            color: ChainlyTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          type == ReminderType.timeBased 
                              ? Icons.schedule 
                              : Icons.straighten,
                          size: 14,
                          color: ChainlyTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          type == ReminderType.timeBased 
                              ? 'Time-based' 
                              : 'Usage-based',
                          style: TextStyle(
                            fontSize: 13,
                            color: ChainlyTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isOverdue 
                  ? ChainlyTheme.errorColor.withValues(alpha: 0.05)
                  : ChainlyTheme.primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(ChainlyTheme.radiusSmall),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isOverdue ? Icons.warning_rounded : Icons.notifications_active,
                      size: 18,
                      color: statusColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dueInfo,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                if (isOverdue)
                  GestureDetector(
                    onTap: () {
                      _showSnoozeDialog(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: ChainlyTheme.warningColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.snooze,
                            size: 16,
                            color: ChainlyTheme.warningColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Snooze',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: ChainlyTheme.warningColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSnoozeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Snooze Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('1 day'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Snooze for 1 day
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('3 days'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Snooze for 3 days
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('1 week'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Snooze for 1 week
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

enum ReminderType { timeBased, usageBased }
