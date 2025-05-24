// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manufacturing_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ManufacturingLogModelAdapter extends TypeAdapter<ManufacturingLogModel> {
  @override
  final int typeId = 3;

  @override
  ManufacturingLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ManufacturingLogModel(
      id: fields[0] as String,
      productName: fields[1] as String,
      quantity: fields[2] as int,
      materialsUsed: (fields[3] as List).cast<MaterialUsage>(),
      manufacturedAt: fields[4] as DateTime,
      notes: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ManufacturingLogModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.materialsUsed)
      ..writeByte(4)
      ..write(obj.manufacturedAt)
      ..writeByte(5)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ManufacturingLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MaterialUsageAdapter extends TypeAdapter<MaterialUsage> {
  @override
  final int typeId = 4;

  @override
  MaterialUsage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MaterialUsage(
      materialId: fields[0] as String,
      materialName: fields[1] as String,
      quantity: fields[2] as double,
      unit: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MaterialUsage obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.materialId)
      ..writeByte(1)
      ..write(obj.materialName)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaterialUsageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
