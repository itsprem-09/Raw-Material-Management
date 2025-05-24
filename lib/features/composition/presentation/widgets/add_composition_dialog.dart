import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raw_material_management/core/constants/app_constants.dart';
import 'package:raw_material_management/features/composition/data/models/composition_model.dart';
import 'package:raw_material_management/features/composition/presentation/bloc/composition_bloc.dart';
import 'package:raw_material_management/features/inventory/data/models/material_model.dart';
import 'package:raw_material_management/features/inventory/presentation/bloc/material_bloc.dart' as inventory;

class AddCompositionDialog extends StatefulWidget {
  const AddCompositionDialog({super.key});

  @override
  State<AddCompositionDialog> createState() => _AddCompositionDialogState();
}

class _AddCompositionDialogState extends State<AddCompositionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final List<MaterialComposition> _materials = [];
  final Map<String, TextEditingController> _quantityControllers = {};

  @override
  void dispose() {
    _productNameController.dispose();
    for (final controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addMaterial(MaterialModel material) {
    if (!_materials.any((m) => m.materialId == material.id)) {
      setState(() {
        _materials.add(
          MaterialComposition(
            materialId: material.id,
            materialName: material.name,
            quantity: 0,
            unit: material.unit,
          ),
        );
        _quantityControllers[material.id] = TextEditingController();
      });
    }
  }

  void _removeMaterial(String materialId) {
    setState(() {
      _materials.removeWhere((m) => m.materialId == materialId);
      _quantityControllers[materialId]?.dispose();
      _quantityControllers.remove(materialId);
    });
  }

  void _updateMaterialQuantity(String materialId, String value) {
    final index = _materials.indexWhere((m) => m.materialId == materialId);
    if (index != -1) {
      setState(() {
        _materials[index] = _materials[index].copyWith(
          quantity: double.tryParse(value) ?? 0,
        );
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final composition = CompositionModel(
        id: '', // Will be set by the repository
        productName: _productNameController.text,
        materials: _materials,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      context.read<CompositionBloc>().add(AddComposition(composition));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Composition'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _productNameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  hintText: 'Enter product name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              BlocBuilder<inventory.MaterialBloc, inventory.MaterialState>(
                builder: (context, state) {
                  if (state is inventory.MaterialLoaded) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Add Materials:'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: state.materials.map((material) {
                            final isSelected = _materials.any(
                              (m) => m.materialId == material.id,
                            );
                            return FilterChip(
                              label: Text(material.name),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  _addMaterial(material);
                                } else {
                                  _removeMaterial(material.id);
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 16),
              if (_materials.isNotEmpty) ...[
                const Text('Material Quantities:'),
                const SizedBox(height: 8),
                ..._materials.map((material) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(material.materialName),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _quantityControllers[material.materialId],
                            decoration: InputDecoration(
                              labelText: 'Quantity',
                              suffixText: material.unit,
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter quantity';
                              }
                              final number = double.tryParse(value);
                              if (number == null) {
                                return 'Please enter a valid number';
                              }
                              if (number < AppConstants.minQuantity) {
                                return 'Quantity must be greater than ${AppConstants.minQuantity}';
                              }
                              if (number > AppConstants.maxQuantity) {
                                return 'Quantity must be less than ${AppConstants.maxQuantity}';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              _updateMaterialQuantity(material.materialId, value);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Add'),
        ),
      ],
    );
  }
} 