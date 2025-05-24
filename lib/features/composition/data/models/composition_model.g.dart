// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'composition_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompositionModelAdapter extends TypeAdapter<CompositionModel> {
  @override
  final int typeId = 1;

  @override
  CompositionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompositionModel(
      id: fields[0] as String,
      productName: fields[1] as String,
      materials: (fields[2] as List).cast<MaterialComposition>(),
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CompositionModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.materials)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompositionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MaterialCompositionAdapter extends TypeAdapter<MaterialComposition> {
  @override
  final int typeId = 2;

  @override
  MaterialComposition read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MaterialComposition(
      materialId: fields[0] as String,
      materialName: fields[1] as String,
      quantity: fields[2] as double,
      unit: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MaterialComposition obj) {
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
      other is MaterialCompositionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
