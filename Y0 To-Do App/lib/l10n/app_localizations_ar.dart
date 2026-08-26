// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Y0 To-Do';

  @override
  String get appInitializing => 'جاري تهيئة التطبيق...';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navStatistics => 'الإحصائيات';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String homeGreeting(String name) {
    return 'أهلاً بك، $name!';
  }

  @override
  String get morningGreeting => 'صباح الخير، حان وقت بداية يوم إيجابي ومثمر.';

  @override
  String get afternoonGreeting => 'مساء الخير، حان وقت إنجاز باقي مهامك.';

  @override
  String get eveningGreeting => 'مساء الخير، حان وقت مراجعة إنجازات يومك.';

  @override
  String dailyProgress(int percent) {
    return 'إنجازك لليوم: $percent%';
  }

  @override
  String get progressNearEnd => 'أنت قريب جداً من إنهاء خطتك اليومية!';

  @override
  String get progressGood => 'أنت تسير بخطى جيدة، استمر!';

  @override
  String get progressStart => 'لنبدأ اليوم بإنجاز مهامك!';

  @override
  String completedOutOfTotal(int completed, int total) {
    return '$completed من $total مهمة';
  }

  @override
  String get searchHint => 'ابحث عن مهمة...';

  @override
  String get searchHistoryTitle => 'تاريخ البحث';

  @override
  String get clearAllHistory => 'مسح الكل';

  @override
  String get clearAllConfirm => 'هل أنت متأكد من مسح تاريخ البحث بالكامل؟';

  @override
  String get noSearchHistoryTitle => 'لا يوجد تاريخ بحث';

  @override
  String get noSearchHistorySubtitle =>
      'ابدأ بالبحث عن مهام وسيظهر هنا تاريخ البحث';

  @override
  String get searchCleared => 'تم مسح تاريخ البحث';

  @override
  String get quickTagHighPriority => 'أولوية عالية';

  @override
  String get quickTagTodayTasks => 'مهام اليوم';

  @override
  String get quickTagOverdue => 'متأخرة';

  @override
  String get quickTagWork => 'العمل';

  @override
  String get quickTagStudy => 'الدراسة';

  @override
  String get tasksSectionTitle => 'المهام';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get noTasksTitle => 'لا توجد مهام حالياً';

  @override
  String get noTasksSubtitle =>
      'إما أنك أنهيت كل المهام أو لا توجد نتائج مطابقة';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterPending => 'معلقة';

  @override
  String get filterCompleted => 'مكتملة';

  @override
  String get filterArchive => 'الأرشيف';

  @override
  String get filterToday => 'اليوم';

  @override
  String get filterThisWeek => 'هذا الأسبوع';

  @override
  String get filterOverdue => 'متأخرة';

  @override
  String get priorityHigh => 'عالية';

  @override
  String get priorityMedium => 'متوسطة';

  @override
  String get priorityLow => 'منخفضة';

  @override
  String get categoryWork => 'عمل';

  @override
  String get categoryPersonal => 'شخصي';

  @override
  String get categoryStudy => 'دراسة';

  @override
  String get categoryHealth => 'صحة';

  @override
  String get categoryGeneral => 'عام';

  @override
  String get categoryShopping => 'تسوق';

  @override
  String get categoryEntertainment => 'ترفيه';

  @override
  String get taskDoneSnackBar => 'تم إنجاز المهمة';

  @override
  String get taskUndoneSnackBar => 'تم إلغاء إنجاز المهمة';

  @override
  String get taskDeleteConfirmTitle => 'تأكيد الحذف';

  @override
  String taskDeleteConfirmMessage(String title) {
    return 'هل أنت متأكد من حذف \"$title\"؟';
  }

  @override
  String get taskDeletedSnackBar => 'تم حذف المهمة بنجاح';

  @override
  String get addTaskTitle => 'إضافة مهمة جديدة';

  @override
  String get editTaskTitle => 'تعديل المهمة';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get confirm => 'تأكيد';

  @override
  String get taskTitleLabel => 'عنوان المهمة';

  @override
  String get taskTitleRequired => 'عنوان المهمة مطلوب';

  @override
  String get taskNoteLabel => 'ملاحظات (اختيارية)';

  @override
  String get pickDueDateLabel => 'تحديد تاريخ الاستحقاق';

  @override
  String dueDatePrefix(String date) {
    return 'الاستحقاق: $date';
  }

  @override
  String get smartSuggestions => 'اقتراحات ذكية:';

  @override
  String suggestedPriority(String priority) {
    return 'الأولوية المقترحة: $priority';
  }

  @override
  String suggestedDate(String date) {
    return 'التاريخ المقترح: $date';
  }

  @override
  String get applyPriority => 'تطبيق الأولوية';

  @override
  String get applyDate => 'تطبيق التاريخ';

  @override
  String get priorityLabel => 'الأولوية:';

  @override
  String get categoryLabel => 'التصنيف:';

  @override
  String get createTaskButton => 'إنشاء المهمة';

  @override
  String get saveChangesButton => 'حفظ التغييرات';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get appearanceSection => 'المظهر';

  @override
  String get themeModeLabel => 'وضع الثيم';

  @override
  String get themeLight => 'الوضع الفاتح';

  @override
  String get themeDark => 'الوضع الداكن';

  @override
  String get themeSystem => 'تلقائي (حسب النظام)';

  @override
  String get themeChanged => 'تم تغيير وضع الثيم';

  @override
  String get themeSelectTitle => 'اختر وضع الثيم';

  @override
  String get languageSection => 'اللغة';

  @override
  String get languageLabel => 'لغة التطبيق';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSelectTitle => 'اختر اللغة';

  @override
  String get notificationsSection => 'الإشعارات';

  @override
  String get enableNotifications => 'تفعيل الإشعارات';

  @override
  String get enableNotificationsSubtitle => 'استلام إشعارات للمهام والمواعيد';

  @override
  String get notificationsEnabledSnackBar =>
      'تم تفعيل الإشعارات وجدولة التذكيرات';

  @override
  String get notificationsDisabledSnackBar => 'تم تعطيل الإشعارات';

  @override
  String get reminderTimeLabel => 'وقت التذكير';

  @override
  String reminderTimeSubtitle(String time) {
    return 'قبل موعد المهمة بـ $time';
  }

  @override
  String get reminderTimeSelectTitle => 'اختر وقت التذكير';

  @override
  String get reminderTimeUpdated => 'تم تحديث وقت التذكير';

  @override
  String get exactTimeNotifications => 'إشعارات دقيقة الوقت';

  @override
  String get exactTimeNotificationsSubtitle =>
      'إشعار إضافي يظهر في الوقت المحدد تماماً';

  @override
  String get exactTimeNotificationsEnabledSnackBar =>
      'تم تفعيل الإشعارات الدقيقة';

  @override
  String get exactTimeNotificationsDisabledSnackBar =>
      'تم تعطيل الإشعارات الدقيقة';

  @override
  String get testNotification => 'اختبار الإشعارات';

  @override
  String get testNotificationSubtitle => 'إرسال إشعار تجريبي';

  @override
  String get testNotificationSent => 'تم إرسال الإشعار التجريبي';

  @override
  String get testNotificationTitle => 'اختبار';

  @override
  String get testNotificationBody => 'هذا إشعار تجريبي';

  @override
  String get voiceSettingsSection => 'إعدادات الصوت';

  @override
  String get soundSettingsUpdated => 'تم تحديث إعدادات الصوت';

  @override
  String get securitySection => 'الأمان';

  @override
  String get appLockLabel => 'قفل التطبيق';

  @override
  String get appLockSubtitle => 'حماية التطبيق بالبصمة أو رمز الجهاز';

  @override
  String get appLockEnabledSnackBar => 'تم تفعيل قفل التطبيق';

  @override
  String get appLockDisabledSnackBar => 'تم تعطيل قفل التطبيق';

  @override
  String get profileSection => 'الملف الشخصي';

  @override
  String get userNameLabel => 'اسم المستخدم';

  @override
  String get editNameTitle => 'تعديل الاسم';

  @override
  String get nameRequired => 'يرجى إدخال الاسم';

  @override
  String get nameUpdated => 'تم تحديث الاسم بنجاح';

  @override
  String get aboutSection => 'حول التطبيق';

  @override
  String get aboutAppLabel => 'معلومات التطبيق';

  @override
  String get aboutAppSubtitle => 'Y0 To-Do App v3.3.0';

  @override
  String get aboutAppDescription =>
      'تطبيق مهام احترافي مع دعم كامل للغتين العربية والإنجليزية، التشفير الآمن AES-256، وترتيب المهام بالأولوية.';

  @override
  String get resetSettingsLabel => 'إعادة تعيين الإعدادات';

  @override
  String get resetSettingsSubtitle => 'استعادة جميع الإعدادات الافتراضية';

  @override
  String get resetConfirmTitle => 'إعادة تعيين الإعدادات';

  @override
  String get resetConfirmMessage =>
      'هل أنت متأكد من إعادة تعيين جميع الإعدادات إلى القيم الافتراضية؟';

  @override
  String get settingsResetSnackBar => 'تم إعادة تعيين جميع الإعدادات';

  @override
  String get backupSection => 'النسخ الاحتياطي';

  @override
  String get createBackupLabel => 'إنشاء نسخة احتياطية';

  @override
  String get createBackupSubtitle => 'تصدير جميع بيانات التطبيق';

  @override
  String get backupSuccessSnackBar => 'تم إنشاء النسخة الاحتياطية بنجاح';

  @override
  String backupFailedSnackBar(String error) {
    return 'فشل إنشاء النسخة الاحتياطية: $error';
  }

  @override
  String get restoreBackupLabel => 'استعادة نسخة احتياطية';

  @override
  String get restoreBackupSubtitle => 'استيراد بيانات من نسخة احتياطية';

  @override
  String get restoreConfirmTitle => 'استعادة نسخة احتياطية';

  @override
  String get restoreConfirmMessage =>
      'هل تريد استعادة نسخة احتياطية؟ سيتم استبدال جميع البيانات الحالية.';

  @override
  String get restoreFeatureComingSoon => 'ميزة الاستعادة قيد التطوير';

  @override
  String minutesFormat(int minutes) {
    return '$minutes دقيقة';
  }

  @override
  String get oneHour => 'ساعة واحدة';

  @override
  String hoursFormat(int hours) {
    return '$hours ساعات';
  }

  @override
  String get oneDay => 'يوم واحد';

  @override
  String get statisticsTitle => 'إحصائيات الإنجاز';

  @override
  String get statisticsSubtitle => 'نظرة عامة';

  @override
  String get statisticsOverviewSubtitle => 'Achievement Overview';

  @override
  String get completionRateLabel => 'نسبة الإنجاز';

  @override
  String get quickStatsTotalTasks => 'إجمالي المهام';

  @override
  String get quickStatsCompletedTasks => 'مكتملة';

  @override
  String get quickStatsPendingTasks => 'قيد التنفيذ';

  @override
  String get quickStatsArchivedTasks => 'مؤرشفة';

  @override
  String get weeklyProductivityTitle => 'الإنتاجية الأسبوعية';

  @override
  String get achievementBadgesTitle => 'أوسمة الإنجاز';

  @override
  String get badgeFirstTask => 'المهمة الأولى';

  @override
  String get badgeFirstTaskDesc => 'أكملت أول مهمة بنجاح';

  @override
  String get badgeFiveTasks => 'بداية قوية';

  @override
  String get badgeFiveTasksDesc => 'أكملت 5 مهام';

  @override
  String get badgeTenTasks => 'بطل الإنتاجية';

  @override
  String get badgeTenTasksDesc => 'أكملت 10 مهام';

  @override
  String get archiveSummaryTitle => 'ملخص الأرشيف';

  @override
  String get archiveSummaryOverdueOnly => 'متأخرة > 30 يوم';

  @override
  String get archiveSummaryCompleted => 'مكتملة ومؤرشفة';

  @override
  String get archiveSummaryTotal => 'إجمالي الأرشيف';

  @override
  String get voiceInputTitle => 'الإدخال الصوتي والتحليل الذكي';

  @override
  String get voiceInputHint => 'انقر الميكروفون للتحدث بأمر صوتي';

  @override
  String get errorGeneral => 'حدث خطأ. يرجى المحاولة مرة أخرى.';

  @override
  String get errorInitApp => 'فشل في تهيئة التطبيق';
}
