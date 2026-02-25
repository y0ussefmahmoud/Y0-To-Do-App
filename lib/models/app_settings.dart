import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 4)
class AppSettings {
  @HiveField(0)
  final String themeMode; // 'light', 'dark', 'system'
  
  @HiveField(1)
  final String language; // 'ar', 'en'
  
  @HiveField(2)
  final bool notificationsEnabled;
  
  @HiveField(3)
  final bool soundEnabled;
  
  @HiveField(4)
  final double speechRate; // 0.1 - 1.0
  
  @HiveField(5)
  final double speechVolume; // 0.0 - 1.0
  
  @HiveField(6)
  final double speechPitch; // 0.5 - 2.0
  
  @HiveField(7)
  final int notificationMinutesBefore; // minutes before due date

  const AppSettings({
    this.themeMode = 'system',
    this.language = 'ar',
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.speechRate = 0.5,
    this.speechVolume = 0.8,
    this.speechPitch = 1.0,
    this.notificationMinutesBefore = 60,
  });

  AppSettings copyWith({
    String? themeMode,
    String? language,
    bool? notificationsEnabled,
    bool? soundEnabled,
    double? speechRate,
    double? speechVolume,
    double? speechPitch,
    int? notificationMinutesBefore,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      speechRate: speechRate ?? this.speechRate,
      speechVolume: speechVolume ?? this.speechVolume,
      speechPitch: speechPitch ?? this.speechPitch,
      notificationMinutesBefore: notificationMinutesBefore ?? this.notificationMinutesBefore,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode,
      'language': language,
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'speechRate': speechRate,
      'speechVolume': speechVolume,
      'speechPitch': speechPitch,
      'notificationMinutesBefore': notificationMinutesBefore,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      themeMode: map['themeMode'] ?? 'system',
      language: map['language'] ?? 'ar',
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      soundEnabled: map['soundEnabled'] ?? true,
      speechRate: map['speechRate']?.toDouble() ?? 0.5,
      speechVolume: map['speechVolume']?.toDouble() ?? 0.8,
      speechPitch: map['speechPitch']?.toDouble() ?? 1.0,
      notificationMinutesBefore: map['notificationMinutesBefore'] ?? 60,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.themeMode == themeMode &&
        other.language == language &&
        other.notificationsEnabled == notificationsEnabled &&
        other.soundEnabled == soundEnabled &&
        other.speechRate == speechRate &&
        other.speechVolume == speechVolume &&
        other.speechPitch == speechPitch &&
        other.notificationMinutesBefore == notificationMinutesBefore;
  }

  @override
  int get hashCode {
    return themeMode.hashCode ^
        language.hashCode ^
        notificationsEnabled.hashCode ^
        soundEnabled.hashCode ^
        speechRate.hashCode ^
        speechVolume.hashCode ^
        speechPitch.hashCode ^
        notificationMinutesBefore.hashCode;
  }
}
