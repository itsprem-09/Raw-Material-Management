import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'material_model.g.dart';

@HiveType(typeId: 0)
class MaterialModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double currentQuantity;

  @HiveField(3)
  final double thresholdQuantity;

  @HiveField(4)
  final String unit;

  @HiveField(5)
  final DateTime lastUpdated;

  const MaterialModel({
    required this.id,
    required this.name,
    required this.currentQuantity,
    required this.thresholdQuantity,
    required this.unit,
    required this.lastUpdated,
  });

  MaterialModel copyWith({
    String? id,
    String? name,
    double? currentQuantity,
    double? thresholdQuantity,
    String? unit,
    DateTime? lastUpdated,
  }) {
    return MaterialModel(
      id: id ?? this.id,
      name: name ?? this.name,
      currentQuantity: currentQuantity ?? this.currentQuantity,
      thresholdQuantity: thresholdQuantity ?? this.thresholdQuantity,
      unit: unit ?? this.unit,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'currentQuantity': currentQuantity,
      'thresholdQuantity': thresholdQuantity,
      'unit': unit,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'] as String,
      name: json['name'] as String,
      currentQuantity: (json['currentQuantity'] as num).toDouble(),
      thresholdQuantity: (json['thresholdQuantity'] as num).toDouble(),
      unit: json['unit'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        currentQuantity,
        thresholdQuantity,
        unit,
        lastUpdated,
      ];
} 