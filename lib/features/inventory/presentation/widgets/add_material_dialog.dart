import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raw_material_management/core/constants/app_constants.dart';
import 'package:raw_material_management/features/inventory/data/models/material_model.dart';
import 'package:raw_material_management/features/inventory/presentation/bloc/material_bloc.dart';

class AddMaterialDialog extends StatefulWidget {
  const AddMaterialDialog({super.key});

  @override
  State<AddMaterialDialog> createState() => _AddMaterialDialogState();
}

class _AddMaterialDialogState extends State<AddMaterialDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _currentQuantityController = TextEditingController();
  final _thresholdQuantityController = TextEditingController();
  final _unitController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _currentQuantityController.dispose();
    _thresholdQuantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final material = MaterialModel(
        id: '', // Will be set by the repository
        name: _nameController.text,
        currentQuantity: double.parse(_currentQuantityController.text),
        thresholdQuantity: double.parse(_thresholdQuantityController.text),
        unit: _unitController.text,
        lastUpdated: DateTime.now(),
      );

      context.read<MaterialBloc>().add(AddMaterial(material));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Material'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Material Name',
                  hintText: 'Enter material name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a material name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _currentQuantityController,
                decoration: const InputDecoration(
                  labelText: 'Current Quantity',
                  hintText: 'Enter current quantity',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter current quantity';
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
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _thresholdQuantityController,
                decoration: const InputDecoration(
                  labelText: 'Threshold Quantity',
                  hintText: 'Enter threshold quantity',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter threshold quantity';
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
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _unitController,
                decoration: const InputDecoration(
                  labelText: 'Unit',
                  hintText: 'Enter unit (e.g., kg, units)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a unit';
                  }
                  return null;
                },
              ),
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