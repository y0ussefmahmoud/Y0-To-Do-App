// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Y0 To-Do';

  @override
  String get appInitializing => 'Initializing app...';

  @override
  String get navHome => 'Home';

  @override
  String get navStatistics => 'Statistics';

  @override
  String get navSettings => 'Settings';

  @override
  String homeGreeting(String name) {
    return 'Welcome, $name!';
  }

  @override
  String get morningGreeting =>
      'Good morning, time to start a productive and positive day.';

  @override
  String get afternoonGreeting =>
      'Good afternoon, time to accomplish the rest of your tasks.';

  @override
  String get eveningGreeting =>
      'Good evening, time to review today\'s achievements.';

  @override
  String dailyProgress(int percent) {
    return 'Today\'s Progress: $percent%';
  }

  @override
  String get progressNearEnd =>
      'You are very close to completing your daily plan!';

  @override
  String get progressGood => 'You are making good progress, keep going!';

  @override
  String get progressStart => 'Let\'s start today by accomplishing your tasks!';

  @override
  String completedOutOfTotal(int completed, int total) {
    return '$completed of $total tasks';
  }

  @override
  String get searchHint => 'Search tasks...';

  @override
  String get searchHistoryTitle => 'Search History';

  @override
  String get clearAllHistory => 'Clear All';

  @override
  String get clearAllConfirm =>
      'Are you sure you want to clear your entire search history?';

  @override
  String get noSearchHistoryTitle => 'No Search History';

  @override
  String get noSearchHistorySubtitle =>
      'Start searching for tasks and history will appear here';

  @override
  String get searchCleared => 'Search history cleared';

  @override
  String get quickTagHighPriority => 'High Priority';

  @override
  String get quickTagTodayTasks => 'Today\'s Tasks';

  @override
  String get quickTagOverdue => 'Overdue';

  @override
  String get quickTagWork => 'Work';

  @override
  String get quickTagStudy => 'Study';

  @override
  String get tasksSectionTitle => 'Tasks';

  @override
  String get viewAll => 'View All';

  @override
  String get noTasksTitle => 'No tasks yet';

  @override
  String get noTasksSubtitle =>
      'Either you\'ve finished everything or no results match';

  @override
  String get filterAll => 'All';

  @override
  String get filterPending => 'Pending';

  @override
  String get filterCompleted => 'Completed';

  @override
  String get filterArchive => 'Archive';

  @override
  String get filterToday => 'Today';

  @override
  String get filterThisWeek => 'This Week';

  @override
  String get filterOverdue => 'Overdue';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityLow => 'Low';

  @override
  String get categoryWork => 'Work';

  @override
  String get categoryPersonal => 'Personal';

  @override
  String get categoryStudy => 'Study';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryGeneral => 'General';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get taskDoneSnackBar => 'Task marked as completed';

  @override
  String get taskUndoneSnackBar => 'Task marked as incomplete';

  @override
  String get taskDeleteConfirmTitle => 'Confirm Deletion';

  @override
  String taskDeleteConfirmMessage(String title) {
    return 'Are you sure you want to delete \"$title\"?';
  }

  @override
  String get taskDeletedSnackBar => 'Task deleted successfully';

  @override
  String get addTaskTitle => 'Add New Task';

  @override
  String get editTaskTitle => 'Edit Task';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get taskTitleLabel => 'Task Title';

  @override
  String get taskTitleRequired => 'Task title is required';

  @override
  String get taskNoteLabel => 'Notes (optional)';

  @override
  String get pickDueDateLabel => 'Set Due Date';

  @override
  String dueDatePrefix(String date) {
    return 'Due: $date';
  }

  @override
  String get smartSuggestions => 'Smart Suggestions:';

  @override
  String suggestedPriority(String priority) {
    return 'Suggested Priority: $priority';
  }

  @override
  String suggestedDate(String date) {
    return 'Suggested Date: $date';
  }

  @override
  String get applyPriority => 'Apply Priority';

  @override
  String get applyDate => 'Apply Date';

  @override
  String get priorityLabel => 'Priority:';

  @override
  String get categoryLabel => 'Category:';

  @override
  String get createTaskButton => 'Create Task';

  @override
  String get saveChangesButton => 'Save Changes';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get themeModeLabel => 'Theme Mode';

  @override
  String get themeLight => 'Light Mode';

  @override
  String get themeDark => 'Dark Mode';

  @override
  String get themeSystem => 'System Default';

  @override
  String get themeChanged => 'Theme mode updated';

  @override
  String get themeSelectTitle => 'Select Theme Mode';

  @override
  String get languageSection => 'Language';

  @override
  String get languageLabel => 'App Language';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSelectTitle => 'Select Language';

  @override
  String get notificationsSection => 'Notifications';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get enableNotificationsSubtitle =>
      'Receive notifications for tasks and due dates';

  @override
  String get notificationsEnabledSnackBar =>
      'Notifications enabled and reminders scheduled';

  @override
  String get notificationsDisabledSnackBar => 'Notifications disabled';

  @override
  String get reminderTimeLabel => 'Reminder Time';

  @override
  String reminderTimeSubtitle(String time) {
    return '$time before task due date';
  }

  @override
  String get reminderTimeSelectTitle => 'Select Reminder Time';

  @override
  String get reminderTimeUpdated => 'Reminder time updated';

  @override
  String get exactTimeNotifications => 'Exact-Time Notifications';

  @override
  String get exactTimeNotificationsSubtitle =>
      'Extra notification at the exact due time';

  @override
  String get exactTimeNotificationsEnabledSnackBar =>
      'Exact-time notifications enabled';

  @override
  String get exactTimeNotificationsDisabledSnackBar =>
      'Exact-time notifications disabled';

  @override
  String get testNotification => 'Test Notifications';

  @override
  String get testNotificationSubtitle => 'Send a test notification';

  @override
  String get testNotificationSent => 'Test notification sent';

  @override
  String get testNotificationTitle => 'Test';

  @override
  String get testNotificationBody => 'This is a test notification';

  @override
  String get voiceSettingsSection => 'Voice Settings';

  @override
  String get soundSettingsUpdated => 'Sound settings updated';

  @override
  String get securitySection => 'Security';

  @override
  String get appLockLabel => 'App Lock';

  @override
  String get appLockSubtitle =>
      'Protect the app with biometric or device passcode';

  @override
  String get appLockEnabledSnackBar => 'App lock enabled';

  @override
  String get appLockDisabledSnackBar => 'App lock disabled';

  @override
  String get profileSection => 'Profile';

  @override
  String get userNameLabel => 'Username';

  @override
  String get editNameTitle => 'Edit Name';

  @override
  String get nameRequired => 'Please enter your name';

  @override
  String get nameUpdated => 'Name updated successfully';

  @override
  String get aboutSection => 'About App';

  @override
  String get aboutAppLabel => 'App Information';

  @override
  String get aboutAppSubtitle => 'Y0 To-Do App v3.3.0';

  @override
  String get aboutAppDescription =>
      'A professional task management app with full Arabic and English support, secure AES-256 encryption, and priority sorting.';

  @override
  String get resetSettingsLabel => 'Reset Settings';

  @override
  String get resetSettingsSubtitle => 'Restore all default settings';

  @override
  String get resetConfirmTitle => 'Reset Settings';

  @override
  String get resetConfirmMessage =>
      'Are you sure you want to reset all settings to default values?';

  @override
  String get settingsResetSnackBar => 'All settings have been reset';

  @override
  String get backupSection => 'Backup';

  @override
  String get createBackupLabel => 'Create Backup';

  @override
  String get createBackupSubtitle => 'Export all application data';

  @override
  String get backupSuccessSnackBar => 'Backup created successfully';

  @override
  String backupFailedSnackBar(String error) {
    return 'Failed to create backup: $error';
  }

  @override
  String get restoreBackupLabel => 'Restore Backup';

  @override
  String get restoreBackupSubtitle => 'Import data from a backup';

  @override
  String get restoreConfirmTitle => 'Restore Backup';

  @override
  String get restoreConfirmMessage =>
      'Do you want to restore a backup? All current data will be replaced.';

  @override
  String get restoreFeatureComingSoon => 'Restore feature is under development';

  @override
  String minutesFormat(int minutes) {
    return '$minutes minutes';
  }

  @override
  String get oneHour => '1 hour';

  @override
  String hoursFormat(int hours) {
    return '$hours hours';
  }

  @override
  String get oneDay => '1 day';

  @override
  String get statisticsTitle => 'Achievement Overview';

  @override
  String get statisticsSubtitle => 'Overview';

  @override
  String get statisticsOverviewSubtitle => 'Achievement Overview';

  @override
  String get completionRateLabel => 'Completion Rate';

  @override
  String get quickStatsTotalTasks => 'Total Tasks';

  @override
  String get quickStatsCompletedTasks => 'Completed';

  @override
  String get quickStatsPendingTasks => 'Pending';

  @override
  String get quickStatsArchivedTasks => 'Archived';

  @override
  String get weeklyProductivityTitle => 'Weekly Productivity';

  @override
  String get achievementBadgesTitle => 'Achievement Badges';

  @override
  String get badgeFirstTask => 'First Task';

  @override
  String get badgeFirstTaskDesc => 'Completed your first task successfully';

  @override
  String get badgeFiveTasks => 'Strong Start';

  @override
  String get badgeFiveTasksDesc => 'Completed 5 tasks';

  @override
  String get badgeTenTasks => 'Productivity Champion';

  @override
  String get badgeTenTasksDesc => 'Completed 10 tasks';

  @override
  String get archiveSummaryTitle => 'Archive Summary';

  @override
  String get archiveSummaryOverdueOnly => 'Overdue > 30 Days';

  @override
  String get archiveSummaryCompleted => 'Completed & Archived';

  @override
  String get archiveSummaryTotal => 'Total Archived';

  @override
  String get voiceInputTitle => 'Voice Input & Smart Analysis';

  @override
  String get voiceInputHint => 'Tap the microphone to speak a command';

  @override
  String get errorGeneral => 'An error occurred. Please try again.';

  @override
  String get errorInitApp => 'Failed to initialize the app';
}
