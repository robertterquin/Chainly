import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_app_header.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';

/// Dashboard (Home) Screen
/// Shows bike status summary, last maintenance, upcoming reminders,
/// quick actions, and cycling tips
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh data when dashboard loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bikesNotifierProvider.notifier).loadBikes();
      ref.read(maintenanceNotifierProvider.notifier).loadMaintenance();
      ref.read(remindersNotifierProvider.notifier).loadReminders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final String greetingName = user?.userMetadata?['full_name'] ?? 'Rider';
    
    // Get data from providers
    final bikesState = ref.watch(bikesNotifierProvider);
    final maintenanceState = ref.watch(maintenanceNotifierProvider);
    final remindersState = ref.watch(remindersNotifierProvider);
    
    // Debug: Print data counts
    debugPrint('Dashboard - Bikes: ${bikesState.bikes.length}');
    debugPrint('Dashboard - Maintenance: ${maintenanceState.records.length}');
    debugPrint('Dashboard - Reminders: ${remindersState.reminders.length}');
    
    // Print all maintenance records for debugging
    for (var m in maintenanceState.records) {
      debugPrint('Maintenance Record: id=${m.id}, title=${m.title}, bikeId=${m.bikeId}');
    }
    
    // Get active bike (first bike or null)
    final activeBike = bikesState.bikes.isNotEmpty ? bikesState.bikes.first : null;
    
    if (activeBike != null) {
      debugPrint('Dashboard - Active Bike ID: ${activeBike.id}');
      debugPrint('Dashboard - Active Bike: ${activeBike.name}, Mileage: ${activeBike.totalMileage}');
    }
    
    // Get last maintenance - show most recent regardless of bike if none match
    List<Maintenance> lastMaintenance;
    if (activeBike != null && maintenanceState.records.any((m) => m.bikeId == activeBike.id)) {
      // Filter by active bike if there are matching records
      lastMaintenance = maintenanceState.records
          .where((m) => m.bikeId == activeBike.id)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } else {
      // Show all maintenance records sorted by date
      lastMaintenance = maintenanceState.records.toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    }
    
    debugPrint('Dashboard - Filtered Maintenance Count: ${lastMaintenance.length}');
    final lastMaintenanceRecord = lastMaintenance.isNotEmpty ? lastMaintenance.first : null;
    
    // Get upcoming reminders (enabled reminders with due dates or all enabled if no due dates)
    final now = DateTime.now();
    final enabledReminders = remindersState.reminders.where((r) => r.isEnabled).toList();
    final upcomingReminders = enabledReminders
        .where((r) {
          if (r.dueDate == null) return true; // Include usage-based reminders without due date
          return r.dueDate!.isBefore(now.add(const Duration(days: 30))); // Extended to 30 days
        })
        .toList()
      ..sort((a, b) {
        // Sort by due date, nulls last
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
    
    final activeRemindersCount = remindersState.reminders.where((r) => r.isEnabled).length;

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
                greeting: '${getGreeting()}, $greetingName 👋',
                action: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ChainlyTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
                    boxShadow: ChainlyTheme.cardShadow,
                  ),
                  child: Badge(
                    label: Text('${upcomingReminders.length}'),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: ChainlyTheme.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Bike Status Card
              _buildBikeStatusCard(activeBike, activeRemindersCount),
              const SizedBox(height: 20),

              // Last Maintenance Info
              _buildLastMaintenanceCard(lastMaintenanceRecord, activeBike),
              const SizedBox(height: 20),

              // Upcoming Reminders
              _buildUpcomingRemindersSection(upcomingReminders, ref),
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

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildBikeStatusCard(Bike? bike, int activeRemindersCount) {
    if (bike == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: ChainlyTheme.primaryGradient,
          borderRadius: BorderRadius.circular(ChainlyTheme.radiusLarge),
          boxShadow: ChainlyTheme.buttonShadow,
        ),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.pedal_bike_outlined, color: Colors.white, size: 48),
              const SizedBox(height: 12),
              const Text(
                'No Bikes Yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your first bike to get started',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      );
    }

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
          Row(
            children: [
              const Icon(Icons.pedal_bike, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bike.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${bike.type ?? "Bike"} • ${bike.totalMileage?.toStringAsFixed(0) ?? "0"} km total',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBikeStatItem('Total Distance', '${bike.totalMileage?.toStringAsFixed(0) ?? "0"} km'),
              _buildBikeStatItem('Type', bike.type ?? 'N/A'),
              _buildBikeStatItem('Reminders', '$activeRemindersCount active'),
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

  Widget _buildLastMaintenanceCard(Maintenance? maintenance, Bike? bike) {
    if (maintenance == null) {
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
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.build_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No Maintenance Records',
                    style: TextStyle(
                      fontSize: 14,
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

    // Get icon and color based on category
    IconData icon = Icons.build;
    Color color = maintenance.status == MaintenanceStatus.done 
        ? ChainlyTheme.successColor 
        : ChainlyTheme.warningColor;
    switch (maintenance.category) {
      case MaintenanceCategory.chain:
        icon = Icons.link;
        break;
      case MaintenanceCategory.brakes:
        icon = Icons.settings;
        break;
      case MaintenanceCategory.tires:
        icon = Icons.tire_repair;
        break;
      default:
        icon = Icons.build;
    }

    // Calculate days since maintenance
    final daysSince = DateTime.now().difference(maintenance.date).inDays;
    String dateText;
    if (maintenance.status == MaintenanceStatus.due) {
      if (daysSince < 0) {
        final daysUntil = -daysSince;
        dateText = daysUntil == 1 ? 'Due tomorrow' : 'Due in $daysUntil days';
      } else if (daysSince == 0) {
        dateText = 'Due today';
      } else {
        dateText = 'Overdue by $daysSince days';
      }
    } else {
      if (daysSince == 0) {
        dateText = 'Completed today';
      } else if (daysSince == 1) {
        dateText = 'Completed yesterday';
      } else {
        dateText = 'Completed $daysSince days ago';
      }
    }
    
    final statusText = maintenance.status == MaintenanceStatus.done ? 'Done' : 'Due';

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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ChainlyTheme.radiusSmall),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      maintenance.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: ChainlyTheme.textPrimary,
                      ),
                    ),
                    Text(
                      dateText,
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingRemindersSection(List<Reminder> reminders, WidgetRef ref) {
    final bikeNames = ref.read(bikeNamesMapProvider);

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
        if (reminders.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ChainlyTheme.surfaceColor,
              borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
              boxShadow: ChainlyTheme.cardShadow,
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No Upcoming Reminders',
                    style: TextStyle(
                      fontSize: 14,
                      color: ChainlyTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...reminders.take(3).map((reminder) {
            final bikeName = bikeNames[reminder.bikeId] ?? 'Unknown Bike';
            final isOverdue = reminder.dueDate != null && reminder.isOverdue;
            
            // Get icon based on category
            IconData icon = Icons.build;
            switch (reminder.category) {
              case 'chain':
                icon = Icons.link;
                break;
              case 'brakes':
                icon = Icons.settings;
                break;
              case 'tires':
                icon = Icons.tire_repair;
                break;
              case 'service':
                icon = Icons.clean_hands;
                break;
              default:
                icon = Icons.build;
            }

            // Get due info
            String subtitle;
            if (reminder.dueDate != null) {
              final days = reminder.dueDate!.difference(DateTime.now()).inDays;
              if (days < 0) {
                subtitle = 'Overdue by ${-days} days';
              } else if (days == 0) {
                subtitle = 'Due today';
              } else if (days == 1) {
                subtitle = 'Due tomorrow';
              } else {
                subtitle = 'Due in $days days';
              }
            } else if (reminder.type == ReminderType.usageBased) {
              subtitle = 'Usage-based reminder';
            } else {
              subtitle = 'No due date';
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildReminderItem(
                icon: icon,
                title: reminder.title,
                subtitle: subtitle,
                color: isOverdue ? ChainlyTheme.errorColor : ChainlyTheme.warningColor,
              ),
            );
          }),
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
