import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'Y0 To-Do'**
  String get appTitle;

  /// No description provided for @appInitializing.
  ///
  /// In ar, this message translates to:
  /// **'جاري تهيئة التطبيق...'**
  String get appInitializing;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navStatistics.
  ///
  /// In ar, this message translates to:
  /// **'الإحصائيات'**
  String get navStatistics;

  /// No description provided for @navSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get navSettings;

  /// No description provided for @homeGreeting.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بك، {name}!'**
  String homeGreeting(String name);

  /// No description provided for @morningGreeting.
  ///
  /// In ar, this message translates to:
  /// **'صباح الخير، حان وقت بداية يوم إيجابي ومثمر.'**
  String get morningGreeting;

  /// No description provided for @afternoonGreeting.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير، حان وقت إنجاز باقي مهامك.'**
  String get afternoonGreeting;

  /// No description provided for @eveningGreeting.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير، حان وقت مراجعة إنجازات يومك.'**
  String get eveningGreeting;

  /// No description provided for @dailyProgress.
  ///
  /// In ar, this message translates to:
  /// **'إنجازك لليوم: {percent}%'**
  String dailyProgress(int percent);

  /// No description provided for @progressNearEnd.
  ///
  /// In ar, this message translates to:
  /// **'أنت قريب جداً من إنهاء خطتك اليومية!'**
  String get progressNearEnd;

  /// No description provided for @progressGood.
  ///
  /// In ar, this message translates to:
  /// **'أنت تسير بخطى جيدة، استمر!'**
  String get progressGood;

  /// No description provided for @progressStart.
  ///
  /// In ar, this message translates to:
  /// **'لنبدأ اليوم بإنجاز مهامك!'**
  String get progressStart;

  /// No description provided for @completedOutOfTotal.
  ///
  /// In ar, this message translates to:
  /// **'{completed} من {total} مهمة'**
  String completedOutOfTotal(int completed, int total);

  /// No description provided for @searchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن مهمة...'**
  String get searchHint;

  /// No description provided for @searchHistoryTitle.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ البحث'**
  String get searchHistoryTitle;

  /// No description provided for @clearAllHistory.
  ///
  /// In ar, this message translates to:
  /// **'مسح الكل'**
  String get clearAllHistory;

  /// No description provided for @clearAllConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من مسح تاريخ البحث بالكامل؟'**
  String get clearAllConfirm;

  /// No description provided for @noSearchHistoryTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد تاريخ بحث'**
  String get noSearchHistoryTitle;

  /// No description provided for @noSearchHistorySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ بالبحث عن مهام وسيظهر هنا تاريخ البحث'**
  String get noSearchHistorySubtitle;

  /// No description provided for @searchCleared.
  ///
  /// In ar, this message translates to:
  /// **'تم مسح تاريخ البحث'**
  String get searchCleared;

  /// No description provided for @quickTagHighPriority.
  ///
  /// In ar, this message translates to:
  /// **'أولوية عالية'**
  String get quickTagHighPriority;

  /// No description provided for @quickTagTodayTasks.
  ///
  /// In ar, this message translates to:
  /// **'مهام اليوم'**
  String get quickTagTodayTasks;

  /// No description provided for @quickTagOverdue.
  ///
  /// In ar, this message translates to:
  /// **'متأخرة'**
  String get quickTagOverdue;

  /// No description provided for @quickTagWork.
  ///
  /// In ar, this message translates to:
  /// **'العمل'**
  String get quickTagWork;

  /// No description provided for @quickTagStudy.
  ///
  /// In ar, this message translates to:
  /// **'الدراسة'**
  String get quickTagStudy;

  /// No description provided for @tasksSectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'المهام'**
  String get tasksSectionTitle;

  /// No description provided for @viewAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get viewAll;

  /// No description provided for @noTasksTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مهام حالياً'**
  String get noTasksTitle;

  /// No description provided for @noTasksSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إما أنك أنهيت كل المهام أو لا توجد نتائج مطابقة'**
  String get noTasksSubtitle;

  /// No description provided for @filterAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get filterAll;

  /// No description provided for @filterPending.
  ///
  /// In ar, this message translates to:
  /// **'معلقة'**
  String get filterPending;

  /// No description provided for @filterCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get filterCompleted;

  /// No description provided for @filterArchive.
  ///
  /// In ar, this message translates to:
  /// **'الأرشيف'**
  String get filterArchive;

  /// No description provided for @filterToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get filterToday;

  /// No description provided for @filterThisWeek.
  ///
  /// In ar, this message translates to:
  /// **'هذا الأسبوع'**
  String get filterThisWeek;

  /// No description provided for @filterOverdue.
  ///
  /// In ar, this message translates to:
  /// **'متأخرة'**
  String get filterOverdue;

  /// No description provided for @priorityHigh.
  ///
  /// In ar, this message translates to:
  /// **'عالية'**
  String get priorityHigh;

  /// No description provided for @priorityMedium.
  ///
  /// In ar, this message translates to:
  /// **'متوسطة'**
  String get priorityMedium;

  /// No description provided for @priorityLow.
  ///
  /// In ar, this message translates to:
  /// **'منخفضة'**
  String get priorityLow;

  /// No description provided for @categoryWork.
  ///
  /// In ar, this message translates to:
  /// **'عمل'**
  String get categoryWork;

  /// No description provided for @categoryPersonal.
  ///
  /// In ar, this message translates to:
  /// **'شخصي'**
  String get categoryPersonal;

  /// No description provided for @categoryStudy.
  ///
  /// In ar, this message translates to:
  /// **'دراسة'**
  String get categoryStudy;

  /// No description provided for @categoryHealth.
  ///
  /// In ar, this message translates to:
  /// **'صحة'**
  String get categoryHealth;

  /// No description provided for @categoryGeneral.
  ///
  /// In ar, this message translates to:
  /// **'عام'**
  String get categoryGeneral;

  /// No description provided for @categoryShopping.
  ///
  /// In ar, this message translates to:
  /// **'تسوق'**
  String get categoryShopping;

  /// No description provided for @categoryEntertainment.
  ///
  /// In ar, this message translates to:
  /// **'ترفيه'**
  String get categoryEntertainment;

  /// No description provided for @taskDoneSnackBar.
  ///
  /// In ar, this message translates to:
  /// **'تم إنجاز المهمة'**
  String get taskDoneSnackBar;

  /// No description provided for @taskUndoneSnackBar.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء إنجاز المهمة'**
  String get taskUndoneSnackBar;

  /// No description provided for @taskDeleteConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الحذف'**
  String get taskDeleteConfirmTitle;

  /// No description provided for @taskDeleteConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف \"{title}\"؟'**
  String taskDeleteConfirmMessage(String title);

  /// No description provided for @taskDeletedSnackBar.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف المهمة بنجاح'**
  String get taskDeletedSnackBar;

  /// No description provided for @addTaskTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مهمة جديدة'**
  String get addTaskTitle;

  /// No description provided for @editTaskTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المهمة'**
  String get editTaskTitle;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @taskTitleLabel.
  ///
  /// In ar, this message translates to:
  /// **'عنوان المهمة'**
  String get taskTitleLabel;

  /// No description provided for @taskTitleRequired.
  ///
  /// In ar, this message translates to:
  /// **'عنوان المهمة مطلوب'**
  String get taskTitleRequired;

  /// No description provided for @taskNoteLabel.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات (اختيارية)'**
  String get taskNoteLabel;

  /// No description provided for @pickDueDateLabel.
  ///
  /// In ar, this message translates to:
  /// **'تحديد تاريخ الاستحقاق'**
  String get pickDueDateLabel;

  /// No description provided for @dueDatePrefix.
  ///
  /// In ar, this message translates to:
  /// **'الاستحقاق: {date}'**
  String dueDatePrefix(String date);

  /// No description provided for @smartSuggestions.
  ///
  /// In ar, this message translates to:
  /// **'اقتراحات ذكية:'**
  String get smartSuggestions;

  /// No description provided for @suggestedPriority.
  ///
  /// In ar, this message translates to:
  /// **'الأولوية المقترحة: {priority}'**
  String suggestedPriority(String priority);

  /// No description provided for @suggestedDate.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ المقترح: {date}'**
  String suggestedDate(String date);

  /// No description provided for @applyPriority.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق الأولوية'**
  String get applyPriority;

  /// No description provided for @applyDate.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق التاريخ'**
  String get applyDate;

  /// No description provided for @priorityLabel.
  ///
  /// In ar, this message translates to:
  /// **'الأولوية:'**
  String get priorityLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In ar, this message translates to:
  /// **'التصنيف:'**
  String get categoryLabel;

  /// No description provided for @createTaskButton.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء المهمة'**
  String get createTaskButton;

  /// No description provided for @saveChangesButton.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التغييرات'**
  String get saveChangesButton;

  /// No description provided for @settingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// No description provided for @appearanceSection.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get appearanceSection;

  /// No description provided for @themeModeLabel.
  ///
  /// In ar, this message translates to:
  /// **'وضع الثيم'**
  String get themeModeLabel;

  /// No description provided for @themeLight.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الفاتح'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الداكن'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي (حسب النظام)'**
  String get themeSystem;

  /// No description provided for @themeChanged.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير وضع الثيم'**
  String get themeChanged;

  /// No description provided for @themeSelectTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر وضع الثيم'**
  String get themeSelectTitle;

  /// No description provided for @languageSection.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get languageSection;

  /// No description provided for @languageLabel.
  ///
  /// In ar, this message translates to:
  /// **'لغة التطبيق'**
  String get languageLabel;

  /// No description provided for @languageArabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSelectTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر اللغة'**
  String get languageSelectTitle;

  /// No description provided for @notificationsSection.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notificationsSection;

  /// No description provided for @enableNotifications.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الإشعارات'**
  String get enableNotifications;

  /// No description provided for @enableNotificationsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'استلام إشعارات للمهام والمواعيد'**
  String get enableNotificationsSubtitle;

  /// No description provided for @notificationsEnabledSnackBar.
  ///
  /// In ar, this message translates to:
  /// **'تم تفعيل الإشعارات وجدولة التذكيرات'**
  String get notificationsEnabledSnackBar;

  /// No description provided for @notificationsDisabledSnackBar.
  ///
  /// In ar, this message translates to:
  /// **'تم تعطيل الإشعارات'**
  String get notificationsDisabledSnackBar;

  /// No description provided for @reminderTimeLabel.
  ///
  /// In ar, this message translates to:
  /// **'وقت التذكير'**
  String get reminderTimeLabel;

  /// No description provided for @reminderTimeSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'قبل موعد المهمة بـ {time}'**
  String reminderTimeSubtitle(String time);

  /// No description provided for @reminderTimeSelectTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر وقت التذكير'**
  String get reminderTimeSelectTitle;

  /// No description provided for @reminderTimeUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث وقت التذكير'**
  String get reminderTimeUpdated;

  /// No description provided for @exactTimeNotifications.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات دقيقة الوقت'**
  String get exactTimeNotifications;

  /// No description provided for @exactTimeNotificationsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إشعار إضافي يظهر في الوقت المحدد تماماً'**
  String get exactTimeNotificationsSubtitle;

  /// No description provided for @exactTimeNotificationsEnabledSnackBar.
  ///
  /// In ar, this message translates to:
  /// **'تم تفعيل الإشعارات الدقيقة'**
  String get exactTimeNotificationsEnabledSnackBar;

  /// No description provided for @exactTimeNotificationsDisabledSnackBar.
  ///
  /// In ar, this message translates to:
  /// **'تم تعطيل الإشعارات الدقيقة'**
  String get exactTimeNotificationsDisabledSnackBar;

  /// No description provided for @testNotification.
  ///
  /// In ar, this message translates to:
  /// **'اختبار الإشعارات'**
  String get testNotification;

  /// No description provided for @testNotificationSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إرسال إشعار تجريبي'**
  String get testNotificationSubtitle;

  /// No description provided for @testNotificationSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال الإشعار التجريبي'**
  String get testNotificationSent;

  /// No description provided for @testNotificationTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختبار'**
  String get testNotificationTitle;

  /// No description provided for @testNotificationBody.
  ///
  /// In ar, this message translates to:
  /// **'هذا إشعار تجريبي'**
  String get testNotificationBody;

  /// No description provided for @voiceSettingsSection.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الصوت'**
  String get voiceSettingsSection;

  /// No description provided for @soundSettingsUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث إعدادات الصوت'**
  String get soundSettingsUpdated;

  /// No description provided for @securitySection.
  ///
  /// In ar, this message translates to:
  /// **'الأمان'**
  String get securitySection;

  /// No description provided for @appLockLabel.
  ///
  /// In ar, this message translates to:
  /// **'قفل التطبيق'**
  String get appLockLabel;

  /// No description provided for @appLockSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'حماية التطبيق بالبصمة أو رمز الجهاز'**
  String get appLockSubtitle;

  /// No description provided for @appLockEnabledSnackBar.
  ///
  /// In ar, this message translates to:
  /// **'تم تفعيل قفل التطبيق'**
  String get appLockEnabledSnackBar;

  /// No description provided for @appLockDisabledSnackBar.
  ///
  /// In ar, this message translates to:
  /// **'تم تعطيل قفل التطبيق'**
  String get appLockDisabledSnackBar;

  /// No description provided for @profileSection.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profileSection;

  /// No description provided for @userNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم'**
  String get userNameLabel;

  /// No description provided for @editNameTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الاسم'**
  String get editNameTitle;

  /// No description provided for @nameRequired.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال الاسم'**
  String get nameRequired;

  /// No description provided for @nameUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الاسم بنجاح'**
  String get nameUpdated;

  /// No description provided for @aboutSection.
  ///
  /// In ar, this message translates to:
  /// **'حول التطبيق'**
  String get aboutSection;

  /// No description provided for @aboutAppLabel.
  ///
  /// In ar, this message translates to:
  /// **'معلومات التطبيق'**
  String get aboutAppLabel;

  /// No description provided for @aboutAppSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'Y0 To-Do App v3.4.0'**
  String get aboutAppSubtitle;

  /// No description provided for @aboutAppDescription.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق مهام احترافي مع دعم كامل للغتين العربية والإنجليزية، التشفير الآمن AES-256، وترتيب المهام بالأولوية.'**
  String get aboutAppDescription;

  /// No description provided for @resetSettingsLabel.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين الإعدادات'**
  String get resetSettingsLabel;

  /// No description provided for @resetSettingsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'استعادة جميع الإعدادات الافتراضية'**
  String get resetSettingsSubtitle;

  /// No description provided for @resetConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين الإعدادات'**
  String get resetConfirmTitle;

  /// No description provided for @resetConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من إعادة تعيين جميع الإعدادات إلى القيم الافتراضية؟'**
  String get resetConfirmMessage;

  /// No description provided for @settingsResetSnackBar.
  ///
  /// In ar, this message translates to:
  /// **'تم إعادة تعيين جميع الإعدادات'**
  String get settingsResetSnackBar;

  /// No description provided for @backupSection.
  ///
  /// In ar, this message translates to:
  /// **'النسخ الاحتياطي'**
  String get backupSection;

  /// No description provided for @createBackupLabel.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء نسخة احتياطية'**
  String get createBackupLabel;

  /// No description provided for @createBackupSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تصدير جميع بيانات التطبيق'**
  String get createBackupSubtitle;

  /// No description provided for @backupSuccessSnackBar.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء النسخة الاحتياطية بنجاح'**
  String get backupSuccessSnackBar;

  /// No description provided for @backupFailedSnackBar.
  ///
  /// In ar, this message translates to:
  /// **'فشل إنشاء النسخة الاحتياطية: {error}'**
  String backupFailedSnackBar(String error);

  /// No description provided for @restoreBackupLabel.
  ///
  /// In ar, this message translates to:
  /// **'استعادة نسخة احتياطية'**
  String get restoreBackupLabel;

  /// No description provided for @restoreBackupSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'استيراد بيانات من نسخة احتياطية'**
  String get restoreBackupSubtitle;

  /// No description provided for @restoreConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'استعادة نسخة احتياطية'**
  String get restoreConfirmTitle;

  /// No description provided for @restoreConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد استعادة نسخة احتياطية؟ سيتم استبدال جميع البيانات الحالية.'**
  String get restoreConfirmMessage;

  /// No description provided for @restoreFeatureComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'ميزة الاستعادة قيد التطوير'**
  String get restoreFeatureComingSoon;

  /// No description provided for @minutesFormat.
  ///
  /// In ar, this message translates to:
  /// **'{minutes} دقيقة'**
  String minutesFormat(int minutes);

  /// No description provided for @oneHour.
  ///
  /// In ar, this message translates to:
  /// **'ساعة واحدة'**
  String get oneHour;

  /// No description provided for @hoursFormat.
  ///
  /// In ar, this message translates to:
  /// **'{hours} ساعات'**
  String hoursFormat(int hours);

  /// No description provided for @oneDay.
  ///
  /// In ar, this message translates to:
  /// **'يوم واحد'**
  String get oneDay;

  /// No description provided for @statisticsTitle.
  ///
  /// In ar, this message translates to:
  /// **'إحصائيات الإنجاز'**
  String get statisticsTitle;

  /// No description provided for @statisticsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'نظرة عامة'**
  String get statisticsSubtitle;

  /// No description provided for @statisticsOverviewSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'Achievement Overview'**
  String get statisticsOverviewSubtitle;

  /// No description provided for @completionRateLabel.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الإنجاز'**
  String get completionRateLabel;

  /// No description provided for @quickStatsTotalTasks.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المهام'**
  String get quickStatsTotalTasks;

  /// No description provided for @quickStatsCompletedTasks.
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get quickStatsCompletedTasks;

  /// No description provided for @quickStatsPendingTasks.
  ///
  /// In ar, this message translates to:
  /// **'قيد التنفيذ'**
  String get quickStatsPendingTasks;

  /// No description provided for @quickStatsArchivedTasks.
  ///
  /// In ar, this message translates to:
  /// **'مؤرشفة'**
  String get quickStatsArchivedTasks;

  /// No description provided for @weeklyProductivityTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإنتاجية الأسبوعية'**
  String get weeklyProductivityTitle;

  /// No description provided for @achievementBadgesTitle.
  ///
  /// In ar, this message translates to:
  /// **'أوسمة الإنجاز'**
  String get achievementBadgesTitle;

  /// No description provided for @badgeFirstTask.
  ///
  /// In ar, this message translates to:
  /// **'المهمة الأولى'**
  String get badgeFirstTask;

  /// No description provided for @badgeFirstTaskDesc.
  ///
  /// In ar, this message translates to:
  /// **'أكملت أول مهمة بنجاح'**
  String get badgeFirstTaskDesc;

  /// No description provided for @badgeFiveTasks.
  ///
  /// In ar, this message translates to:
  /// **'بداية قوية'**
  String get badgeFiveTasks;

  /// No description provided for @badgeFiveTasksDesc.
  ///
  /// In ar, this message translates to:
  /// **'أكملت 5 مهام'**
  String get badgeFiveTasksDesc;

  /// No description provided for @badgeTenTasks.
  ///
  /// In ar, this message translates to:
  /// **'بطل الإنتاجية'**
  String get badgeTenTasks;

  /// No description provided for @badgeTenTasksDesc.
  ///
  /// In ar, this message translates to:
  /// **'أكملت 10 مهام'**
  String get badgeTenTasksDesc;

  /// No description provided for @archiveSummaryTitle.
  ///
  /// In ar, this message translates to:
  /// **'ملخص الأرشيف'**
  String get archiveSummaryTitle;

  /// No description provided for @archiveSummaryOverdueOnly.
  ///
  /// In ar, this message translates to:
  /// **'متأخرة > 30 يوم'**
  String get archiveSummaryOverdueOnly;

  /// No description provided for @archiveSummaryCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتملة ومؤرشفة'**
  String get archiveSummaryCompleted;

  /// No description provided for @archiveSummaryTotal.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الأرشيف'**
  String get archiveSummaryTotal;

  /// No description provided for @voiceInputTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإدخال الصوتي والتحليل الذكي'**
  String get voiceInputTitle;

  /// No description provided for @voiceInputHint.
  ///
  /// In ar, this message translates to:
  /// **'انقر الميكروفون للتحدث بأمر صوتي'**
  String get voiceInputHint;

  /// No description provided for @errorGeneral.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ. يرجى المحاولة مرة أخرى.'**
  String get errorGeneral;

  /// No description provided for @errorInitApp.
  ///
  /// In ar, this message translates to:
  /// **'فشل في تهيئة التطبيق'**
  String get errorInitApp;

  /// No description provided for @subtasksTitle.
  ///
  /// In ar, this message translates to:
  /// **'المهام الفرعية'**
  String get subtasksTitle;

  /// No description provided for @subtasksSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'قائمة الخطوات لإنجاز المهمة'**
  String get subtasksSubtitle;

  /// No description provided for @addSubtaskHint.
  ///
  /// In ar, this message translates to:
  /// **'أضف خطوة جديدة...'**
  String get addSubtaskHint;

  /// No description provided for @subtasksProgress.
  ///
  /// In ar, this message translates to:
  /// **'{completed} من {total} مكتملة'**
  String subtasksProgress(int completed, int total);

  /// No description provided for @recurrenceTitle.
  ///
  /// In ar, this message translates to:
  /// **'تكرار المهمة'**
  String get recurrenceTitle;

  /// No description provided for @recurrenceNone.
  ///
  /// In ar, this message translates to:
  /// **'بدون تكرار'**
  String get recurrenceNone;

  /// No description provided for @recurrenceDaily.
  ///
  /// In ar, this message translates to:
  /// **'يومياً'**
  String get recurrenceDaily;

  /// No description provided for @recurrenceWeekly.
  ///
  /// In ar, this message translates to:
  /// **'أسبوعياً'**
  String get recurrenceWeekly;

  /// No description provided for @recurrenceMonthly.
  ///
  /// In ar, this message translates to:
  /// **'شهرياً'**
  String get recurrenceMonthly;

  /// No description provided for @recurrenceCustom.
  ///
  /// In ar, this message translates to:
  /// **'مخصص'**
  String get recurrenceCustom;

  /// No description provided for @recurringBadge.
  ///
  /// In ar, this message translates to:
  /// **'متكررة'**
  String get recurringBadge;

  /// No description provided for @snooze15Mins.
  ///
  /// In ar, this message translates to:
  /// **'تأجيل 15 دقيقة'**
  String get snooze15Mins;

  /// No description provided for @snoozeTomorrow.
  ///
  /// In ar, this message translates to:
  /// **'تأجيل لصباح الغد'**
  String get snoozeTomorrow;

  /// No description provided for @actionComplete.
  ///
  /// In ar, this message translates to:
  /// **'إكمال المهمة'**
  String get actionComplete;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
