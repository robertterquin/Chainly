import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../dashboard/dashboard_screen.dart';
import '../maintenance/maintenance_hub_screen.dart';
import '../ride/ride_screen.dart';
import '../profile/profile_screen.dart';

/// Main Navigation Shell with Bottom Navigation Bar
/// Contains 4 tabs: Home, Maintenance Hub, Ride, Profile
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final GlobalKey<MaintenanceHubScreenState> _maintenanceKey = GlobalKey<MaintenanceHubScreenState>();

  void _changeTab(int index, {bool scrollToMaintenance = false}) {
    setState(() {
      _currentIndex = index;
    });
    
    // If navigating to maintenance tab and should scroll to maintenance log
    if (index == 1 && scrollToMaintenance) {
      // Wait for the tab switch to complete, then scroll
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _maintenanceKey.currentState?.scrollToMaintenanceLog();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardScreen(onTabChange: _changeTab),
          MaintenanceHubScreen(key: _maintenanceKey),
          const RideScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: ChainlyTheme.surfaceColor,
            borderRadius: BorderRadius.circular(ChainlyTheme.radiusXLarge),
            boxShadow: [
              BoxShadow(
                color: ChainlyTheme.primaryColor.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(ChainlyTheme.radiusXLarge),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              height: 70,
              indicatorColor: ChainlyTheme.primaryColor.withValues(alpha: 0.12),
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.build_outlined),
                  selectedIcon: Icon(Icons.build),
                  label: 'Maintenance',
                ),
                NavigationDestination(
                  icon: Icon(Icons.directions_bike_outlined),
                  selectedIcon: Icon(Icons.directions_bike),
                  label: 'Ride',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
