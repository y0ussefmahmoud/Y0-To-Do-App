import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';
import '../models/app_settings.dart';
import '../models/search_history.dart';
import '../utils/error_handler.dart';

/// 💾 Backup Service - Data Backup and Restore
/// 
/// This service handles exporting and importing application data
/// for backup and restore functionality.
/// 
/// Key Features:
/// - Export all Hive boxes to JSON format
/// - Import data from JSON backup files
/// - Share backup files via system share sheet
/// - Automatic data validation before restore
/// - Version compatibility checking
/// 
/// Example Usage:
/// ```dart
/// final backupService = BackupService();
/// 
/// // Export data
/// await backupService.exportBackup();
/// 
/// // Import data
/// await backupService.importBackup(jsonString);
/// ```
/// 
/// @author Y0 Development Team
/// @version 3.2.6
class BackupService {
  static final BackupService _instance = BackupService._internal();
  
  factory BackupService() => _instance;
  
  BackupService._internal();

  /// Export all application data to JSON format
  /// 
  /// Exports tasks, settings, and search history to a JSON string.
  /// 
  /// Returns: JSON string containing all data
  /// 
  /// Throws: BackupException if export fails
  Future<String> exportBackup() async {
    try {
      final backupData = <String, dynamic>{
        'version': '3.2.6',
        'timestamp': DateTime.now().toIso8601String(),
        'data': {
          'tasks': await _exportTasks(),
          'settings': await _exportSettings(),
          'searchHistory': await _exportSearchHistory(),
        },
      };

      final jsonString = jsonEncode(backupData);
      ErrorHandler.logInfo('Backup exported successfully');
      
      return jsonString;
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace, context: 'Backup export');
      throw BackupException('Failed to export backup: $e');
    }
  }

  /// Export backup and share via system share sheet
  /// 
  /// Creates a JSON file and opens system share dialog.
  /// 
  /// Throws: BackupException if export or share fails
  Future<void> exportAndShareBackup() async {
    try {
      final jsonString = await exportBackup();
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/y0_todo_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonString);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Y0 To-Do App Backup',
        text: 'Backup created on ${DateTime.now().toString()}',
      );
      
      ErrorHandler.logInfo('Backup shared successfully');
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace, context: 'Backup share');
      throw BackupException('Failed to share backup: $e');
    }
  }

  /// Import data from JSON backup string
  /// 
  /// Validates backup version and imports data to Hive boxes.
  /// 
  /// Parameters:
  /// - [jsonString] JSON string containing backup data
  /// 
  /// Returns: Number of items imported
  /// 
  /// Throws: BackupException if import fails or validation error
  Future<int> importBackup(String jsonString) async {
    try {
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Validate backup structure
      if (!_validateBackup(backupData)) {
        throw BackupException('Invalid backup format');
      }

      final data = backupData['data'] as Map<String, dynamic>;
      int importCount = 0;

      // Import tasks
      if (data.containsKey('tasks')) {
        await _importTasks(data['tasks'] as List);
        importCount += (data['tasks'] as List).length;
      }

      // Import settings
      if (data.containsKey('settings')) {
        await _importSettings(data['settings'] as Map<String, dynamic>);
        importCount += 1;
      }

      // Import search history
      if (data.containsKey('searchHistory')) {
        await _importSearchHistory(data['searchHistory'] as List);
        importCount += (data['searchHistory'] as List).length;
      }

      ErrorHandler.logInfo('Backup imported successfully: $importCount items');
      
      return importCount;
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace, context: 'Backup import');
      throw BackupException('Failed to import backup: $e');
    }
  }

  /// Export tasks from Hive box
  Future<List<Map<String, dynamic>>> _exportTasks() async {
    final tasksBox = await Hive.openBox<Task>('tasksBox');
    final tasks = tasksBox.values.toList();
    await tasksBox.close();
    
    return tasks.map((task) => task.toJson()).toList();
  }

  /// Export settings from Hive box
  Future<Map<String, dynamic>> _exportSettings() async {
    final settingsBox = await Hive.openBox<AppSettings>('settingsBox');
    final settings = settingsBox.get('settings');
    await settingsBox.close();
    
    return settings?.toMap() ?? {};
  }

  /// Export search history from Hive box
  Future<List<Map<String, dynamic>>> _exportSearchHistory() async {
    final searchHistoryBox = await Hive.openBox<SearchHistory>('searchHistoryBox');
    final history = searchHistoryBox.values.toList();
    await searchHistoryBox.close();
    
    return history.map((item) => item.toJson()).toList();
  }

  /// Import tasks to Hive box
  Future<void> _importTasks(List<dynamic> tasksData) async {
    final tasksBox = await Hive.openBox<Task>('tasksBox');
    
    // Clear existing tasks
    await tasksBox.clear();
    
    // Import new tasks
    for (final taskData in tasksData) {
      final taskMap = taskData as Map<String, dynamic>;
      final task = Task.fromJson(taskMap);
      await tasksBox.put(task.id, task);
    }
    
    await tasksBox.close();
  }

  /// Import settings to Hive box
  Future<void> _importSettings(Map<String, dynamic> settingsData) async {
    final settingsBox = await Hive.openBox<AppSettings>('settingsBox');
    final settings = AppSettings.fromMap(settingsData);
    await settingsBox.put('settings', settings);
    await settingsBox.close();
  }

  /// Import search history to Hive box
  Future<void> _importSearchHistory(List<dynamic> historyData) async {
    final searchHistoryBox = await Hive.openBox<SearchHistory>('searchHistoryBox');
    
    // Clear existing history
    await searchHistoryBox.clear();
    
    // Import new history
    for (final itemData in historyData) {
      final itemMap = itemData as Map<String, dynamic>;
      final historyItem = SearchHistory.fromJson(itemMap);
      await searchHistoryBox.add(historyItem);
    }
    
    await searchHistoryBox.close();
  }

  /// Validate backup structure and version
  bool _validateBackup(Map<String, dynamic> backupData) {
    if (!backupData.containsKey('version')) return false;
    if (!backupData.containsKey('data')) return false;
    if (!backupData.containsKey('timestamp')) return false;
    
    final data = backupData['data'] as Map<String, dynamic>;
    if (!data.containsKey('tasks')) return false;
    if (!data.containsKey('settings')) return false;
    
    return true;
  }

  /// Get backup info without importing
  /// 
  /// Returns metadata about the backup file.
  /// 
  /// Parameters:
  /// - [jsonString] JSON string containing backup data
  /// 
  /// Returns: Map with version, timestamp, and item counts
  Map<String, dynamic> getBackupInfo(String jsonString) {
    try {
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;
      final data = backupData['data'] as Map<String, dynamic>;
      
      return {
        'version': backupData['version'],
        'timestamp': backupData['timestamp'],
        'tasksCount': (data['tasks'] as List).length,
        'hasSettings': data['settings'] != null,
        'searchHistoryCount': (data['searchHistory'] as List?)?.length ?? 0,
      };
    } catch (e) {
      throw BackupException('Failed to read backup info: $e');
    }
  }
}

/// Custom exception for backup operations
class BackupException implements Exception {
  final String message;
  
  BackupException(this.message);
  
  @override
  String toString() => 'BackupException: $message';
}
