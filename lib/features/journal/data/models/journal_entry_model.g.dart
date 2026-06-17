// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_entry_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JournalEntryModelAdapter extends TypeAdapter<JournalEntryModel> {
  @override
  final int typeId = 0;

  @override
  JournalEntryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JournalEntryModel(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      positiveSymptom: fields[2] as double,
      negativeSymptom: fields[3] as double,
      sleepQuality: fields[4] as double,
      stressLevel: fields[5] as double,
      socialEnergy: fields[6] as double,
      note: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, JournalEntryModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.positiveSymptom)
      ..writeByte(3)
      ..write(obj.negativeSymptom)
      ..writeByte(4)
      ..write(obj.sleepQuality)
      ..writeByte(5)
      ..write(obj.stressLevel)
      ..writeByte(6)
      ..write(obj.socialEnergy)
      ..writeByte(7)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JournalEntryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
