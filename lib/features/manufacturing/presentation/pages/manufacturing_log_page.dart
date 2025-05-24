import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raw_material_management/features/manufacturing/data/models/manufacturing_log_model.dart';
import 'package:raw_material_management/features/manufacturing/presentation/bloc/manufacturing_log_bloc.dart';
import 'package:raw_material_management/features/manufacturing/presentation/widgets/add_manufacturing_log_dialog.dart';
import 'package:raw_material_management/features/manufacturing/presentation/widgets/edit_manufacturing_log_dialog.dart';
import 'package:raw_material_management/features/manufacturing/presentation/widgets/manufacturing_log_card.dart';

class ManufacturingLogPage extends StatelessWidget {
  const ManufacturingLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Manufacturing Log',
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
                context.read<ManufacturingLogBloc>().add(SyncManufacturingLogs());
              },
            ),
          ),
        ],
      ),
      body: BlocBuilder<ManufacturingLogBloc, ManufacturingLogState>(
        builder: (context, state) {
          if (state is ManufacturingLogLoading) {
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
                    'Loading manufacturing logs...',
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

          if (state is ManufacturingLogError) {
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
                    'Error: ${state.message}',
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
                      context.read<ManufacturingLogBloc>().add(LoadManufacturingLogs());
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

          if (state is ManufacturingLogLoaded) {
            if (state.logs.isEmpty) {
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
                        Icons.factory_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No manufacturing logs found',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add some manufacturing logs to get started',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.logs.length,
              itemBuilder: (context, index) {
                final log = state.logs[index];
                return ManufacturingLogCard(
                  log: log,
                  onEdit: () => _showEditDialog(context, log),
                  onDelete: () => _showDeleteConfirmation(context, log),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Log'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 4,
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddManufacturingLogDialog(),
    );
  }

  void _showEditDialog(BuildContext context, ManufacturingLogModel log) {
    showDialog(
      context: context,
      builder: (context) => EditManufacturingLogDialog(log: log),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ManufacturingLogModel log) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 600;
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.05,
          vertical: screenSize.height * 0.05,
        ),
        child: Container(
          constraints: BoxConstraints(
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
                  color: colorScheme.error.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        color: colorScheme.error,
                        size: isSmallScreen ? 20 : 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Delete Manufacturing Log',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.error,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Are you sure you want to delete this manufacturing log?',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.factory_outlined,
                              size: 20,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  log.productName,
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Quantity: ${log.quantity}',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 13 : 14,
                                    color: colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Footer
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.1),
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
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<ManufacturingLogBloc>().add(DeleteManufacturingLog(log.id));
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 