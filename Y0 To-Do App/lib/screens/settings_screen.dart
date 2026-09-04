// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

// ignore_for_file: use_build_context_synchronously, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../l10n/l10n_extension.dart';
import '../providers/settings_provider.dart';
import '../providers/task_provider.dart';
import '../providers/ai_provider.dart';
import '../services/backup_service.dart';
import '../widgets/settings_section.dart';
import '../widgets/theme_mode_selector.dart';
import '../widgets/voice_settings_panel.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/settings/language_selector.dart';
import '../widgets/settings/notification_time_selector.dart';
import '../widgets/settings/name_edit_dialog.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Appearance Section
                Card(
                  child: Column(
                    children: [
                      SettingsSection(
                        title: context.l10n.appearanceSection,
                        icon: Icons.palette,
                      ),
                      ListTile(
                        leading: Icon(
                          _getThemeModeIcon(settings.themeMode),
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(context.l10n.themeModeLabel),
                        subtitle: Text(_getThemeModeText(context, settings.themeMode)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showThemeModeSelector(context),
                      ),
                    ],
                  ),
                ).animate().slideX(begin: -0.1, duration: 300.ms).fadeIn(),
                
                const SizedBox(height: 16),
                
                // Language Section
                Card(
                  child: Column(
                    children: [
                      SettingsSection(
                        title: context.l10n.languageSection,
                        icon: Icons.language,
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.translate,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(context.l10n.languageLabel),
                        subtitle: Text(settings.language == 'ar' ? context.l10n.languageArabic : context.l10n.languageEnglish),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showLanguageSelector(context),
                      ),
                    ],
                  ),
                ).animate().slideX(begin: 0.1, duration: 300.ms).fadeIn(),
                
                const SizedBox(height: 16),
                
                // Notifications Section
                Card(
                  child: Column(
                    children: [
                      SettingsSection(
                        title: context.l10n.notificationsSection,
                        icon: Icons.notifications,
                      ),
                      SwitchListTile(
                        secondary: Icon(
                          settings.notificationsEnabled 
                              ? Icons.notifications_active 
                              : Icons.notifications_off,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(context.l10n.enableNotifications),
                        subtitle: Text(context.l10n.enableNotificationsSubtitle),
                        value: settings.notificationsEnabled,
                        onChanged: (value) async {
                          HapticFeedback.lightImpact();
                          
                          await ref.read(settingsProvider.notifier).toggleNotifications(value);
                          
                          if (value) {
                            await ref.read(tasksProvider.notifier).rescheduleAllNotifications();
                            _showSnackBar(context, context.l10n.notificationsEnabledSnackBar);
                          } else {
                            final notificationService = ref.read(notificationServiceProvider);
                            await notificationService.cancelAllNotifications();
                            _showSnackBar(context, context.l10n.notificationsDisabledSnackBar);
                          }
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.schedule,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(context.l10n.reminderTimeLabel),
                        subtitle: Text(context.l10n.reminderTimeSubtitle(_getNotificationTimeText(context, settings.notificationMinutesBefore))),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showNotificationTimeSelector(context),
                      ),
                      SwitchListTile(
                        secondary: Icon(
                          settings.exactTimeNotificationsEnabled 
                              ? Icons.access_time 
                              : Icons.access_time_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(context.l10n.exactTimeNotifications),
                        subtitle: Text(context.l10n.exactTimeNotificationsSubtitle),
                        value: settings.exactTimeNotificationsEnabled,
                        onChanged: (value) async {
                          HapticFeedback.lightImpact();
                          
                          await ref.read(settingsProvider.notifier).toggleExactTimeNotifications(value);
                          
                          if (value) {
                            await ref.read(tasksProvider.notifier).rescheduleAllNotifications();
                            _showSnackBar(context, context.l10n.exactTimeNotificationsEnabledSnackBar);
                          } else {
                            await ref.read(tasksProvider.notifier).rescheduleAllNotifications();
                            _showSnackBar(context, context.l10n.exactTimeNotificationsDisabledSnackBar);
                          }
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.notifications_active_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(context.l10n.testNotification),
                        subtitle: Text(context.l10n.testNotificationSubtitle),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          final notificationService = ref.read(notificationServiceProvider);
                          await notificationService.showInstantNotification(
                            context.l10n.testNotificationTitle,
                            context.l10n.testNotificationBody,
                          );
                          _showSnackBar(context, context.l10n.testNotificationSent);
                        },
                      ),
                    ],
                  ),
                ).animate().slideX(begin: -0.1, duration: 300.ms).fadeIn(),
                
                const SizedBox(height: 16),
                
                // Voice Settings Section
                VoiceSettingsPanel(
                  settings: settings,
                  onSpeechRateChanged: (value) {
                    HapticFeedback.lightImpact();
                    ref.read(settingsProvider.notifier).updateSpeechRate(value);
                  },
                  onSpeechVolumeChanged: (value) {
                    HapticFeedback.lightImpact();
                    ref.read(settingsProvider.notifier).updateSpeechVolume(value);
                  },
                  onSpeechPitchChanged: (value) {
                    HapticFeedback.lightImpact();
                    ref.read(settingsProvider.notifier).updateSpeechPitch(value);
                  },
                  onSoundToggle: (value) {
                    HapticFeedback.lightImpact();
                    ref.read(settingsProvider.notifier).toggleSound(value);
                    _showSnackBar(context, context.l10n.soundSettingsUpdated);
                  },
                ).animate().slideX(begin: 0.1, duration: 300.ms).fadeIn(),
                
                const SizedBox(height: 16),
                
                // Profile Section
                Card(
                  child: Column(
                    children: [
                      SettingsSection(
                        title: context.l10n.profileSection,
                        icon: Icons.person,
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.person_outline,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(context.l10n.userNameLabel),
                        subtitle: Text(settings.userName),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showNameEditDialog(context),
                      ),
                    ],
                  ),
                ).animate().slideX(begin: -0.1, duration: 300.ms).fadeIn(),
                
                const SizedBox(height: 16),
                
                // Security Section — App Lock
                Card(
                  child: Column(
                    children: [
                      SettingsSection(
                        title: context.l10n.securitySection,
                        icon: Icons.security,
                      ),
                      SwitchListTile(
                        secondary: Icon(
                          settings.appLockEnabled
                              ? Icons.lock
                              : Icons.lock_open,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(context.l10n.appLockLabel),
                        subtitle: Text(context.l10n.appLockSubtitle),
                        value: settings.appLockEnabled,
                        onChanged: (value) async {
                          HapticFeedback.lightImpact();
                          await ref
                              .read(settingsProvider.notifier)
                              .toggleAppLock(value);
                          _showSnackBar(
                            context,
                            value
                                ? context.l10n.appLockEnabledSnackBar
                                : context.l10n.appLockDisabledSnackBar,
                          );
                        },
                      ),
                    ],
                  ),
                ).animate().slideX(begin: 0.1, duration: 300.ms).fadeIn(),
                
                const SizedBox(height: 16),
                
                Card(
                  child: Column(
                    children: [
                      SettingsSection(
                        title: context.l10n.aboutSection,
                        icon: Icons.info,
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(context.l10n.aboutAppLabel),
                        subtitle: Text(context.l10n.aboutAppSubtitle),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showAppInfo(context),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.restore,
                          color: Colors.orange,
                        ),
                        title: Text(context.l10n.resetSettingsLabel),
                        subtitle: Text(context.l10n.resetSettingsSubtitle),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showResetConfirmation(context),
                      ),
                    ],
                  ),
                ).animate().slideX(begin: -0.1, duration: 300.ms).fadeIn(),
                
                const SizedBox(height: 16),
                
                // Backup Section
                Card(
                  child: Column(
                    children: [
                      SettingsSection(
                        title: context.l10n.backupSection,
                        icon: Icons.backup,
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.cloud_upload,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(context.l10n.createBackupLabel),
                        subtitle: Text(context.l10n.createBackupSubtitle),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _handleBackup(context),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.cloud_download,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(context.l10n.restoreBackupLabel),
                        subtitle: Text(context.l10n.restoreBackupSubtitle),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _handleRestore(context),
                      ),
                    ],
                  ),
                ).animate().slideX(begin: 0.1, duration: 300.ms).fadeIn(),
                
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
      
      // Bottom Navigation
      bottomNavigationBar: BottomNavigation(
        currentIndex: 2,
        onTap: (index) => _handleNavigationTap(context, index),
      ),
    );
  }

  void _handleNavigationTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/statistics');
        break;
      case 2:
        break;
    }
  }

  IconData _getThemeModeIcon(String themeMode) {
    switch (themeMode) {
      case 'light':
        return Icons.light_mode;
      case 'dark':
        return Icons.dark_mode;
      case 'system':
      default:
        return Icons.brightness_auto;
    }
  }

  String _getThemeModeText(BuildContext context, String themeMode) {
    switch (themeMode) {
      case 'light':
        return context.l10n.themeLight;
      case 'dark':
        return context.l10n.themeDark;
      case 'system':
      default:
        return context.l10n.themeSystem;
    }
  }

  void _showThemeModeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ThemeModeSelector(
        currentThemeMode: ref.read(settingsProvider).themeMode,
        onThemeModeChanged: (mode) {
          ref.read(settingsProvider.notifier).updateThemeMode(mode);
          Navigator.pop(context);
          _showSnackBar(context, context.l10n.themeChanged);
        },
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const LanguageSelector(),
    );
  }

  void _showAppInfo(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!context.mounted) return;
    
    showAboutDialog(
      context: context,
      applicationName: context.l10n.appTitle,
      applicationVersion: packageInfo.version.isEmpty ? '3.4.0' : packageInfo.version,
      applicationIcon: const Icon(Icons.task_alt, size: 48),
      children: [
        Text(context.l10n.aboutAppDescription),
      ],
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.resetConfirmTitle),
        content: Text(context.l10n.resetConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).resetToDefaults();
              Navigator.pop(context);
              _showSnackBar(context, context.l10n.settingsResetSnackBar);
            },
            child: Text(context.l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _handleBackup(BuildContext context) async {
    try {
      final backupService = BackupService();
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      await backupService.exportAndShareBackup();
      
      if (context.mounted) {
        Navigator.pop(context);
        _showSnackBar(context, context.l10n.backupSuccessSnackBar);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        _showSnackBar(context, context.l10n.backupFailedSnackBar(e.toString()));
      }
    }
  }

  void _handleRestore(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.restoreConfirmTitle),
        content: Text(context.l10n.restoreConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              _showSnackBar(context, context.l10n.restoreFeatureComingSoon);
            },
            child: Text(context.l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _showNameEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const NameEditDialog(),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  String _getNotificationTimeText(BuildContext context, int minutes) {
    if (minutes < 60) {
      return context.l10n.minutesFormat(minutes);
    } else if (minutes == 60) {
      return context.l10n.oneHour;
    } else if (minutes < 1440) {
      return context.l10n.hoursFormat(minutes ~/ 60);
    } else {
      return context.l10n.oneDay;
    }
  }

  void _showNotificationTimeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const NotificationTimeSelector(),
    );
  }
}
