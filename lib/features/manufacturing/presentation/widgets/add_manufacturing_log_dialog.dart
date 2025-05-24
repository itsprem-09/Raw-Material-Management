import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raw_material_management/core/constants/app_constants.dart';
import 'package:raw_material_management/features/composition/data/models/composition_model.dart';
import 'package:raw_material_management/features/composition/presentation/bloc/composition_bloc.dart';
import 'package:raw_material_management/features/manufacturing/data/models/manufacturing_log_model.dart';
import 'package:raw_material_management/features/manufacturing/presentation/bloc/manufacturing_log_bloc.dart';

class AddManufacturingLogDialog extends StatefulWidget {
  const AddManufacturingLogDialog({super.key});

  @override
  State<AddManufacturingLogDialog> createState() => _AddManufacturingLogDialogState();
}

class _AddManufacturingLogDialogState extends State<AddManufacturingLogDialog> {
  final _formKey = GlobalKey<FormState>();
  CompositionModel? _selectedComposition;
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedComposition == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a composition'),
          ),
        );
        return;
      }

      final log = ManufacturingLogModel(
        id: '', // Will be set by the repository
        productName: _selectedComposition!.productName,
        quantity: int.parse(_quantityController.text),
        materialsUsed: _selectedComposition!.materials.map((material) {
          return MaterialUsage(
            materialId: material.materialId,
            materialName: material.materialName,
            quantity: material.quantity * int.parse(_quantityController.text),
            unit: material.unit,
          );
        }).toList(),
        manufacturedAt: DateTime.now(),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      context.read<ManufacturingLogBloc>().add(AddManufacturingLog(log));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 600;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.05,
        vertical: screenSize.height * 0.05,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: screenSize.height * 0.9,
              maxWidth: screenSize.width * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: isSmallScreen ? 8 : 16,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Add Manufacturing Log',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        iconSize: isSmallScreen ? 20 : 24,
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Product Composition Dropdown
                          BlocBuilder<CompositionBloc, CompositionState>(
                            builder: (context, state) {
                              if (state is CompositionLoaded) {
                                return DropdownButtonFormField<CompositionModel>(
                                  value: _selectedComposition,
                                  decoration: InputDecoration(
                                    labelText: 'Product Composition',
                                    hintText: 'Select a product composition',
                                    border: const OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: isSmallScreen ? 8 : 12,
                                    ),
                                  ),
                                  items: state.compositions.map((composition) {
                                    return DropdownMenuItem(
                                      value: composition,
                                      child: Text(
                                        composition.productName,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedComposition = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Please select a composition';
                                    }
                                    return null;
                                  },
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          // Quantity Field
                          TextFormField(
                            controller: _quantityController,
                            decoration: InputDecoration(
                              labelText: 'Quantity',
                              hintText: 'Enter quantity to manufacture',
                              border: const OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: isSmallScreen ? 8 : 12,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter quantity';
                              }
                              final number = int.tryParse(value);
                              if (number == null) {
                                return 'Please enter a valid number';
                              }
                              if (number < 1) {
                                return 'Quantity must be greater than 0';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          // Notes Field
                          TextFormField(
                            controller: _notesController,
                            decoration: InputDecoration(
                              labelText: 'Notes',
                              hintText: 'Enter any additional notes (optional)',
                              border: const OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: isSmallScreen ? 8 : 12,
                              ),
                            ),
                            maxLines: 3,
                          ),
                          // Materials List
                          if (_selectedComposition != null) ...[
                            SizedBox(height: isSmallScreen ? 12 : 16),
                            Text(
                              'Materials Required:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 8 : 12),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _selectedComposition!.materials.length,
                                separatorBuilder: (context, index) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final material = _selectedComposition!.materials[index];
                                  final totalQuantity = material.quantity *
                                      (int.tryParse(_quantityController.text) ?? 0);
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: isSmallScreen ? 6 : 8,
                                    ),
                                    child: Row(
                                      children: [
                                        const Text('•'),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            material.materialName,
                                            style: TextStyle(
                                              fontSize: isSmallScreen ? 13 : 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          '${totalQuantity} ${material.unit}',
                                          style: TextStyle(
                                            fontSize: isSmallScreen ? 13 : 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                // Footer
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 