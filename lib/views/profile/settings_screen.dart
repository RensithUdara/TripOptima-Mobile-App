import 'package:flutter/material.dart';
import 'package:trip_optima_mobile_app/providers/auth_provider.dart';
import 'package:trip_optima_mobile_app/providers/ui_provider.dart';
import 'package:trip_optima_mobile_app/utils/app_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<UIProvider>(
        builder: (context, uiProvider, _) {
          return ListView(
            children: [
              // Appearance section
              _buildSectionHeader('Appearance'),

              // Theme mode
              ListTile(
                title: const Text('Theme'),
                subtitle: Text(_getThemeModeText(uiProvider.themeMode)),
                leading: const Icon(Icons.brightness_6),
                onTap: () => _showThemePicker(context, uiProvider),
              ),

              // Use animations
              SwitchListTile(
                title: const Text('Use Animations'),
                subtitle: const Text('Enable or disable animations in the app'),
                value: uiProvider.useAnimations,
                secondary: const Icon(Icons.animation),
                onChanged: (value) async {
                  uiProvider.setUseAnimations(value);
                  await AppPreferences.setUseAnimations(value);
                },
              ),

              // Preferences section
              _buildSectionHeader('Preferences'),

              // Language
              ListTile(
                title: const Text('Language'),
                subtitle: Text(_getLanguageText(uiProvider.languageCode)),
                leading: const Icon(Icons.language),
                onTap: () => _showLanguagePicker(context, uiProvider),
              ),

              // Measurement units
              ListTile(
                title: const Text('Measurement Units'),
                subtitle: Text(uiProvider.measurementUnit == 'metric'
                    ? 'Metric (km, °C)'
                    : 'Imperial (mi, °F)'),
                leading: const Icon(Icons.straighten),
                onTap: () => _showUnitsPicker(context, uiProvider),
              ),

              // Account section
              _buildSectionHeader('Account'),

              // Change password
              ListTile(
                title: const Text('Change Password'),
                leading: const Icon(Icons.lock_outline),
                onTap: () {
                  // Navigate to change password screen
                  Navigator.pushNamed(context, '/change-password');
                },
              ),

              // Privacy settings
              ListTile(
                title: const Text('Privacy Settings'),
                leading: const Icon(Icons.privacy_tip_outlined),
                onTap: () {
                  // Navigate to privacy settings
                  Navigator.pushNamed(context, '/privacy-settings');
                },
              ),

              // Data section
              _buildSectionHeader('Data'),

              // Clear cache
              ListTile(
                title: const Text('Clear Cache'),
                subtitle: const Text('Free up storage space'),
                leading: const Icon(Icons.cleaning_services_outlined),
                onTap: () => _showClearCacheDialog(context),
              ),

              // Export data
              ListTile(
                title: const Text('Export Data'),
                subtitle: const Text('Export your trips to JSON'),
                leading: const Icon(Icons.ios_share),
                onTap: () {
                  // Handle export data
                },
              ),

              // About section
              _buildSectionHeader('About'),

              // About app
              ListTile(
                title: const Text('About TripOptima'),
                leading: const Icon(Icons.info_outline),
                onTap: () {
                  // Navigate to about screen
                  Navigator.pushNamed(context, '/about');
                },
              ),

              // Help & Support
              ListTile(
                title: const Text('Help & Support'),
                leading: const Icon(Icons.help_outline),
                onTap: () {
                  // Navigate to help & support
                  Navigator.pushNamed(context, '/help-support');
                },
              ),

              // Log out
              ListTile(
                title: const Text(
                  'Log Out',
                  style: TextStyle(color: Colors.red),
                ),
                leading: const Icon(
                  Icons.exit_to_app,
                  color: Colors.red,
                ),
                onTap: () => _showLogoutDialog(context),
              ),

              // App version
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Version 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  String _getThemeModeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      default:
        return 'System Default';
    }
  }

  String _getLanguageText(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español (Spanish)';
      case 'fr':
        return 'Français (French)';
      case 'de':
        return 'Deutsch (German)';
      case 'zh':
        return '中文 (Chinese)';
      case 'ja':
        return '日本語 (Japanese)';
      case 'ko':
        return '한국어 (Korean)';
      default:
        return 'English';
    }
  }

  Future<void> _showThemePicker(
      BuildContext context, UIProvider uiProvider) async {
    final result = await showDialog<ThemeMode>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Choose Theme'),
          children: [
            _buildThemeOption(
              context: context,
              title: 'System Default',
              subtitle: 'Follow system settings',
              themeMode: ThemeMode.system,
              selectedThemeMode: uiProvider.themeMode,
            ),
            _buildThemeOption(
              context: context,
              title: 'Light',
              subtitle: 'Light theme',
              themeMode: ThemeMode.light,
              selectedThemeMode: uiProvider.themeMode,
            ),
            _buildThemeOption(
              context: context,
              title: 'Dark',
              subtitle: 'Dark theme',
              themeMode: ThemeMode.dark,
              selectedThemeMode: uiProvider.themeMode,
            ),
          ],
        );
      },
    );

    if (result != null) {
      uiProvider.setThemeMode(result);
      await AppPreferences.setThemeMode(result);
    }
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required ThemeMode themeMode,
    required ThemeMode selectedThemeMode,
  }) {
    return SimpleDialogOption(
      onPressed: () {
        Navigator.pop(context, themeMode);
      },
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: themeMode == selectedThemeMode
            ? Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              )
            : null,
      ),
    );
  }

  Future<void> _showLanguagePicker(
      BuildContext context, UIProvider uiProvider) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Choose Language'),
          children: [
            _buildLanguageOption(
              context: context,
              title: 'English',
              languageCode: 'en',
              selectedLanguageCode: uiProvider.languageCode,
            ),
            _buildLanguageOption(
              context: context,
              title: 'Español (Spanish)',
              languageCode: 'es',
              selectedLanguageCode: uiProvider.languageCode,
            ),
            _buildLanguageOption(
              context: context,
              title: 'Français (French)',
              languageCode: 'fr',
              selectedLanguageCode: uiProvider.languageCode,
            ),
            _buildLanguageOption(
              context: context,
              title: 'Deutsch (German)',
              languageCode: 'de',
              selectedLanguageCode: uiProvider.languageCode,
            ),
          ],
        );
      },
    );

    if (result != null) {
      // TODO: Implement language change
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Language support will be available in a future update'),
        ),
      );
    }
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String title,
    required String languageCode,
    required String selectedLanguageCode,
  }) {
    return SimpleDialogOption(
      onPressed: () {
        Navigator.pop(context, languageCode);
      },
      child: ListTile(
        title: Text(title),
        trailing: languageCode == selectedLanguageCode
            ? Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              )
            : null,
      ),
    );
  }

  Future<void> _showUnitsPicker(
      BuildContext context, UIProvider uiProvider) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Choose Units'),
          children: [
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'metric');
              },
              child: ListTile(
                title: const Text('Metric'),
                subtitle: const Text('Kilometers (km), Celsius (°C)'),
                trailing: uiProvider.measurementUnit == 'metric'
                    ? Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'imperial');
              },
              child: ListTile(
                title: const Text('Imperial'),
                subtitle: const Text('Miles (mi), Fahrenheit (°F)'),
                trailing: uiProvider.measurementUnit == 'imperial'
                    ? Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
              ),
            ),
          ],
        );
      },
    );

    if (result != null) {
      await AppPreferences.setMeasurementUnit(result);
      // Update the UI provider
      uiProvider.setMeasurementUnit(result);
    }
  }

  Future<void> _showClearCacheDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear all cached data including maps, images, and weather data. This won\'t affect your trips or account information.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );

    if (result == true) {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Clearing cache...'),
          duration: Duration(seconds: 1),
        ),
      );

      // Simulate cache clearing
      await Future.delayed(const Duration(seconds: 1));

      // Show success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cache cleared successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (result == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();

      if (mounted) {
        // Navigate to login screen
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }
}
