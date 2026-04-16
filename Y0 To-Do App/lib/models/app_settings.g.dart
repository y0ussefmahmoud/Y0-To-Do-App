// GENERATED CODE - DO NOT MODIFY BY HAND

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
      themeMode: fields[0] as String,
      language: fields[1] as String,
      notificationsEnabled: fields[2] as bool,
      soundEnabled: fields[3] as bool,
      speechRate: fields[4] as double,
      speechVolume: fields[5] as double,
      speechPitch: fields[6] as double,
      notificationMinutesBefore: fields[7] as int,
      exactTimeNotificationsEnabled: fields[8] as bool,
      userName: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(10)
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
      ..write(obj.userName);
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
