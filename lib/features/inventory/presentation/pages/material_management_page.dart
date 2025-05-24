import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:raw_material_management/core/constants/app_constants.dart';
import 'package:raw_material_management/features/inventory/data/models/material_model.dart';
import 'package:raw_material_management/features/inventory/presentation/bloc/material_bloc.dart' as inventory;
import 'package:raw_material_management/features/inventory/presentation/widgets/add_material_dialog.dart';
import 'package:raw_material_management/features/inventory/presentation/widgets/edit_material_dialog.dart';

class MaterialManagementPage extends StatelessWidget {
  const MaterialManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Material Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.sync,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                context.read<inventory.MaterialBloc>().add(inventory.SyncMaterials());
              },
            ),
          ),
        ],
      ),
      body: BlocBuilder<inventory.MaterialBloc, inventory.MaterialState>(
        builder: (context, state) {
          if (state is inventory.MaterialLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading materials...',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is inventory.MaterialError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<inventory.MaterialBloc>().add(inventory.LoadMaterials());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is inventory.MaterialLoaded) {
            return _buildMaterialList(context, state.materials);
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddMaterialDialog(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Material'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 4,
      ),
    );
  }

  Widget _buildMaterialList(BuildContext context, List<MaterialModel> materials) {
    if (materials.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No materials found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add some materials to get started',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: materials.length,
      itemBuilder: (context, index) {
        final material = materials[index];
        return _buildMaterialCard(context, material);
      },
    );
  }

  Widget _buildMaterialCard(BuildContext context, MaterialModel material) {
    final isBelowThreshold = material.currentQuantity < material.thresholdQuantity;
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    final formattedDate = dateFormat.format(material.lastUpdated);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                showDialog(
                  context: context,
                  builder: (context) => EditMaterialDialog(material: material),
                );
              },
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              icon: Icons.edit,
              label: 'Edit',
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            ),
            SlidableAction(
              onPressed: (context) {
                context.read<inventory.MaterialBloc>().add(inventory.DeleteMaterial(material.id));
              },
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
            ),
          ],
        ),
        child: Card(
          elevation: 4,
          shadowColor: colorScheme.shadow.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: isBelowThreshold
                ? BorderSide(color: colorScheme.error.withOpacity(0.5), width: 1)
                : BorderSide.none,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.surface,
                  colorScheme.surface.withOpacity(0.95),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.inventory_2_outlined,
                                color: colorScheme.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                material.name,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isBelowThreshold)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 16,
                                color: colorScheme.error,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Low Stock',
                                style: TextStyle(
                                  color: colorScheme.error,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.1),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuantityInfo(
                                context,
                                'Current Quantity',
                                '${material.currentQuantity} ${material.unit}',
                                Icons.inventory_2_outlined,
                              ),
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              color: colorScheme.outline.withOpacity(0.1),
                            ),
                            Expanded(
                              child: _buildQuantityInfo(
                                context,
                                'Threshold',
                                '${material.thresholdQuantity} ${material.unit}',
                                Icons.notifications_outlined,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.update,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Last Updated: $formattedDate',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                  fontWeight: FontWeight.w500,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityInfo(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
} 