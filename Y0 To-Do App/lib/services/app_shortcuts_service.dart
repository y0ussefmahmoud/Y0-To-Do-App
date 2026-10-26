// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter/foundation.dart';
import 'package:quick_actions/quick_actions.dart';

/// خدمة اختصارات شاشة التطبيق (App Launcher Quick Actions)
///
/// تتيح للمستخدم الوصول السريع للوظائف الأساسية عند الضغط المطول على أيقونة التطبيق:
/// 1. إضافة مهمة جديدة (action_add_task)
/// 2. إدخال صوتي (action_voice)
/// 3. إحصائيات اليوم (action_stats)
class AppShortcutsService {
  static final AppShortcutsService _instance = AppShortcutsService._internal();
  factory AppShortcutsService() => _instance;
  AppShortcutsService._internal();

  final QuickActions _quickActions = const QuickActions();
  void Function(String shortcutType)? onShortcutReceived;

  /// تهيئة الاختصارات وتسجيل معالج الأحداث
  void initialize({void Function(String shortcutType)? handler}) {
    if (kIsWeb) return;
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    if (handler != null) {
      onShortcutReceived = handler;
    }

    try {
      _quickActions.initialize((shortcutType) {
        if (onShortcutReceived != null) {
          onShortcutReceived!(shortcutType);
        }
      });

      _quickActions.setShortcutItems(const <ShortcutItem>[
        ShortcutItem(
          type: 'action_add_task',
          localizedTitle: 'إضافة مهمة جديدة',
          icon: 'ic_launcher',
        ),
        ShortcutItem(
          type: 'action_voice',
          localizedTitle: 'إدخال صوتي',
          icon: 'ic_launcher',
        ),
        ShortcutItem(
          type: 'action_stats',
          localizedTitle: 'إحصائيات اليوم',
          icon: 'ic_launcher',
        ),
      ]);
    } catch (e) {
      debugPrint('AppShortcutsService error: $e');
    }
  }
}
