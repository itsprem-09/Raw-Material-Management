import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'composition_model.g.dart';

@HiveType(typeId: 1)
class CompositionModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String productName;

  @HiveField(2)
  final List<MaterialComposition> materials;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime updatedAt;

  const CompositionModel({
    required this.id,
    required this.productName,
    required this.materials,
    required this.createdAt,
    required this.updatedAt,
  });

  CompositionModel copyWith({
    String? id,
    String? productName,
    List<MaterialComposition>? materials,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CompositionModel(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      materials: materials ?? this.materials,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productName': productName,
      'materials': materials.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CompositionModel.fromJson(Map<String, dynamic> json) {
    return CompositionModel(
      id: json['id'] as String,
      productName: json['productName'] as String,
      materials: (json['materials'] as List)
          .map((m) => MaterialComposition.fromJson(m as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        productName,
        materials,
        createdAt,
        updatedAt,
      ];
}

@HiveType(typeId: 2)
class MaterialComposition extends Equatable {
  @HiveField(0)
  final String materialId;

  @HiveField(1)
  final String materialName;

  @HiveField(2)
  final double quantity;

  @HiveField(3)
  final String unit;

  const MaterialComposition({
    required this.materialId,
    required this.materialName,
    required this.quantity,
    required this.unit,
  });

  MaterialComposition copyWith({
    String? materialId,
    String? materialName,
    double? quantity,
    String? unit,
  }) {
    return MaterialComposition(
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

  factory MaterialComposition.fromJson(Map<String, dynamic> json) {
    return MaterialComposition(
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