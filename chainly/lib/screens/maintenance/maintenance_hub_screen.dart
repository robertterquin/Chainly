import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/maintenance.dart';
import '../../models/reminder.dart';
import '../../providers/providers.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_app_header.dart';

/// Unified Maintenance Hub Screen
/// Combines reminders and maintenance logs in one scrollable view
class MaintenanceHubScreen extends ConsumerWidget {
  const MaintenanceHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maintenanceState = ref.watch(maintenanceNotifierProvider);
    final remindersState = ref.watch(remindersNotifierProvider);
    final bikeNames = ref.watch(bikeNamesMapProvider);
    final activeReminderCount = remindersState.reminders.where((r) => r.isEnabled).length;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: CustomAppHeader(
                  title: 'Maintenance Hub',
                  description: '${maintenanceState.records.length} records • $activeReminderCount reminders',
                  action: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: ChainlyTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
                          boxShadow: ChainlyTheme.cardShadow,
                        ),
                        child: Icon(
                          Icons.search,
                          color: ChainlyTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => ref.read(maintenanceNotifierProvider.notifier).loadMaintenance(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: ChainlyTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
                            boxShadow: ChainlyTheme.cardShadow,
                          ),
                          child: Icon(
                            Icons.refresh,
                            color: ChainlyTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Reminders Section
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _RemindersSection(),
              ),
            ),

            // Divider
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Divider(color: Colors.grey.shade300, thickness: 1),
              ),
            ),

            // Maintenance Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.build, 
                          color: ChainlyTheme.primaryColor, 
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Maintenance Log',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: ChainlyTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Filter Chips
            SliverToBoxAdapter(
              child: _FilterChips(),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Maintenance List
            if (maintenanceState.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (maintenanceState.error != null)
              SliverFillRemaining(
                child: _ErrorState(error: maintenanceState.error!),
              )
            else if (maintenanceState.filteredRecords.isEmpty)
              const SliverFillRemaining(
                child: _EmptyState(type: 'maintenance'),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == maintenanceState.filteredRecords.length) {
                        return const SizedBox(height: 100); // Space for FABs
                      }
                      final record = maintenanceState.filteredRecords[index];
                      return _MaintenanceItem(record: record, bikeNames: bikeNames);
                    },
                    childCount: maintenanceState.filteredRecords.length + 1,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButtons(context, ref),
    );
  }

  Widget _buildFloatingActionButtons(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      heroTag: 'add_item',
      onPressed: () => _showAddDialog(context, ref),
      backgroundColor: ChainlyTheme.primaryColor,
      tooltip: 'Add Maintenance or Reminder',
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddItemBottomSheet(ref: ref),
    );
  }

  void _showMaintenanceForm(BuildContext context, WidgetRef ref, Maintenance? record) {
    final isEditing = record != null;
    final titleController = TextEditingController(text: record?.title ?? '');
    final costController = TextEditingController(
      text: record?.cost.toString() ?? '',
    );
    final notesController = TextEditingController(text: record?.notes ?? '');
    String selectedCategory = record?.category.name ?? 'chain';
    String selectedStatus = record?.status.name ?? 'done';
    String? selectedBikeId = record?.bikeId;
    DateTime selectedDate = record?.date ?? DateTime.now();
    final bikeNames = ref.read(bikeNamesMapProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isEditing ? 'Edit Maintenance' : 'Add Maintenance',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Title
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // Bike Dropdown
                DropdownButtonFormField<String>(
                  value: selectedBikeId,
                  decoration: InputDecoration(
                    labelText: 'Bike',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: bikeNames.entries
                      .map((e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          ))
                      .toList(),
                  onChanged: (value) => setModalState(() => selectedBikeId = value),
                ),
                const SizedBox(height: 16),

                // Category & Status Row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: ['chain', 'brakes', 'tires', 'service', 'other']
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c.capitalize()),
                                ))
                            .toList(),
                        onChanged: (value) => setModalState(() => selectedCategory = value!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: ['done', 'due']
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s.capitalize()),
                                ))
                            .toList(),
                        onChanged: (value) => setModalState(() => selectedStatus = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Date & Cost Row
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setModalState(() => selectedDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 20),
                              const SizedBox(width: 8),
                              Text(_formatDate(selectedDate)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: costController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Cost (₱)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Notes
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (titleController.text.isEmpty || selectedBikeId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill in title and select a bike')),
                        );
                        return;
                      }

                      final maintenance = Maintenance(
                        id: record?.id,
                        bikeId: selectedBikeId!,
                        title: titleController.text.trim(),
                        category: MaintenanceCategory.fromString(selectedCategory),
                        status: MaintenanceStatus.fromString(selectedStatus),
                        date: selectedDate,
                        cost: double.tryParse(costController.text) ?? 0,
                        notes: notesController.text.trim().isEmpty 
                            ? null 
                            : notesController.text.trim(),
                      );

                      try {
                        if (isEditing) {
                          await ref
                              .read(maintenanceNotifierProvider.notifier)
                              .updateMaintenance(maintenance);
                        } else {
                          await ref
                              .read(maintenanceNotifierProvider.notifier)
                              .addMaintenance(maintenance);
                        }
                        if (context.mounted) Navigator.pop(context);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to save: ${e.toString()}')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ChainlyTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      isEditing ? 'Update' : 'Add Maintenance',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

// Reminders Section
class _RemindersSection extends ConsumerWidget {
  const _RemindersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersState = ref.watch(remindersNotifierProvider);
    final bikeNames = ref.watch(bikeNamesMapProvider);
    
    // Calculate stats
    final activeReminders = remindersState.reminders.where((r) => r.isEnabled).toList();
    final now = DateTime.now();
    final dueSoon = activeReminders.where((r) {
      if (r.type == ReminderType.timeBased && r.dueDate != null) {
        return r.dueDate!.isAfter(now) && r.dueDate!.difference(now).inDays <= 7;
      }
      return false;
    }).length;
    final overdue = activeReminders.where((r) => r.isOverdue).length;

    // Get upcoming reminders (overdue + due soon)
    final upcomingReminders = activeReminders.where((r) {
      if (r.type == ReminderType.timeBased && r.dueDate != null) {
        return r.dueDate!.isBefore(now.add(const Duration(days: 7)));
      }
      return true; // Include usage-based reminders
    }).take(5).toList();

    if (remindersState.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.notifications_active, 
                  color: ChainlyTheme.primaryColor, 
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Reminders',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ChainlyTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Active Reminders Stats
        _buildActiveRemindersCard(activeReminders.length, dueSoon, overdue),
        const SizedBox(height: 20),

        // Upcoming Reminders
        if (upcomingReminders.isEmpty)
          _buildEmptyState()
        else
          _buildUpcomingReminders(upcomingReminders, bikeNames, ref),
      ],
    );
  }

  Widget _buildActiveRemindersCard(int total, int dueSoon, int overdue) {
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
              _buildReminderStatItem('$total', 'Total'),
              _buildReminderStatItem('$dueSoon', 'Due Soon'),
              _buildReminderStatItem('$overdue', 'Overdue'),
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

  Widget _buildEmptyState() {
    return Container(
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
            const SizedBox(height: 12),
            Text(
              'No Active Reminders',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ChainlyTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first reminder to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingReminders(List<dynamic> reminders, Map<String, String> bikeNames, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due Soon',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: ChainlyTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...reminders.map((reminder) {
          final bikeName = bikeNames[reminder.bikeId] ?? 'Unknown Bike';
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildReminderCard(
              reminder: reminder,
              bikeName: bikeName,
              ref: ref,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildReminderCard({
    required dynamic reminder,
    required String bikeName,
    required WidgetRef ref,
  }) {
    final isOverdue = reminder.isOverdue;
    final statusColor = isOverdue 
        ? ChainlyTheme.errorColor 
        : ChainlyTheme.warningColor;
    
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
    if (reminder.type == ReminderType.timeBased && reminder.dueDate != null) {
      final days = reminder.dueDate!.difference(DateTime.now()).inDays;
      if (days < 0) {
        dueInfo = 'Overdue by ${-days} days';
      } else if (days == 0) {
        dueInfo = 'Due today';
      } else if (days == 1) {
        dueInfo = 'Due tomorrow';
      } else {
        dueInfo = 'Due in $days days';
      }
    } else if (reminder.type == ReminderType.usageBased) {
      // For usage-based, we'd need current bike mileage - for now show interval
      if (reminder.intervalDistance != null) {
        dueInfo = '${reminder.intervalDistance!.toStringAsFixed(0)} km interval';
      } else {
        dueInfo = 'Usage-based';
      }
    } else {
      dueInfo = 'No due date';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ChainlyTheme.surfaceColor,
        borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
        boxShadow: ChainlyTheme.cardShadow,
        border: isOverdue
            ? Border.all(color: ChainlyTheme.errorColor.withValues(alpha: 0.3), width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ChainlyTheme.radiusSmall),
            ),
            child: Icon(icon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ChainlyTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.pedal_bike,
                      size: 12,
                      color: ChainlyTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      bikeName,
                      style: TextStyle(
                        fontSize: 12,
                        color: ChainlyTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      isOverdue ? Icons.warning_rounded : Icons.schedule,
                      size: 12,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        dueInfo,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: reminder.isEnabled,
            onChanged: (value) async {
              await ref.read(remindersNotifierProvider.notifier).toggleEnabled(reminder.id!);
            },
            activeColor: ChainlyTheme.primaryColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

// Filter Chips
class _FilterChips extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(maintenanceFilterProvider);
    final filters = ['All', 'Due', 'Done', 'Chain', 'Brakes', 'Tires'];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                ref.read(maintenanceNotifierProvider.notifier).setFilter(filter);
              },
              backgroundColor: ChainlyTheme.surfaceColor,
              selectedColor: ChainlyTheme.primaryColor.withValues(alpha: 0.15),
              labelStyle: TextStyle(
                color: isSelected ? ChainlyTheme.primaryColor : ChainlyTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? ChainlyTheme.primaryColor : Colors.grey.shade300,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Error State
class _ErrorState extends StatelessWidget {
  final String error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: ChainlyTheme.errorColor),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: ChainlyTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// Empty State
class _EmptyState extends StatelessWidget {
  final String type;

  const _EmptyState({required this.type});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.build_outlined, size: 64, color: ChainlyTheme.textSecondary),
          const SizedBox(height: 16),
          Text(
            'No maintenance records yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ChainlyTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first maintenance record',
            style: TextStyle(color: ChainlyTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

// Maintenance Item
class _MaintenanceItem extends ConsumerWidget {
  final Maintenance record;
  final Map<String, String> bikeNames;

  const _MaintenanceItem({
    required this.record,
    required this.bikeNames,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDue = record.status == MaintenanceStatus.due;
    final statusColor = isDue ? ChainlyTheme.warningColor : ChainlyTheme.successColor;
    final statusText = isDue ? 'Due' : 'Done';
    final bikeName = bikeNames[record.bikeId] ?? 'Unknown Bike';
    final costText = record.cost > 0 ? '₱${record.cost.toStringAsFixed(2)}' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ChainlyTheme.surfaceColor,
        borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
        boxShadow: ChainlyTheme.cardShadow,
        border: isDue
            ? Border.all(color: ChainlyTheme.warningColor.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ChainlyTheme.radiusSmall),
            ),
            child: Icon(_getCategoryIcon(record.category), color: statusColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ChainlyTheme.textPrimary,
                  ),
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
                    Flexible(
                      child: Text(
                        bikeName,
                        style: TextStyle(
                          fontSize: 13,
                          color: ChainlyTheme.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: ChainlyTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(record.date),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                costText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ChainlyTheme.textPrimary,
                ),
              ),
            ],
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert, color: ChainlyTheme.textSecondary),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(
                value: 'toggle',
                child: Text(isDue ? 'Mark as Done' : 'Mark as Due'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
            onSelected: (value) {
              if (value != null) _handleMenuAction(context, ref, value);
            },
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(MaintenanceCategory category) {
    switch (category) {
      case MaintenanceCategory.chain:
        return Icons.link;
      case MaintenanceCategory.brakes:
        return Icons.settings;
      case MaintenanceCategory.tires:
        return Icons.tire_repair;
      case MaintenanceCategory.service:
        return Icons.build;
      default:
        return Icons.handyman;
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _handleMenuAction(BuildContext context, WidgetRef ref, String action) async {
    switch (action) {
      case 'edit':
        final screen = context.findAncestorWidgetOfExactType<MaintenanceHubScreen>();
        if (screen != null) {
          screen._showMaintenanceForm(context, ref, record);
        }
        break;
      case 'toggle':
        await _toggleStatus(context, ref);
        break;
      case 'delete':
        await _deleteRecord(context, ref);
        break;
    }
  }

  Future<void> _toggleStatus(BuildContext context, WidgetRef ref) async {
    if (record.id == null) return;
    try {
      await ref.read(maintenanceNotifierProvider.notifier).toggleStatus(record.id!);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteRecord(BuildContext context, WidgetRef ref) async {
    if (record.id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Maintenance'),
        content: const Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(maintenanceNotifierProvider.notifier).deleteMaintenance(record.id!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Maintenance record deleted')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: ${e.toString()}')),
          );
        }
      }
    }
  }
}

// Combined Add Item Bottom Sheet
class _AddItemBottomSheet extends StatefulWidget {
  final WidgetRef ref;

  const _AddItemBottomSheet({required this.ref});

  @override
  State<_AddItemBottomSheet> createState() => _AddItemBottomSheetState();
}

class _AddItemBottomSheetState extends State<_AddItemBottomSheet> {
  int _selectedTab = 0; // 0 = Maintenance, 1 = Reminder

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tab Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTab == 0 ? ChainlyTheme.primaryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.build,
                              color: _selectedTab == 0 ? Colors.white : ChainlyTheme.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Maintenance',
                              style: TextStyle(
                                color: _selectedTab == 0 ? Colors.white : ChainlyTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1 ? ChainlyTheme.warningColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_active,
                              color: _selectedTab == 1 ? Colors.white : ChainlyTheme.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Reminder',
                              style: TextStyle(
                                color: _selectedTab == 1 ? Colors.white : ChainlyTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _selectedTab == 0
                  ? _MaintenanceForm(ref: widget.ref)
                  : _ReminderForm(ref: widget.ref),
            ),
          ),
        ],
      ),
    );
  }
}

// Maintenance Form Widget
class _MaintenanceForm extends StatefulWidget {
  final WidgetRef ref;

  const _MaintenanceForm({required this.ref});

  @override
  State<_MaintenanceForm> createState() => _MaintenanceFormState();
}

class _MaintenanceFormState extends State<_MaintenanceForm> {
  final _titleController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedCategory = 'chain';
  String _selectedStatus = 'done';
  String? _selectedBikeId;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bikeNames = widget.ref.read(bikeNamesMapProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Title *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedBikeId,
          decoration: InputDecoration(
            labelText: 'Bike *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: bikeNames.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: (value) => setState(() => _selectedBikeId = value),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: ['chain', 'brakes', 'tires', 'service', 'other']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.capitalize())))
                    .toList(),
                onChanged: (value) => setState(() => _selectedCategory = value!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: ['done', 'due']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.capitalize())))
                    .toList(),
                onChanged: (value) => setState(() => _selectedStatus = value!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 8),
                      Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _costController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Cost (₱)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Notes (optional)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveMaintenance,
            style: ElevatedButton.styleFrom(
              backgroundColor: ChainlyTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Add Maintenance',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<void> _saveMaintenance() async {
    if (_titleController.text.isEmpty || _selectedBikeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in title and select a bike')),
      );
      return;
    }

    final maintenance = Maintenance(
      bikeId: _selectedBikeId!,
      title: _titleController.text.trim(),
      category: MaintenanceCategory.fromString(_selectedCategory),
      status: MaintenanceStatus.fromString(_selectedStatus),
      date: _selectedDate,
      cost: double.tryParse(_costController.text) ?? 0,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    try {
      await widget.ref.read(maintenanceNotifierProvider.notifier).addMaintenance(maintenance);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: ${e.toString()}')),
        );
      }
    }
  }
}

// Reminder Form Widget
class _ReminderForm extends StatefulWidget {
  final WidgetRef ref;

  const _ReminderForm({required this.ref});

  @override
  State<_ReminderForm> createState() => _ReminderFormState();
}

class _ReminderFormState extends State<_ReminderForm> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _intervalDaysController = TextEditingController();
  final _intervalDistanceController = TextEditingController();
  String _selectedType = 'time_based';
  String _selectedCategory = 'chain';
  String _selectedPriority = 'normal';
  String? _selectedBikeId;
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 7));
  bool _isRecurring = true;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _intervalDaysController.dispose();
    _intervalDistanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bikeNames = widget.ref.read(bikeNamesMapProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Title *',
            hintText: 'e.g., Chain Lubrication',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Description (optional)',
            hintText: 'Additional details',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedBikeId,
          decoration: InputDecoration(
            labelText: 'Bike *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: bikeNames.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: (value) => setState(() => _selectedBikeId = value),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedType,
          decoration: InputDecoration(
            labelText: 'Reminder Type',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: const [
            DropdownMenuItem(value: 'time_based', child: Text('Time-based (days)')),
            DropdownMenuItem(value: 'usage_based', child: Text('Usage-based (km)')),
          ],
          onChanged: (value) => setState(() => _selectedType = value!),
        ),
        const SizedBox(height: 16),
        if (_selectedType == 'time_based') ...[
          TextField(
            controller: _intervalDaysController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Interval (days) *',
              hintText: 'e.g., 14 for every 2 weeks',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDueDate,
                firstDate: DateTime.now(),
                lastDate: DateTime(2030),
              );
              if (picked != null) setState(() => _selectedDueDate = picked);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20),
                  const SizedBox(width: 8),
                  Text('Due Date: ${_selectedDueDate.day}/${_selectedDueDate.month}/${_selectedDueDate.year}'),
                ],
              ),
            ),
          ),
        ] else ...[
          TextField(
            controller: _intervalDistanceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Interval Distance (km) *',
              hintText: 'e.g., 500 for every 500 km',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: ['chain', 'brakes', 'tires', 'service', 'other']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.capitalize())))
                    .toList(),
                onChanged: (value) => setState(() => _selectedCategory = value!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedPriority,
                decoration: InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                  DropdownMenuItem(value: 'normal', child: Text('Normal')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                ],
                onChanged: (value) => setState(() => _selectedPriority = value!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Recurring Reminder'),
          subtitle: Text(_isRecurring 
              ? 'Will repeat after completion' 
              : 'One-time reminder'),
          value: _isRecurring,
          onChanged: (value) => setState(() => _isRecurring = value),
          activeColor: ChainlyTheme.primaryColor,
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveReminder,
            style: ElevatedButton.styleFrom(
              backgroundColor: ChainlyTheme.warningColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Add Reminder',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<void> _saveReminder() async {
    if (_titleController.text.isEmpty || _selectedBikeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in title and select a bike')),
      );
      return;
    }

    if (_selectedType == 'time_based' && _intervalDaysController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter interval days')),
      );
      return;
    }

    if (_selectedType == 'usage_based' && _intervalDistanceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter interval distance')),
      );
      return;
    }

    // Get current user ID
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    final reminder = Reminder(
      userId: userId,
      bikeId: _selectedBikeId!,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      type: _selectedType == 'time_based' ? ReminderType.timeBased : ReminderType.usageBased,
      intervalDays: _selectedType == 'time_based' 
          ? int.tryParse(_intervalDaysController.text) 
          : null,
      dueDate: _selectedType == 'time_based' ? _selectedDueDate : null,
      intervalDistance: _selectedType == 'usage_based' 
          ? double.tryParse(_intervalDistanceController.text) 
          : null,
      isRecurring: _isRecurring,
      category: _selectedCategory,
      priority: ReminderPriority.fromString(_selectedPriority),
    );

    try {
      await widget.ref.read(remindersNotifierProvider.notifier).addReminder(reminder);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: ${e.toString()}')),
        );
      }
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
