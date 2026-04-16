// ignore_for_file: use_build_context_synchronously, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../providers/settings_provider.dart';
import '../providers/task_provider.dart';
import '../providers/ai_provider.dart';
import '../widgets/settings_section.dart';
import '../widgets/theme_mode_selector.dart';
import '../widgets/voice_settings_panel.dart';
import '../widgets/bottom_navigation.dart';

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
                      const SettingsSection(
                        title: 'المظهر',
                        icon: Icons.palette,
                      ),
                      ListTile(
                        leading: Icon(
                          _getThemeModeIcon(settings.themeMode),
                          color: theme.colorScheme.primary,
                        ),
                        title: const Text('وضع الثيم'),
                        subtitle: Text(_getThemeModeText(settings.themeMode)),
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
                      const SettingsSection(
                        title: 'اللغة',
                        icon: Icons.language,
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.translate,
                          color: theme.colorScheme.primary,
                        ),
                        title: const Text('لغة التطبيق'),
                        subtitle: Text(settings.language == 'ar' ? 'العربية' : 'English'),
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
                      const SettingsSection(
                        title: 'الإشعارات',
                        icon: Icons.notifications,
                      ),
                      SwitchListTile(
                        secondary: Icon(
                          settings.notificationsEnabled 
                              ? Icons.notifications_active 
                              : Icons.notifications_off,
                          color: theme.colorScheme.primary,
                        ),
                        title: const Text('تفعيل الإشعارات'),
                        subtitle: const Text('استلام إشعارات للمهام والمواعيد'),
                        value: settings.notificationsEnabled,
                        onChanged: (value) async {
                          HapticFeedback.lightImpact();
                          
                          // تحديث الإعدادات
                          await ref.read(settingsProvider.notifier).toggleNotifications(value);
                          
                          // التعامل مع الإشعارات
                          if (value) {
                            // تفعيل الإشعارات: إعادة جدولة جميع الإشعارات
                            await ref.read(tasksProvider.notifier).rescheduleAllNotifications();
                            // ignore: use_build_context_synchronously
                            _showSnackBar(context, 'تم تفعيل الإشعارات وجدولة التذكيرات');
                          } else {
                            // تعطيل الإشعارات: إلغاء جميع الإشعارات
                            final notificationService = ref.read(notificationServiceProvider);
                            await notificationService.cancelAllNotifications();
                            // ignore: use_build_context_synchronously
                            _showSnackBar(context, 'تم تعطيل الإشعارات');
                          }
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.schedule,
                          color: theme.colorScheme.primary,
                        ),
                        title: const Text('وقت التذكير'),
                        subtitle: Text('قبل موعد المهمة بـ ${_getNotificationTimeText(settings.notificationMinutesBefore)}'),
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
                        title: const Text('إشعارات دقيقة الوقت'),
                        subtitle: const Text('إشعار إضافي يظهر في الوقت المحدد تماماً'),
                        value: settings.exactTimeNotificationsEnabled,
                        onChanged: (value) async {
                          HapticFeedback.lightImpact();
                          
                          // تحديث الإعدادات
                          await ref.read(settingsProvider.notifier).toggleExactTimeNotifications(value);
                          
                          // التعامل مع الإشعارات
                          if (value) {
                            // تفعيل الإشعارات الدقيقة: إعادة جدولة جميع الإشعارات
                            await ref.read(tasksProvider.notifier).rescheduleAllNotifications();
                            // ignore: use_build_context_synchronously
                            _showSnackBar(context, 'تم تفعيل الإشعارات الدقيقة');
                          } else {
                            // تعطيل الإشعارات الدقيقة: إلغاء الإشعارات الدقيقة فقط
                            await ref.read(tasksProvider.notifier).rescheduleAllNotifications();
                            // ignore: use_build_context_synchronously
                            _showSnackBar(context, 'تم تعطيل الإشعارات الدقيقة');
                          }
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.notifications_active_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        title: const Text('اختبار الإشعارات'),
                        subtitle: const Text('إرسال إشعار تجريبي'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          final notificationService = ref.read(notificationServiceProvider);
                          await notificationService.showInstantNotification('اختبار', 'هذا إشعار تجريبي');
                          // ignore: use_build_context_synchronously
                          _showSnackBar(context, 'تم إرسال الإشعار التجريبي');
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
                    _showSnackBar(context, 'تم تحديث إعدادات الصوت');
                  },
                ).animate().slideX(begin: 0.1, duration: 300.ms).fadeIn(),
                
                const SizedBox(height: 16),
                
                // Profile Section
                Card(
                  child: Column(
                    children: [
                      const SettingsSection(
                        title: 'الملف الشخصي',
                        icon: Icons.person,
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.person_outline,
                          color: theme.colorScheme.primary,
                        ),
                        title: const Text('اسم المستخدم'),
                        subtitle: Text(settings.userName),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showNameEditDialog(context),
                      ),
                    ],
                  ),
                ).animate().slideX(begin: -0.1, duration: 300.ms).fadeIn(),
                
                const SizedBox(height: 16),
                
                // About Section
                Card(
                  child: Column(
                    children: [
                      const SettingsSection(
                        title: 'حول التطبيق',
                        icon: Icons.info,
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.primary,
                        ),
                        title: const Text('معلومات التطبيق'),
                        subtitle: const Text('Y0 To-Do App v3.2.2'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showAppInfo(context),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.restore,
                          color: Colors.orange,
                        ),
                        title: const Text('إعادة تعيين الإعدادات'),
                        subtitle: const Text('استعادة جميع الإعدادات الافتراضية'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showResetConfirmation(context),
                      ),
                    ],
                  ),
                ).animate().slideX(begin: -0.1, duration: 300.ms).fadeIn(),
                
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
        // Home Screen
        Navigator.pushReplacementNamed(context, '/');
        break;
      case 1:
        // Statistics Screen
        Navigator.pushReplacementNamed(context, '/statistics');
        break;
      case 2:
        // Settings Screen (we're already here)
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

  String _getThemeModeText(String themeMode) {
    switch (themeMode) {
      case 'light':
        return 'الوضع الفاتح';
      case 'dark':
        return 'الوضع الداكن';
      case 'system':
      default:
        return 'تلقائي (حسب النظام)';
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
          _showSnackBar(context, 'تم تغيير وضع الثيم');
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
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'اختر اللغة',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('العربية'),
              subtitle: const Text('قريباً'),
              leading: Radio<String>(
                value: 'ar',
                // ignore: deprecated_member_use
                groupValue: ref.read(settingsProvider).language,
                // ignore: deprecated_member_use
                onChanged: (value) {
                  if (value != null) {
                    ref.read(settingsProvider.notifier).updateLanguage(value);
                    Navigator.pop(context);
                    _showSnackBar(context, 'قريباً: دعم اللغة العربية');
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('English'),
              subtitle: const Text('Coming soon'),
              leading: Radio<String>(
                value: 'en',
                // ignore: deprecated_member_use
                groupValue: ref.read(settingsProvider).language,
                // ignore: deprecated_member_use
                onChanged: (value) {
                  if (value != null) {
                    ref.read(settingsProvider.notifier).updateLanguage(value);
                    Navigator.pop(context);
                    _showSnackBar(context, 'Coming soon: English support');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAppInfo(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();
    
    showAboutDialog(
      context: context,
      applicationName: 'Y0 To-Do App',
      applicationVersion: packageInfo.version,
      applicationIcon: const Icon(Icons.task_alt, size: 48),
      children: [
        const Text('تطبيق مهام احترافي مع واجهة عربية كاملة ومميزات متقدمة.'),
      ],
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة تعيين الإعدادات'),
        content: const Text('هل أنت متأكد من إعادة تعيين جميع الإعدادات إلى القيم الافتراضية؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).resetToDefaults();
              Navigator.pop(context);
              _showSnackBar(context, 'تم إعادة تعيين جميع الإعدادات');
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _showNameEditDialog(BuildContext context) {
    final controller = TextEditingController(text: ref.read(settingsProvider).userName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل اسم المستخدم'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'الاسم',
            hintText: 'أدخل اسمك',
            border: OutlineInputBorder(),
          ),
          textDirection: TextDirection.rtl,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref.read(settingsProvider.notifier).updateUserName(name);
                Navigator.pop(context);
                _showSnackBar(context, 'تم تحديث اسم المستخدم');
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
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

  String _getNotificationTimeText(int minutes) {
    if (minutes < 60) {
      return '$minutes دقيقة';
    } else if (minutes == 60) {
      return 'ساعة واحدة';
    } else if (minutes < 1440) {
      final hours = minutes ~/ 60;
      return '$hours ساعات';
    } else {
      final days = minutes ~/ 1440;
      return '$days يوم';
    }
  }

  void _showNotificationTimeSelector(BuildContext context) {
    final currentTime = ref.read(settingsProvider).notificationMinutesBefore;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'اختر وقت التذكير',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            ...[
              {'minutes': 15, 'text': '15 دقيقة'},
              {'minutes': 30, 'text': '30 دقيقة'},
              {'minutes': 60, 'text': 'ساعة واحدة'},
              {'minutes': 120, 'text': 'ساعتين'},
              {'minutes': 1440, 'text': 'يوم واحد'},
            ].map((option) => ListTile(
              title: Text(option['text'] as String),
              leading: Radio<int>(
                value: option['minutes'] as int,
                // ignore: deprecated_member_use
                groupValue: currentTime,
                // ignore: deprecated_member_use
                onChanged: (value) {
                  if (value != null) {
                    ref.read(settingsProvider.notifier).updateNotificationMinutesBefore(value);
                    Navigator.pop(context);
                    _showSnackBar(context, 'تم تحديث وقت التذكير');
                  }
                },
              ),
            )),
          ],
        ),
      ),
    );
  }
}
