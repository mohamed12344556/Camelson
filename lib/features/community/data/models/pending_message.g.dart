// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingMessageAdapter extends TypeAdapter<PendingMessage> {
  @override
  final typeId = 5;

  @override
  PendingMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingMessage(
      id: fields[0] as String,
      roomId: fields[1] as String,
      content: fields[2] as String,
      timestamp: fields[3] as DateTime,
      retryCount: fields[4] == null ? 0 : (fields[4] as num).toInt(),
      status: fields[5] == null ? 'pending' : fields[5] as String,
      attachmentPaths: (fields[6] as List?)?.cast<String>(),
      replyToId: fields[7] as String?,
      isQuestion: fields[8] == null ? false : fields[8] as bool,
      lastAttemptAt: fields[9] as DateTime?,
      error: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PendingMessage obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.roomId)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.retryCount)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.attachmentPaths)
      ..writeByte(7)
      ..write(obj.replyToId)
      ..writeByte(8)
      ..write(obj.isQuestion)
      ..writeByte(9)
      ..write(obj.lastAttemptAt)
      ..writeByte(10)
      ..write(obj.error);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
