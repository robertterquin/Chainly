import 'package:flutter/material.dart';
import '../../utils/theme.dart';

/// Ride Screen
/// Shows Start/Stop ride controls, ride stats (time, distance),
/// and ride history
class RideScreen extends StatefulWidget {
  const RideScreen({super.key});

  @override
  State<RideScreen> createState() => _RideScreenState();
}

class _RideScreenState extends State<RideScreen> {
  bool _isRiding = false;

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
              _buildHeader(),
              const SizedBox(height: 24),

              // Ride Control Card
              _buildRideControlCard(),
              const SizedBox(height: 24),

              // Current/Last Ride Stats
              _buildCurrentRideStats(),
              const SizedBox(height: 24),

              // Ride History Section
              _buildRideHistorySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ride',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: ChainlyTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _isRiding ? 'Ride in progress...' : 'Ready to ride?',
              style: TextStyle(
                fontSize: 14,
                color: ChainlyTheme.textSecondary,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: ChainlyTheme.surfaceColor,
            borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
            boxShadow: ChainlyTheme.cardShadow,
          ),
          child: Icon(
            Icons.history,
            color: ChainlyTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildRideControlCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: _isRiding ? ChainlyTheme.accentGradient : ChainlyTheme.primaryGradient,
        borderRadius: BorderRadius.circular(ChainlyTheme.radiusXLarge),
        boxShadow: ChainlyTheme.buttonShadow,
      ),
      child: Column(
        children: [
          // Bike selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.pedal_bike, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Canyon Aeroad CF',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Timer display
          Text(
            _isRiding ? '00:45:32' : '00:00:00',
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isRiding ? 'Elapsed Time' : 'Tap to Start',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 30),

          // Start/Stop Button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isRiding) ...[
                // Pause button
                GestureDetector(
                  onTap: () {
                    // TODO: Pause ride
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.pause,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
              ],
              // Start/Stop button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isRiding = !_isRiding;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRiding ? Icons.stop : Icons.play_arrow,
                    color: _isRiding ? ChainlyTheme.errorColor : ChainlyTheme.primaryColor,
                    size: 40,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentRideStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isRiding ? 'Current Ride' : 'Last Ride Stats',
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
              child: _buildStatCard(
                icon: Icons.straighten,
                value: _isRiding ? '12.5' : '25.8',
                unit: 'km',
                label: 'Distance',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.speed,
                value: _isRiding ? '18.2' : '22.4',
                unit: 'km/h',
                label: 'Avg Speed',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.local_fire_department,
                value: _isRiding ? '320' : '650',
                unit: 'cal',
                label: 'Calories',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String unit,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ChainlyTheme.surfaceColor,
        borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
        boxShadow: ChainlyTheme.cardShadow,
      ),
      child: Column(
        children: [
          Icon(icon, color: ChainlyTheme.primaryColor, size: 24),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ChainlyTheme.textPrimary,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    fontSize: 12,
                    color: ChainlyTheme.textSecondary,
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
              color: ChainlyTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ride History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ChainlyTheme.textPrimary,
              ),
            ),
            Text(
              'View All',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ChainlyTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildRideHistoryItem(
          date: 'Jan 8, 2026',
          duration: '1h 15m',
          distance: '25.8 km',
          avgSpeed: '22.4 km/h',
        ),
        const SizedBox(height: 10),
        _buildRideHistoryItem(
          date: 'Jan 6, 2026',
          duration: '45m',
          distance: '15.2 km',
          avgSpeed: '20.1 km/h',
        ),
        const SizedBox(height: 10),
        _buildRideHistoryItem(
          date: 'Jan 4, 2026',
          duration: '2h 30m',
          distance: '52.3 km',
          avgSpeed: '24.8 km/h',
        ),
      ],
    );
  }

  Widget _buildRideHistoryItem({
    required String date,
    required String duration,
    required String distance,
    required String avgSpeed,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ChainlyTheme.surfaceColor,
        borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
        boxShadow: ChainlyTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ChainlyTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ChainlyTheme.radiusSmall),
            ),
            child: Icon(
              Icons.directions_bike,
              color: ChainlyTheme.primaryColor,
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
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ChainlyTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$distance • $duration',
                  style: TextStyle(
                    fontSize: 13,
                    color: ChainlyTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                avgSpeed,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ChainlyTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'avg',
                style: TextStyle(
                  fontSize: 11,
                  color: ChainlyTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            color: ChainlyTheme.textSecondary,
          ),
        ],
      ),
    );
  }
}
