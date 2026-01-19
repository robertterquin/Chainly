import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/theme.dart';
import '../../services/notification_service.dart';

/// Notification Settings Screen
/// Allows users to configure notification preferences
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _maintenanceReminders = true;
  bool _overdueAlerts = true;
  bool _dailySummary = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _maintenanceReminders = prefs.getBool('maintenance_reminders') ?? true;
      _overdueAlerts = prefs.getBool('overdue_alerts') ?? true;
      _dailySummary = prefs.getBool('daily_summary') ?? false;
      _soundEnabled = prefs.getBool('notification_sound') ?? true;
      _vibrationEnabled = prefs.getBool('notification_vibration') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('maintenance_reminders', _maintenanceReminders);
    await prefs.setBool('overdue_alerts', _overdueAlerts);
    await prefs.setBool('daily_summary', _dailySummary);
    await prefs.setBool('notification_sound', _soundEnabled);
    await prefs.setBool('notification_vibration', _vibrationEnabled);

    // Update notification service
    await NotificationService().setNotificationsEnabled(_notificationsEnabled);
  }

  Future<void> _requestPermission() async {
    final granted = await NotificationService().requestPermission();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            granted 
              ? 'Notification permission granted' 
              : 'Notification permission denied. Please enable in device settings.',
          ),
          backgroundColor: granted ? ChainlyTheme.successColor : ChainlyTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _testNotification() async {
    await NotificationService().showNotification(
      title: 'Test Notification',
      body: 'Your notifications are working correctly!',
      id: 999999,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification sent!'),
          backgroundColor: ChainlyTheme.successColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Notification Settings',
          style: TextStyle(
            color: ChainlyTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Master toggle
                  _buildMasterToggle(),
                  const SizedBox(height: 24),
                  
                  // Notification types
                  _buildSectionTitle('Notification Types'),
                  const SizedBox(height: 12),
                  _buildNotificationTypes(),
                  const SizedBox(height: 24),
                  
                  // Sound & Vibration
                  _buildSectionTitle('Sound & Vibration'),
                  const SizedBox(height: 12),
                  _buildSoundSettings(),
                  const SizedBox(height: 24),
                  
                  // Actions
                  _buildSectionTitle('Actions'),
                  const SizedBox(height: 12),
                  _buildActions(),
                  const SizedBox(height: 32),
                  
                  // Info
                  _buildInfoCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildMasterToggle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ChainlyTheme.primaryColor,
            ChainlyTheme.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
        boxShadow: ChainlyTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Push Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _notificationsEnabled ? 'Enabled' : 'Disabled',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
              _saveSettings();
            },
            activeColor: Colors.white,
            activeTrackColor: Colors.white.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: ChainlyTheme.textPrimary,
      ),
    );
  }

  Widget _buildNotificationTypes() {
    return Container(
      decoration: BoxDecoration(
        color: ChainlyTheme.surfaceColor,
        borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
        boxShadow: ChainlyTheme.cardShadow,
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.build,
            title: 'Maintenance Reminders',
            subtitle: 'Get notified when maintenance is due',
            value: _maintenanceReminders,
            enabled: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _maintenanceReminders = value);
              _saveSettings();
            },
          ),
          const Divider(height: 1),
          _buildSwitchTile(
            icon: Icons.warning_amber,
            title: 'Overdue Alerts',
            subtitle: 'Alert when maintenance is overdue',
            value: _overdueAlerts,
            enabled: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _overdueAlerts = value);
              _saveSettings();
            },
          ),
          const Divider(height: 1),
          _buildSwitchTile(
            icon: Icons.summarize,
            title: 'Daily Summary',
            subtitle: 'Daily overview of upcoming tasks',
            value: _dailySummary,
            enabled: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _dailySummary = value);
              _saveSettings();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSoundSettings() {
    return Container(
      decoration: BoxDecoration(
        color: ChainlyTheme.surfaceColor,
        borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
        boxShadow: ChainlyTheme.cardShadow,
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.volume_up,
            title: 'Sound',
            subtitle: 'Play sound for notifications',
            value: _soundEnabled,
            enabled: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _soundEnabled = value);
              _saveSettings();
            },
          ),
          const Divider(height: 1),
          _buildSwitchTile(
            icon: Icons.vibration,
            title: 'Vibration',
            subtitle: 'Vibrate for notifications',
            value: _vibrationEnabled,
            enabled: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _vibrationEnabled = value);
              _saveSettings();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: ChainlyTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: enabled ? ChainlyTheme.primaryColor : Colors.grey,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: enabled ? ChainlyTheme.textPrimary : Colors.grey,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: enabled ? ChainlyTheme.textSecondary : Colors.grey,
        ),
      ),
      trailing: Switch(
        value: value && enabled,
        onChanged: enabled ? onChanged : null,
        activeColor: ChainlyTheme.primaryColor,
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      decoration: BoxDecoration(
        color: ChainlyTheme.surfaceColor,
        borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
        boxShadow: ChainlyTheme.cardShadow,
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ChainlyTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.security,
                color: ChainlyTheme.warningColor,
                size: 24,
              ),
            ),
            title: const Text(
              'Request Permission',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Grant notification permission',
              style: TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _requestPermission,
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ChainlyTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.send,
                color: ChainlyTheme.successColor,
                size: 24,
              ),
            ),
            title: const Text(
              'Send Test Notification',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Check if notifications work',
              style: TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _notificationsEnabled ? _testNotification : null,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ChainlyTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ChainlyTheme.radiusMedium),
        border: Border.all(
          color: ChainlyTheme.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: ChainlyTheme.primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Push notifications will remind you about upcoming and overdue maintenance tasks even when the app is closed.',
              style: TextStyle(
                fontSize: 13,
                color: ChainlyTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
