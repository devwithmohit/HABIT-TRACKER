import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/di/injection.dart';
import '../../../core/constants/app_constants.dart';

/// Settings screen
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    final settings = settingsState.settings;
    final isPremium = settings.isPremium;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          if (isPremium)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: const Text('Premium', style: TextStyle(fontSize: 12)),
                backgroundColor: Colors.amber,
                avatar: const Icon(Icons.star, size: 16),
              ),
            ),
        ],
      ),
      body: ListView(
        children: [
          // Appearance section
          _buildSectionHeader(context, 'Appearance'),
          _buildListTile(
            context,
            icon: Icons.palette,
            title: 'Theme',
            subtitle: _getThemeLabel(settings.themeMode),
            onTap: () => _showThemePicker(context, ref, settings.themeMode),
          ),

          const Divider(),

          // Notifications section
          _buildSectionHeader(context, 'Notifications'),
          _buildSwitchTile(
            context,
            icon: Icons.notifications,
            title: 'Enable Notifications',
            value: settings.notificationsEnabled,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleNotifications(value);
            },
          ),
          _buildListTile(
            context,
            icon: Icons.access_time,
            title: 'Reminder Time',
            subtitle: settings.notificationTime,
            onTap: () => _showTimePicker(context, ref, settings.notificationTime),
          ),
          _buildSwitchTile(
            context,
            icon: Icons.weekend,
            title: 'Skip Weekends',
            value: settings.skipWeekends,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleSkipWeekends(value);
            },
          ),

          const Divider(),

          // Data section
          _buildSectionHeader(context, 'Data'),
          _buildListTile(
            context,
            icon: Icons.download,
            title: 'Export Data',
            subtitle: isPremium ? 'CSV or PDF' : 'Premium feature',
            trailing: isPremium
                ? const Icon(Icons.chevron_right)
                : const Icon(Icons.lock, size: 20),
            onTap: () => _handleExportData(context, ref, isPremium),
          ),
          _buildListTile(
            context,
            icon: Icons.delete_forever,
            title: 'Clear All Data',
            subtitle: 'Delete all habits and logs',
            onTap: () => _showClearDataDialog(context, ref),
          ),

          const Divider(),

          // Premium section
          if (!isPremium) ...[
            _buildSectionHeader(context, 'Premium'),
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.shade400,
                    Colors.amber.shade700,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.star, color: Colors.white, size: 32),
                      SizedBox(width: 12),
                      Text(
                        'Go Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Unlock all premium features:',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  _buildPremiumFeature('🎯 Unlimited habits'),
                  _buildPremiumFeature('🚫 Remove all ads'),
                  _buildPremiumFeature('📊 Export data to CSV/PDF'),
                  _buildPremiumFeature('⭐ Priority support'),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showPremiumUpgrade(context, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.amber.shade700,
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Text(
                        'Upgrade Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Language section
          const Divider(),
          _buildSectionHeader(context, 'Language'),
          _buildListTile(
            context,
            icon: Icons.language,
            title: 'App Language',
            subtitle: _getLanguageName(settings.language),
            onTap: () => _showLanguageSelector(context, ref, settings.language),
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
            icon: Icons.bug_report,
            title: 'Debug Info',
            subtitle: 'View app status',
            onTap: () => _showDebugInfo(context, ref, settings),
          ),
          _buildListTile(
            context,
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            onTap: () => _openUrl(AppConstants.privacyPolicyUrl),
          ),
          _buildListTile(
            context,
            icon: Icons.description,
            title: 'Terms of Service',
            onTap: () => _openUrl(AppConstants.termsOfServiceUrl),
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

  Widget _buildPremiumFeature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _handleExportData(BuildContext context, WidgetRef ref, bool isPremium) {
    if (!isPremium) {
      _showPremiumRequired(context, ref);
      return;
    }

    // Show export options
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('Choose export format:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportData(context, ref, 'csv');
            },
            child: const Text('CSV'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportData(context, ref, 'pdf');
            },
            child: const Text('PDF'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _exportData(BuildContext context, WidgetRef ref, String format) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Exporting data as ${format.toUpperCase()}...'),
            const SizedBox(height: 8),
            const Text(
              'Please wait while we prepare your file',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    // Run real export
    String? filePath;
    try {
      final exportService = ref.read(exportServiceProvider);
      if (format == 'csv') {
        filePath = await exportService.exportToCsv();
      } else {
        filePath = await exportService.exportReport();
      }
    } catch (e) {
      filePath = null;
    }

    if (context.mounted) {
      Navigator.pop(context); // Close loading dialog

      if (filePath != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600),
                const SizedBox(width: 8),
                const Text('Export Complete!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your data has been exported as ${format.toUpperCase()}.'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'File Location:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        filePath,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Export failed. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showPremiumRequired(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock, color: Colors.amber),
            SizedBox(width: 8),
            Text('Premium Feature'),
          ],
        ),
        content: const Text(
          'This feature is only available for Premium users. Upgrade now to unlock all premium features!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showPremiumUpgrade(context, ref);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
            ),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  void _showPremiumUpgrade(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade to Premium'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Get lifetime access to all premium features:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPremiumFeature('🎯 Unlimited habits'),
            _buildPremiumFeature('🚫 Remove all ads'),
            _buildPremiumFeature('📊 Export data to CSV/PDF'),
            _buildPremiumFeature('⭐ Priority support'),
            const SizedBox(height: 16),
            const Text(
              'One-time payment: ₹149',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processPremiumPurchase(context, ref);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
            ),
            child: const Text('Purchase Now'),
          ),
        ],
      ),
    );
  }

  void _processPremiumPurchase(BuildContext context, WidgetRef ref) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Processing purchase...'),
                SizedBox(height: 8),
                Text(
                  'This will only take a moment',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Use real PurchaseService when available (non-web platforms)
      if (!kIsWeb) {
        final purchaseService = ref.read(purchaseServiceProvider);
        if (purchaseService.isAvailable) {
          // Wire the callback to handle purchase result
          purchaseService.onPurchaseUpdate = (isPremium) async {
            if (isPremium) {
              await ref.read(settingsProvider.notifier).activatePremium();
              // Dispose banner ad since user is now premium
              ref.read(adServiceProvider).disposeBanner();
            }
          };
          await purchaseService.purchasePremium();
          if (context.mounted) Navigator.pop(context); // Close loading
          return;
        }
      }

      // Fallback: direct activation (for web or when IAP not available)
      await ref.read(settingsProvider.notifier).activatePremium();
      await Future.delayed(const Duration(milliseconds: 300));

      if (context.mounted) {
        Navigator.pop(context); // Close loading

        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                SizedBox(width: 8),
                Text('Welcome to Premium!'),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thank you for your purchase!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text('✓ Unlimited habits unlocked'),
                Text('✓ Ads removed'),
                Text('✓ Data export unlocked'),
                Text('✓ Priority support enabled'),
                SizedBox(height: 12),
                Text(
                  'All premium features are now active!',
                  style: TextStyle(color: Colors.green),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.star, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Premium activated successfully!'),
                          ],
                        ),
                        backgroundColor: Colors.amber,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Start Using Premium',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text('Purchase Failed'),
              ],
            ),
            content: Text('Failed to activate premium: $e\n\nPlease try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _processPremiumPurchase(context, ref);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }
    }
  }

  String _getThemeLabel(String themeMode) {
    switch (themeMode) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      case 'amoled':
        return 'AMOLED Dark';
      case 'system':
        return 'System';
      default:
        return 'System';
    }
  }

  void _showThemePicker(BuildContext context, WidgetRef ref, String currentTheme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Light'),
              value: 'light',
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Dark'),
              value: 'dark',
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('AMOLED Dark'),
              value: 'amoled',
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('System'),
              value: 'system',
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTimePicker(BuildContext context, WidgetRef ref, String currentTime) async {
    // Parse current time
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 20,
      minute: int.tryParse(parts[1]) ?? 0,
    );

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      final formattedTime = '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
      ref.read(settingsProvider.notifier).updateNotificationTime(formattedTime);
    }
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Clear All Data?'),
          ],
        ),
        content: const Text(
          'This will permanently delete:\n\n'
          '• All habits\n'
          '• All progress logs\n'
          '• All settings (except premium status)\n\n'
          'This action CANNOT be undone!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearAllData(context, ref);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear Everything'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllData(BuildContext context, WidgetRef ref) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Clearing all data...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Get the database instance
      final database = ref.read(hiveDatabaseProvider);

      // Clear all data
      await database.clearAllData();

      // Reload habits to refresh the UI
      await ref.read(habitsProvider.notifier).loadHabits();

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data has been cleared successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear data: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showDebugInfo(BuildContext context, WidgetRef ref, settings) {
    final habitsState = ref.read(habitsProvider);
    final isPremium = settings.isPremium;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.bug_report),
            const SizedBox(width: 8),
            const Text('Debug Information'),
            const Spacer(),
            if (isPremium)
              const Chip(
                label: Text('PRO', style: TextStyle(fontSize: 10)),
                backgroundColor: Colors.amber,
                padding: EdgeInsets.symmetric(horizontal: 8),
              ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isPremium ? Colors.green.shade50 : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isPremium ? Colors.green.shade200 : Colors.orange.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPremium ? Icons.check_circle : Icons.lock,
                      color: isPremium ? Colors.green : Colors.orange,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isPremium ? 'Premium Active' : 'Free Version',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isPremium ? Colors.green.shade700 : Colors.orange.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isPremium
                              ? 'All features unlocked'
                              : 'Upgrade to unlock premium features',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'App Status:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _buildDebugRow('Premium Status', isPremium ? '✓ Active' : '✗ Not Active'),
              _buildDebugRow('Theme Mode', settings.themeMode.toUpperCase()),
              _buildDebugRow('Notifications', settings.notificationsEnabled ? 'Enabled' : 'Disabled'),
              _buildDebugRow('Reminder Time', settings.notificationTime),
              _buildDebugRow('Skip Weekends', settings.skipWeekends ? 'Yes' : 'No'),
              _buildDebugRow('Total Habits', '${habitsState.habits.length}'),
              _buildDebugRow('App Version', '1.0.0'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Testing Notes:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isPremium
                          ? '• Export Data should show → arrow\n'
                            '• Premium section should be hidden\n'
                            '• Premium badge should appear in app bar\n'
                            '• All premium features unlocked'
                          : '• Export Data shows 🔒 lock icon\n'
                            '• Premium section is visible\n'
                            '• Tap "Activate Premium" to upgrade',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (!isPremium)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showPremiumUpgrade(context, ref);
              },
              icon: const Icon(Icons.star, size: 16),
              label: const Text('Activate Premium'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'hi':
        return 'हिंदी (Hindi)';
      case 'es':
        return 'Español (Spanish)';
      case 'fr':
        return 'Français (French)';
      case 'de':
        return 'Deutsch (German)';
      case 'ja':
        return '日本語 (Japanese)';
      default:
        return code;
    }
  }

  void _showLanguageSelector(
      BuildContext context, WidgetRef ref, String current) {
    final languages = ['en', 'hi', 'es', 'fr', 'de', 'ja'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((code) {
            return RadioListTile<String>(
              title: Text(_getLanguageName(code)),
              value: code,
              groupValue: current,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateLanguage(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
