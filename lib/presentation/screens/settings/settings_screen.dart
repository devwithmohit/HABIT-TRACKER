import 'package:flutter/material.dart';

/// Settings screen
/// Note: Full implementation requires:
/// - Riverpod provider integration
/// - Theme switcher
/// - Notification settings
/// - Premium upgrade flow
/// - Data export
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Appearance section
          _buildSectionHeader(context, 'Appearance'),
          _buildListTile(
            context,
            icon: Icons.palette,
            title: 'Theme',
            subtitle: 'Light',
            onTap: () {
              // Show theme picker
            },
          ),

          const Divider(),

          // Notifications section
          _buildSectionHeader(context, 'Notifications'),
          _buildSwitchTile(
            context,
            icon: Icons.notifications,
            title: 'Enable Notifications',
            value: true,
            onChanged: (value) {
              // Toggle notifications
            },
          ),
          _buildListTile(
            context,
            icon: Icons.access_time,
            title: 'Reminder Time',
            subtitle: '20:00',
            onTap: () {
              // Show time picker
            },
          ),
          _buildSwitchTile(
            context,
            icon: Icons.weekend,
            title: 'Skip Weekends',
            value: false,
            onChanged: (value) {
              // Toggle skip weekends
            },
          ),

          const Divider(),

          // Data section
          _buildSectionHeader(context, 'Data'),
          _buildListTile(
            context,
            icon: Icons.download,
            title: 'Export Data',
            subtitle: 'CSV or PDF',
            trailing: const Chip(
              label: Text('Premium', style: TextStyle(fontSize: 10)),
              padding: EdgeInsets.symmetric(horizontal: 8),
            ),
            onTap: () {
              // Export data (premium feature)
            },
          ),
          _buildListTile(
            context,
            icon: Icons.delete_forever,
            title: 'Clear All Data',
            subtitle: 'Cannot be undone',
            onTap: () {
              // Show confirmation dialog
            },
          ),

          const Divider(),

          // Premium section
          _buildSectionHeader(context, 'Premium'),
          Container(
            margin: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {
                // Show premium upgrade screen
              },
              icon: const Icon(Icons.star),
              label: const Text('Upgrade to Premium'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),

          // About section
          const Divider(),
          _buildSectionHeader(context, 'About'),
          _buildListTile(
            context,
            icon: Icons.info,
            title: 'Version',
            subtitle: '1.0.0',
            onTap: null,
          ),
          _buildListTile(
            context,
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            onTap: () {
              // Open privacy policy
            },
          ),
          _buildListTile(
            context,
            icon: Icons.description,
            title: 'Terms of Service',
            onTap: () {
              // Open terms
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
}
