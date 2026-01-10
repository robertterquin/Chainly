import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_app_header.dart';
import '../../providers/providers.dart';
import '../../models/ride.dart';

/// Ride Screen
/// Manually record ride details to calculate bike usage and trigger maintenance reminders
/// Features: Add ride, ride history, edit/delete, mileage tracking, maintenance integration
class RideScreen extends ConsumerWidget {
  const RideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ridesNotifierProvider);
    final bikeNames = ref.watch(bikeNamesMapProvider);
    final monthlyDistance = ref.watch(monthlyDistanceProvider);
    final totalRides = ref.watch(totalRidesCountProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: CustomAppHeader(
                title: 'Rides',
                description: 'Track your cycling activities',
                action: GestureDetector(
                  onTap: () => ref.read(ridesNotifierProvider.notifier).loadRides(),
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
              ),
            ),

            // Stats Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildStatsCard(monthlyDistance, totalRides),
            ),
            const SizedBox(height: 16),

            // Filter Chips
            _buildFilterChips(ref, bikeNames),
            const SizedBox(height: 8),

            // Ride History List
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null
                      ? _buildErrorState(state.error!)
                      : state.filteredRides.isEmpty
                          ? _buildEmptyState()
                          : _buildRideHistoryList(state.filteredRides, bikeNames, ref),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddRideDialog(context, ref, bikeNames);
        },
        backgroundColor: ChainlyTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Ride',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildStatsCard(double monthlyDistance, int totalRides) {
    // Calculate monthly ride time (rough estimate: 1 km = ~3 minutes for average cycling)
    final estimatedMinutes = (monthlyDistance * 3).round();
    final hours = estimatedMinutes ~/ 60;
    final minutes = estimatedMinutes % 60;
    final timeDisplay = hours > 0 ? '${hours}.${(minutes / 60 * 10).round()}' : '0.${(minutes / 6).round()}';

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
                'This Month',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
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
                    Icon(Icons.trending_up, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '+12%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
              _buildStatItem('${monthlyDistance.toStringAsFixed(1)}', 'km', 'Distance'),
              _buildStatDivider(),
              _buildStatItem('$totalRides', '', 'Total Rides'),
              _buildStatDivider(),
              _buildStatItem(timeDisplay, 'hr', 'Ride Time'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String unit, String label) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (unit.isNotEmpty)
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }

  Widget _buildFilterChips(WidgetRef ref, Map<String, String> bikeNames) {
    final selectedBikeId = ref.watch(ridesNotifierProvider).selectedBikeId;
    final filters = ['All Bikes', ...bikeNames.values];
    
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isAllBikes = filter == 'All Bikes';
          final bikeId = isAllBikes 
              ? null 
              : bikeNames.entries.firstWhere((e) => e.value == filter, orElse: () => const MapEntry('', '')).key;
          final isSelected = isAllBikes ? selectedBikeId == null : selectedBikeId == bikeId;
          
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                ref.read(ridesNotifierProvider.notifier).setBikeFilter(bikeId);
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

  Widget _buildRideHistoryList(List<Ride> rides, Map<String, String> bikeNames, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => ref.read(ridesNotifierProvider.notifier).loadRides(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rides.length + 1,
        itemBuilder: (context, index) {
          if (index == rides.length) {
            return const SizedBox(height: 80); // Space for FAB
          }
          final ride = rides[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildRideItem(
              ride: ride,
              bikeName: bikeNames[ride.bikeId] ?? 'Unknown Bike',
              ref: ref,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_bike_outlined, size: 64, color: ChainlyTheme.textSecondary),
            const SizedBox(height: 16),
            Text(
              'No rides yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ChainlyTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first ride to start tracking',
              textAlign: TextAlign.center,
              style: TextStyle(color: ChainlyTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
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

  Widget _buildRideItem({
    required Ride ride,
    required String bikeName,
    required WidgetRef ref,
  }) {
    final formattedDate = _formatDate(ride.date);
    
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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ChainlyTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ChainlyTheme.radiusSmall),
                ),
                child: Icon(
                  Icons.directions_bike,
                  color: ChainlyTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
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
                        Text(
                          bikeName,
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
              Builder(
                builder: (popupContext) => PopupMenuButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: ChainlyTheme.textSecondary,
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20),
                          SizedBox(width: 12),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 20, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditRideDialog(popupContext, ref, ride);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(popupContext, ref, ride);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ChainlyTheme.primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(ChainlyTheme.radiusSmall),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.straighten,
                        size: 16,
                        color: ChainlyTheme.primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ride.formattedDistance,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ChainlyTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: ChainlyTheme.primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ride.formattedDuration,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ChainlyTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (ride.notes != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.note_outlined,
                  size: 14,
                  color: ChainlyTheme.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    ride.notes!,
                    style: TextStyle(
                      fontSize: 13,
                      color: ChainlyTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showAddRideDialog(BuildContext context, WidgetRef ref, Map<String, String> bikeNames) {
    final distanceController = TextEditingController();
    final notesController = TextEditingController();
    String? selectedBikeId = bikeNames.keys.firstOrNull;
    DateTime selectedDate = DateTime.now();
    TimeOfDay? selectedDuration;

    if (bikeNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add a bike first in the Profile screen'),
          backgroundColor: ChainlyTheme.warningColor,
        ),
      );
      return;
    }

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
                const Text(
                  'Add New Ride',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

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

                // Date Picker
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
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
                        const SizedBox(width: 12),
                        Text(
                          'Date: ${_formatDate(selectedDate)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Distance
                TextField(
                  controller: distanceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Distance (km) *',
                    hintText: 'e.g., 25.5',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // Duration (Optional)
                GestureDetector(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedDuration ?? const TimeOfDay(hour: 1, minute: 0),
                      builder: (context, child) {
                        return MediaQuery(
                          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setModalState(() => selectedDuration = picked);
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
                        const Icon(Icons.schedule, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          selectedDuration != null
                              ? 'Duration: ${selectedDuration!.hour}h ${selectedDuration!.minute}m'
                              : 'Duration (optional)',
                          style: TextStyle(
                            fontSize: 16,
                            color: selectedDuration != null ? Colors.black : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Notes
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Notes (optional)',
                    hintText: 'Add notes about your ride...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (distanceController.text.trim().isEmpty || selectedBikeId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill in distance and select a bike')),
                        );
                        return;
                      }

                      final distance = double.tryParse(distanceController.text.trim());
                      if (distance == null || distance <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a valid distance')),
                        );
                        return;
                      }

                      final newRide = Ride(
                        bikeId: selectedBikeId!,
                        date: selectedDate,
                        distance: distance,
                        duration: selectedDuration != null
                            ? Duration(hours: selectedDuration!.hour, minutes: selectedDuration!.minute)
                            : null,
                        notes: notesController.text.trim().isEmpty 
                            ? null 
                            : notesController.text.trim(),
                      );

                      try {
                        await ref.read(ridesNotifierProvider.notifier).addRide(newRide);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Ride added successfully!'),
                              backgroundColor: ChainlyTheme.successColor,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to add ride: ${e.toString()}')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ChainlyTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Add Ride',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
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

  void _showEditRideDialog(BuildContext context, WidgetRef ref, Ride ride) {
    // TODO: Implement Edit Ride dialog (similar to Add)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit Ride dialog - Coming soon!')),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Ride ride) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ride'),
        content: const Text('Are you sure you want to delete this ride? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (ride.id != null) {
                try {
                  await ref.read(ridesNotifierProvider.notifier).deleteRide(ride.id!);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Ride deleted'),
                        backgroundColor: ChainlyTheme.successColor,
                      ),
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
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
