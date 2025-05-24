import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raw_material_management/features/inventory/presentation/bloc/material_bloc.dart' as inventory;
import 'package:raw_material_management/features/composition/presentation/bloc/composition_bloc.dart' as composition;
import 'package:raw_material_management/features/manufacturing/presentation/bloc/manufacturing_log_bloc.dart' as manufacturing;
import 'package:raw_material_management/features/inventory/data/models/material_model.dart';
import 'package:raw_material_management/features/composition/data/models/composition_model.dart';
import 'package:raw_material_management/features/manufacturing/data/models/manufacturing_log_model.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<inventory.MaterialBloc, inventory.MaterialState>(
      builder: (context, materialState) {
        return BlocBuilder<composition.CompositionBloc, composition.CompositionState>(
          builder: (context, compositionState) {
            return BlocBuilder<manufacturing.ManufacturingLogBloc, manufacturing.ManufacturingLogState>(
              builder: (context, manufacturingState) {
                List<MaterialModel> materials = [];
                List<CompositionModel> compositions = [];
                List<ManufacturingLogModel> manufacturingLogs = [];

                if (materialState is inventory.MaterialLoaded) {
                  materials = materialState.materials;
                }
                if (compositionState is composition.CompositionLoaded) {
                  compositions = compositionState.compositions;
                }
                if (manufacturingState is manufacturing.ManufacturingLogLoaded) {
                  manufacturingLogs = manufacturingState.logs;
                }

                final lowStockMaterials = materials.where((material) => 
                  material.currentQuantity <= material.thresholdQuantity).length;

                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Analysis Dashboard'),
                    elevation: 0,
                  ),
                  body: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary Cards
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildSummaryCard(
                                  context,
                                  'Total Materials',
                                  materials.length.toString(),
                                  Icons.inventory_2,
                                  Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildSummaryCard(
                                  context,
                                  'Active Compositions',
                                  compositions.length.toString(),
                                  Icons.science,
                                  Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildSummaryCard(
                                  context,
                                  'Manufacturing Logs',
                                  manufacturingLogs.length.toString(),
                                  Icons.history,
                                  Theme.of(context).colorScheme.tertiary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildSummaryCard(
                                  context,
                                  'Low Stock Items',
                                  lowStockMaterials.toString(),
                                  Icons.warning,
                                  Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Charts Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Material Usage Analysis',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 300,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildMaterialUsageChart(context, materials),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Composition Distribution',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 300,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildCompositionPieChart(context, compositions),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Manufacturing Trends',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 300,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildManufacturingTrendChart(context, manufacturingLogs),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialUsageChart(BuildContext context, List<MaterialModel> materials) {
    // Group materials by unit and calculate total quantity
    final unitQuantities = <String, double>{};
    for (var material in materials) {
      unitQuantities[material.unit] = (unitQuantities[material.unit] ?? 0) + material.currentQuantity;
    }

    final spots = <FlSpot>[];
    var index = 0.0;
    for (var entry in unitQuantities.entries) {
      spots.add(FlSpot(index, entry.value));
      index += 1;
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= unitQuantities.length) return const Text('');
                return Text(
                  unitQuantities.keys.elementAt(value.toInt()),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompositionPieChart(BuildContext context, List<CompositionModel> compositions) {
    // Calculate total materials used in compositions
    final materialUsage = <String, double>{};
    for (var composition in compositions) {
      for (var material in composition.materials) {
        materialUsage[material.materialName] = (materialUsage[material.materialName] ?? 0) + material.quantity;
      }
    }

    // Convert to pie chart sections
    final sections = <PieChartSectionData>[];
    final totalUsage = materialUsage.values.fold(0.0, (sum, quantity) => sum + quantity);
    
    var index = 0;
    for (var entry in materialUsage.entries) {
      final percentage = (entry.value / totalUsage * 100).round();
      sections.add(
        PieChartSectionData(
          color: _getColorForIndex(index),
          value: entry.value,
          title: '$percentage%',
          radius: 50 - (index * 5),
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      index++;
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 0,
        centerSpaceRadius: 40,
        sections: sections,
      ),
    );
  }

  Widget _buildManufacturingTrendChart(BuildContext context, List<ManufacturingLogModel> logs) {
    // Group logs by date and calculate total quantity
    final dailyQuantities = <DateTime, double>{};
    for (var log in logs) {
      final date = DateTime(log.manufacturedAt.year, log.manufacturedAt.month, log.manufacturedAt.day);
      dailyQuantities[date] = (dailyQuantities[date] ?? 0) + log.quantity;
    }

    // Sort by date
    final sortedDates = dailyQuantities.keys.toList()..sort();
    
    // Get last 7 days
    final last7Days = sortedDates.length > 7 
        ? sortedDates.sublist(sortedDates.length - 7) 
        : sortedDates;

    final barGroups = <BarChartGroupData>[];
    for (var i = 0; i < last7Days.length; i++) {
      final date = last7Days[i];
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: dailyQuantities[date] ?? 0,
              color: Theme.of(context).colorScheme.primary,
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: dailyQuantities.values.fold(0.0, (max, value) => value > max ? value : max) * 1.2,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= last7Days.length) return const Text('');
                final date = last7Days[value.toInt()];
                return Text(
                  '${date.day}/${date.month}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }
} 