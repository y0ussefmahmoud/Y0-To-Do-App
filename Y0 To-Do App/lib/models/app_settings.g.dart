// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

// GENERATED CODE - DO NOT MODIFY BY HAND
// Manually maintained for compatibility. Re-run build_runner if adding more fields.

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 4;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      themeMode: fields[0] as String? ?? 'system',
      language: fields[1] as String? ?? 'ar',
      notificationsEnabled: fields[2] as bool? ?? true,
      soundEnabled: fields[3] as bool? ?? true,
      speechRate: (fields[4] as num?)?.toDouble() ?? 0.5,
      speechVolume: (fields[5] as num?)?.toDouble() ?? 0.8,
      speechPitch: (fields[6] as num?)?.toDouble() ?? 1.0,
      notificationMinutesBefore: fields[7] as int? ?? 60,
      exactTimeNotificationsEnabled: fields[8] as bool? ?? false,
      userName: fields[9] as String? ?? 'أحمد',
      // Field 10: appLockEnabled — safe default false for existing records
      appLockEnabled: fields[10] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.themeMode)
      ..writeByte(1)
      ..write(obj.language)
      ..writeByte(2)
      ..write(obj.notificationsEnabled)
      ..writeByte(3)
      ..write(obj.soundEnabled)
      ..writeByte(4)
      ..write(obj.speechRate)
      ..writeByte(5)
      ..write(obj.speechVolume)
      ..writeByte(6)
      ..write(obj.speechPitch)
      ..writeByte(7)
      ..write(obj.notificationMinutesBefore)
      ..writeByte(8)
      ..write(obj.exactTimeNotificationsEnabled)
      ..writeByte(9)
      ..write(obj.userName)
      ..writeByte(10)
      ..write(obj.appLockEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
