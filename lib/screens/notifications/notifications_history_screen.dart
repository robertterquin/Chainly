import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/theme.dart';
import '../../providers/reminder_provider.dart';
import '../../models/reminder.dart';
import '../../providers/bike_provider.dart';
import 'package:intl/intl.dart';

/// Notifications History Screen
/// Shows all notifications including overdue, upcoming, and completed reminders
class NotificationsHistoryScreen extends ConsumerStatefulWidget {
  const NotificationsHistoryScreen({super.key});

  @override
  ConsumerState<NotificationsHistoryScreen> createState() => _NotificationsHistoryScreenState();
}

class _NotificationsHistoryScreenState extends ConsumerState<NotificationsHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reminders = ref.watch(remindersProvider);
    final overdueReminders = reminders.where((r) => r.isOverdue && r.isEnabled).toList();
    final upcomingReminders = reminders.where((r) => !r.isOverdue && r.isEnabled && r.dueDate != null).toList();
    final allReminders = reminders.where((r) => r.isEnabled).toList();

    return Scaffold(
      backgroundColor: ChainlyTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: ChainlyTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: ChainlyTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: ChainlyTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: ChainlyTheme.primaryColor,
          unselectedLabelColor: ChainlyTheme.textSecondary,
          indicatorColor: ChainlyTheme.primaryColor,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('All'),
                  if (allReminders.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: ChainlyTheme.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${allReminders.length}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Overdue'),
                  if (overdueReminders.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: ChainlyTheme.errorColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${overdueReminders.length}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Upcoming'),
                  if (upcomingReminders.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: ChainlyTheme.warningColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${upcomingReminders.length}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationList(allReminders, 'All'),
          _buildNotificationList(overdueReminders, 'Overdue'),
          _buildNotificationList(upcomingReminders, 'Upcoming'),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<Reminder> reminders, String type) {
    if (reminders.isEmpty) {
      return _buildEmptyState(type);
    }

    // Sort by due date
    final sortedReminders = List<Reminder>.from(reminders)
      ..sort((a, b) {
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(remindersNotifierProvider.notifier).loadReminders();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: sortedReminders.length,
        itemBuilder: (context, index) {
          final reminder = sortedReminders[index];
          return _buildNotificationCard(reminder);
        },
      ),
    );
  }

  Widget _buildNotificationCard(Reminder reminder) {
    final bikes = ref.watch(bikesNotifierProvider).bikes;
    final bike = bikes.firstWhere(
      (b) => b.id == reminder.bikeId,
      orElse: () => bikes.first,
    );
    
    final isOverdue = reminder.isOverdue;
    final statusColor = isOverdue ? ChainlyTheme.errorColor : ChainlyTheme.warningColor;
    
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

    // Get due info string
    String dueInfo;
    String timeAgo = '';
    if (reminder.type == ReminderType.timeBased && reminder.dueDate != null) {
      final days = reminder.dueDate!.difference(DateTime.now()).inDays;
      if (days < 0) {
        dueInfo = 'Overdue by ${-days} days';
        timeAgo = DateFormat('MMM dd, yyyy').format(reminder.dueDate!);
      } else if (days == 0) {
        dueInfo = 'Due today';
        timeAgo = DateFormat('h:mm a').format(reminder.dueDate!);
      } else if (days == 1) {
        dueInfo = 'Due tomorrow';
        timeAgo = DateFormat('h:mm a').format(reminder.dueDate!);
      } else {
        dueInfo = 'Due in $days days';
        timeAgo = DateFormat('MMM dd').format(reminder.dueDate!);
      }
    } else if (reminder.type == ReminderType.usageBased) {
      dueInfo = 'Usage-based reminder';
      timeAgo = 'Every ${reminder.intervalDistance} km';
    } else {
      dueInfo = 'No due date';
      timeAgo = '';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ChainlyTheme.surfaceColor,
        borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
        boxShadow: ChainlyTheme.cardShadow,
        border: Border.all(
          color: isOverdue ? ChainlyTheme.errorColor.withOpacity(0.3) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to maintenance hub or reminder details
        },
        borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
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
                            reminder.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ChainlyTheme.textPrimary,
                            ),
                          ),
                        ),
                        if (isOverdue)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: ChainlyTheme.errorColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'OVERDUE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.pedal_bike,
                          size: 14,
                          color: ChainlyTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          bike.name,
                          style: TextStyle(
                            fontSize: 13,
                            color: ChainlyTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          isOverdue ? Icons.warning_rounded : Icons.schedule,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dueInfo,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: statusColor,
                          ),
                        ),
                        if (timeAgo.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            '• $timeAgo',
                            style: TextStyle(
                              fontSize: 12,
                              color: ChainlyTheme.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (reminder.description != null && reminder.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        reminder.description!,
                        style: TextStyle(
                          fontSize: 13,
                          color: ChainlyTheme.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    String message;
    IconData icon;
    
    switch (type) {
      case 'Overdue':
        message = 'No overdue reminders';
        icon = Icons.check_circle_outline;
        break;
      case 'Upcoming':
        message = 'No upcoming reminders';
        icon = Icons.notifications_off_outlined;
        break;
      default:
        message = 'No notifications yet';
        icon = Icons.notifications_none;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ChainlyTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            type == 'Overdue' 
                ? 'Great! All your maintenance is up to date'
                : 'Add reminders to get notified',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
