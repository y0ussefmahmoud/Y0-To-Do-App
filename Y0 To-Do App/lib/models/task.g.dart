// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 1;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      id: fields[0] as String,
      title: fields[1] as String,
      note: fields[2] as String?,
      dueDate: fields[3] as DateTime?,
      priority: fields[4] as int,
      isDone: fields[5] as bool,
      category: fields[6] as TaskCategory?,
      sortOrder: fields[7] as int? ?? 0,
      recurrenceRule: fields[8] as RecurrenceRule?,
      subtasks: (fields[9] as List?)?.cast<SubTask>() ?? const [],
      tags: (fields[10] as List?)?.cast<String>() ?? const [],
      completedAt: fields[13] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.note)
      ..writeByte(3)
      ..write(obj.dueDate)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.isDone)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.sortOrder)
      ..writeByte(8)
      ..write(obj.recurrenceRule)
      ..writeByte(9)
      ..write(obj.subtasks)
      ..writeByte(10)
      ..write(obj.tags)
      ..writeByte(13)
      ..write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
