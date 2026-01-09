import 'package:flutter/material.dart';
import '../../utils/theme.dart';

/// Profile Screen
/// Shows user info, bike info, settings access, and logout option
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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

              // Profile Card
              _buildProfileCard(),
              const SizedBox(height: 24),

              // My Bikes Section
              _buildBikesSection(),
              const SizedBox(height: 24),

              // Stats Overview
              _buildStatsOverview(),
              const SizedBox(height: 24),

              // Settings Section
              _buildSettingsSection(),
              const SizedBox(height: 24),

              // Logout Button
              _buildLogoutButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'Profile',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: ChainlyTheme.textPrimary,
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: ChainlyTheme.primaryGradient,
        borderRadius: BorderRadius.circular(ChainlyTheme.radiusLarge),
        boxShadow: ChainlyTheme.buttonShadow,
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Center(
              child: Text(
                'JD',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: ChainlyTheme.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'John Doe',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'john.doe@email.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Pro Cyclist 🚴',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(ChainlyTheme.radiusSmall),
            ),
            child: const Icon(
              Icons.edit_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBikesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Bikes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ChainlyTheme.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ChainlyTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.add, size: 16, color: ChainlyTheme.primaryColor),
                  const SizedBox(width: 4),
                  Text(
                    'Add Bike',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ChainlyTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildBikeCard(
          name: 'Canyon Aeroad CF',
          type: 'Road Bike',
          totalDistance: '2,450 km',
          isActive: true,
        ),
        const SizedBox(height: 10),
        _buildBikeCard(
          name: 'Trek Domane',
          type: 'Endurance Bike',
          totalDistance: '1,200 km',
          isActive: false,
        ),
      ],
    );
  }

  Widget _buildBikeCard({
    required String name,
    required String type,
    required String totalDistance,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ChainlyTheme.surfaceColor,
        borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
        boxShadow: ChainlyTheme.cardShadow,
        border: isActive
            ? Border.all(color: ChainlyTheme.primaryColor.withOpacity(0.3), width: 2)
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive
                  ? ChainlyTheme.primaryColor.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ChainlyTheme.radiusSmall),
            ),
            child: Icon(
              Icons.pedal_bike,
              color: isActive ? ChainlyTheme.primaryColor : ChainlyTheme.textSecondary,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ChainlyTheme.textPrimary,
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: ChainlyTheme.successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Active',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: ChainlyTheme.successColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$type • $totalDistance',
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

  Widget _buildStatsOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ChainlyTheme.surfaceColor,
        borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
        boxShadow: ChainlyTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Time Stats',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ChainlyTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.straighten,
                value: '3,650',
                unit: 'km',
                label: 'Total Distance',
              ),
              _buildStatDivider(),
              _buildStatItem(
                icon: Icons.timer_outlined,
                value: '186',
                unit: 'hrs',
                label: 'Ride Time',
              ),
              _buildStatDivider(),
              _buildStatItem(
                icon: Icons.directions_bike,
                value: '142',
                unit: '',
                label: 'Total Rides',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String unit,
    required String label,
  }) {
    return Column(
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
              if (unit.isNotEmpty)
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
            fontSize: 11,
            color: ChainlyTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 50,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ChainlyTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildSettingsItem(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Maintenance & ride reminders',
        ),
        _buildSettingsItem(
          icon: Icons.palette_outlined,
          title: 'Appearance',
          subtitle: 'Light / Dark / System',
        ),
        _buildSettingsItem(
          icon: Icons.straighten,
          title: 'Units',
          subtitle: 'Kilometers (km)',
        ),
        _buildSettingsItem(
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'FAQ, Tips & Guides',
        ),
        _buildSettingsItem(
          icon: Icons.info_outline,
          title: 'About Chainly',
          subtitle: 'Version 1.0.0',
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
              color: ChainlyTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ChainlyTheme.radiusSmall),
            ),
            child: Icon(icon, color: ChainlyTheme.primaryColor, size: 22),
          ),
          const SizedBox(width: 14),
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

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: ChainlyTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
        border: Border.all(
          color: ChainlyTheme.errorColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.logout,
            color: ChainlyTheme.errorColor,
          ),
          const SizedBox(width: 10),
          Text(
            'Log Out',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ChainlyTheme.errorColor,
            ),
          ),
        ],
      ),
    );
  }
}
