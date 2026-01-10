import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/maintenance.dart';
import '../../providers/providers.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_app_header.dart';

/// Maintenance Screen (Riverpod Version)
/// Shows maintenance list (logs), status indicators (Due/Done),
/// and filter options by bike or type
class MaintenanceScreen extends ConsumerWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(maintenanceNotifierProvider);
    final bikeNames = ref.watch(bikeNamesMapProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: CustomAppHeader(
                title: 'Maintenance',
                description: '${state.records.length} total records',
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

            // Filter Chips
            _FilterChips(),

            // Maintenance List
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null
                      ? _ErrorState(error: state.error!)
                      : state.filteredRecords.isEmpty
                          ? const _EmptyState()
                          : _MaintenanceList(
                              records: state.filteredRecords,
                              bikeNames: bikeNames,
                            ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMaintenanceDialog(context, ref),
        backgroundColor: ChainlyTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Maintenance',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showAddMaintenanceDialog(BuildContext context, WidgetRef ref) {
    _showMaintenanceForm(context, ref, null);
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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

class _MaintenanceList extends ConsumerWidget {
  final List<Maintenance> records;
  final Map<String, String> bikeNames;

  const _MaintenanceList({
    required this.records,
    required this.bikeNames,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => ref.read(maintenanceNotifierProvider.notifier).loadMaintenance(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: records.length + 1, // +1 for bottom padding
        itemBuilder: (context, index) {
          if (index == records.length) {
            return const SizedBox(height: 80); // Space for FAB
          }
          final record = records[index];
          return _MaintenanceItem(record: record, bikeNames: bikeNames);
        },
      ),
    );
  }
}

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
        final screen = context.findAncestorWidgetOfExactType<MaintenanceScreen>();
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

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
