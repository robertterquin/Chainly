import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_app_header.dart';

/// Ride Screen
/// Manually record ride details to calculate bike usage and trigger maintenance reminders
/// Features: Add ride, ride history, edit/delete, mileage tracking, maintenance integration
class RideScreen extends StatefulWidget {
  const RideScreen({super.key});

  @override
  State<RideScreen> createState() => _RideScreenState();
}

class _RideScreenState extends State<RideScreen> {
  String _selectedFilter = 'All Bikes';
  final List<String> _filters = ['All Bikes', 'Canyon Aeroad CF', 'Trek Domane'];

  @override
  Widget build(BuildContext context) {
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
                action: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ChainlyTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
                    boxShadow: ChainlyTheme.cardShadow,
                  ),
                  child: Icon(
                    Icons.filter_list,
                    color: ChainlyTheme.textPrimary,
                  ),
                ),
              ),
            ),

            // Stats Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildStatsCard(),
            ),
            const SizedBox(height: 16),

            // Filter Chips
            _buildFilterChips(),
            const SizedBox(height: 8),

            // Ride History List
            Expanded(
              child: _buildRideHistoryList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddRideDialog(context);
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

  Widget _buildStatsCard() {
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
              _buildStatItem('245', 'km', 'Distance'),
              _buildStatDivider(),
              _buildStatItem('8', '', 'Total Rides'),
              _buildStatDivider(),
              _buildStatItem('12.5', 'hr', 'Ride Time'),
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

  Widget _buildFilterChips() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
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

  Widget _buildRideHistoryList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildRideItem(
          date: 'Jan 8, 2026',
          bikeName: 'Canyon Aeroad CF',
          distance: '25.8 km',
          duration: '1h 15m',
          notes: 'Morning ride, great weather',
        ),
        const SizedBox(height: 12),
        _buildRideItem(
          date: 'Jan 6, 2026',
          bikeName: 'Canyon Aeroad CF',
          distance: '18.2 km',
          duration: '52m',
          notes: 'Evening commute',
        ),
        const SizedBox(height: 12),
        _buildRideItem(
          date: 'Jan 4, 2026',
          bikeName: 'Trek Domane',
          distance: '42.5 km',
          duration: '2h 18m',
          notes: 'Weekend long ride',
        ),
        const SizedBox(height: 12),
        _buildRideItem(
          date: 'Jan 3, 2026',
          bikeName: 'Canyon Aeroad CF',
          distance: '15.0 km',
          duration: '45m',
          notes: null,
        ),
        const SizedBox(height: 12),
        _buildRideItem(
          date: 'Jan 1, 2026',
          bikeName: 'Trek Domane',
          distance: '32.8 km',
          duration: '1h 42m',
          notes: 'New Year ride',
        ),
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }

  Widget _buildRideItem({
    required String date,
    required String bikeName,
    required String distance,
    required String duration,
    String? notes,
  }) {
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
                      date,
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
              PopupMenuButton(
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
                    _showEditRideDialog(context);
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(context);
                  }
                },
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
                        distance,
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
                        duration,
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
          if (notes != null) ...[
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
                    notes,
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

  void _showAddRideDialog(BuildContext context) {
    // TODO: Implement Add Ride dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Ride dialog - Coming soon!')),
    );
  }

  void _showEditRideDialog(BuildContext context) {
    // TODO: Implement Edit Ride dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit Ride dialog - Coming soon!')),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Ride deleted'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      // TODO: Implement undo functionality
                    },
                  ),
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
