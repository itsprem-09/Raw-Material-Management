import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'manufacturing_log_model.g.dart';

@HiveType(typeId: 3)
class ManufacturingLogModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String productName;

  @HiveField(2)
  final int quantity;

  @HiveField(3)
  final List<MaterialUsage> materialsUsed;

  @HiveField(4)
  final DateTime manufacturedAt;

  @HiveField(5)
  final String? notes;

  const ManufacturingLogModel({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.materialsUsed,
    required this.manufacturedAt,
    this.notes,
  });

  ManufacturingLogModel copyWith({
    String? id,
    String? productName,
    int? quantity,
    List<MaterialUsage>? materialsUsed,
    DateTime? manufacturedAt,
    String? notes,
  }) {
    return ManufacturingLogModel(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      materialsUsed: materialsUsed ?? this.materialsUsed,
      manufacturedAt: manufacturedAt ?? this.manufacturedAt,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productName': productName,
      'quantity': quantity,
      'materialsUsed': materialsUsed.map((m) => m.toJson()).toList(),
      'manufacturedAt': manufacturedAt.toIso8601String(),
      'notes': notes,
    };
  }

  factory ManufacturingLogModel.fromJson(Map<String, dynamic> json) {
    return ManufacturingLogModel(
      id: json['id'] as String,
      productName: json['productName'] as String,
      quantity: json['quantity'] as int,
      materialsUsed: (json['materialsUsed'] as List)
          .map((m) => MaterialUsage.fromJson(m as Map<String, dynamic>))
          .toList(),
      manufacturedAt: DateTime.parse(json['manufacturedAt'] as String),
      notes: json['notes'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        productName,
        quantity,
        materialsUsed,
        manufacturedAt,
        notes,
      ];
}

@HiveType(typeId: 4)
class MaterialUsage extends Equatable {
  @HiveField(0)
  final String materialId;

  @HiveField(1)
  final String materialName;

  @HiveField(2)
  final double quantity;

  @HiveField(3)
  final String unit;

  const MaterialUsage({
    required this.materialId,
    required this.materialName,
    required this.quantity,
    required this.unit,
  });

  MaterialUsage copyWith({
    String? materialId,
    String? materialName,
    double? quantity,
    String? unit,
  }) {
    return MaterialUsage(
      materialId: materialId ?? this.materialId,
      materialName: materialName ?? this.materialName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'materialId': materialId,
      'materialName': materialName,
      'quantity': quantity,
      'unit': unit,
    };
  }

  factory MaterialUsage.fromJson(Map<String, dynamic> json) {
    return MaterialUsage(
      materialId: json['materialId'] as String,
      materialName: json['materialName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
    );
  }

  @override
  List<Object?> get props => [
        materialId,
        materialName,
        quantity,
        unit,
      ];
} 