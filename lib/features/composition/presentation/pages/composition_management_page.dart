import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:raw_material_management/core/constants/app_constants.dart';
import 'package:raw_material_management/features/composition/data/models/composition_model.dart';
import 'package:raw_material_management/features/composition/presentation/bloc/composition_bloc.dart';
import 'package:raw_material_management/features/composition/presentation/widgets/add_composition_dialog.dart';
import 'package:raw_material_management/features/composition/presentation/widgets/edit_composition_dialog.dart';

class CompositionManagementPage extends StatelessWidget {
  const CompositionManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Composition Management',
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
                context.read<CompositionBloc>().add(SyncCompositions());
              },
            ),
          ),
        ],
      ),
      body: BlocBuilder<CompositionBloc, CompositionState>(
        builder: (context, state) {
          if (state is CompositionLoading) {
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
                    'Loading compositions...',
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

          if (state is CompositionError) {
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
                      context.read<CompositionBloc>().add(LoadCompositions());
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

          if (state is CompositionLoaded) {
            return _buildCompositionList(context, state.compositions);
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddCompositionDialog(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Composition'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 4,
      ),
    );
  }

  Widget _buildCompositionList(BuildContext context, List<CompositionModel> compositions) {
    if (compositions.isEmpty) {
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
                Icons.science_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No compositions found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add some compositions to get started',
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
      itemCount: compositions.length,
      itemBuilder: (context, index) {
        final composition = compositions[index];
        return _buildCompositionCard(context, composition);
      },
    );
  }

  Widget _buildCompositionCard(BuildContext context, CompositionModel composition) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    final createdDate = dateFormat.format(composition.createdAt);
    final updatedDate = dateFormat.format(composition.updatedAt);

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
                  builder: (context) => EditCompositionDialog(composition: composition),
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
                context.read<CompositionBloc>().add(DeleteComposition(composition.id));
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
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.science_outlined,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          composition.productName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          overflow: TextOverflow.ellipsis,
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
                                Icons.inventory_2_outlined,
                                size: 18,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Materials',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...composition.materials.map((material) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '${material.materialName}: ${material.quantity} ${material.unit}',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: colorScheme.onSurface.withOpacity(0.8),
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateInfo(
                          context,
                          'Created',
                          createdDate,
                          Icons.add_circle_outline,
                        ),
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        color: colorScheme.outline.withOpacity(0.1),
                      ),
                      Expanded(
                        child: _buildDateInfo(
                          context,
                          'Updated',
                          updatedDate,
                          Icons.update,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateInfo(
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
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                size: 16,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
} 