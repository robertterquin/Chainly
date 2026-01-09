import 'package:flutter/material.dart';
import '../../utils/theme.dart';

/// Maintenance Screen
/// Shows maintenance list (logs), status indicators (Due/Done),
/// and filter options by bike or type
class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Due', 'Done', 'Chain', 'Brakes', 'Tires'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Filter Chips
            _buildFilterChips(),

            // Maintenance List
            Expanded(
              child: _buildMaintenanceList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to Add Maintenance
        },
        backgroundColor: ChainlyTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Maintenance',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Maintenance',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: ChainlyTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '12 total records',
                style: TextStyle(
                  fontSize: 14,
                  color: ChainlyTheme.textSecondary,
                ),
              ),
            ],
          ),
          Row(
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ChainlyTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
                  boxShadow: ChainlyTheme.cardShadow,
                ),
                child: Icon(
                  Icons.sort,
                  color: ChainlyTheme.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
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
              selectedColor: ChainlyTheme.primaryColor.withOpacity(0.15),
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

  Widget _buildMaintenanceList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMaintenanceItem(
          icon: Icons.link,
          title: 'Chain Lubrication',
          bikeName: 'Canyon Aeroad CF',
          date: 'Jan 5, 2026',
          cost: '\$15.00',
          status: MaintenanceStatus.done,
        ),
        _buildMaintenanceItem(
          icon: Icons.tire_repair,
          title: 'Tire Replacement',
          bikeName: 'Canyon Aeroad CF',
          date: 'Jan 12, 2026',
          cost: '\$85.00',
          status: MaintenanceStatus.due,
        ),
        _buildMaintenanceItem(
          icon: Icons.settings,
          title: 'Brake Pad Check',
          bikeName: 'Canyon Aeroad CF',
          date: 'Jan 15, 2026',
          cost: '-',
          status: MaintenanceStatus.due,
        ),
        _buildMaintenanceItem(
          icon: Icons.build,
          title: 'Full Service',
          bikeName: 'Trek Domane',
          date: 'Dec 28, 2025',
          cost: '\$150.00',
          status: MaintenanceStatus.done,
        ),
        _buildMaintenanceItem(
          icon: Icons.link,
          title: 'Chain Replacement',
          bikeName: 'Trek Domane',
          date: 'Dec 15, 2025',
          cost: '\$45.00',
          status: MaintenanceStatus.done,
        ),
        _buildMaintenanceItem(
          icon: Icons.air,
          title: 'Tire Pressure Check',
          bikeName: 'Canyon Aeroad CF',
          date: 'Dec 10, 2025',
          cost: '\$0.00',
          status: MaintenanceStatus.done,
        ),
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }

  Widget _buildMaintenanceItem({
    required IconData icon,
    required String title,
    required String bikeName,
    required String date,
    required String cost,
    required MaintenanceStatus status,
  }) {
    final isDue = status == MaintenanceStatus.due;
    final statusColor = isDue ? ChainlyTheme.warningColor : ChainlyTheme.successColor;
    final statusText = isDue ? 'Due' : 'Done';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ChainlyTheme.surfaceColor,
        borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
        boxShadow: ChainlyTheme.cardShadow,
        border: isDue
            ? Border.all(color: ChainlyTheme.warningColor.withOpacity(0.3))
            : null,
      ),
      child: Row(
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
                Text(
                  title,
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
                    const SizedBox(width: 12),
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: ChainlyTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
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
                  color: statusColor.withOpacity(0.1),
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
                cost,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ChainlyTheme.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum MaintenanceStatus { due, done }
