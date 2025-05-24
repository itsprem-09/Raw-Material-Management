import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raw_material_management/core/theme/theme_bloc.dart';
import 'package:raw_material_management/features/inventory/presentation/pages/material_management_page.dart';
import 'package:raw_material_management/features/composition/presentation/pages/composition_management_page.dart';
import 'package:raw_material_management/features/manufacturing/presentation/pages/manufacturing_log_page.dart';
import 'package:raw_material_management/features/analysis/presentation/pages/analysis_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: size.height * 0.25,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Raw Material Management',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.white
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              // Theme Toggle Button
              BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, state) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        state.themeMode == ThemeMode.dark
                            ? Icons.light_mode
                            : Icons.dark_mode,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        context.read<ThemeBloc>().add(ToggleTheme());
                      },
                    ),
                  );
                },
              ),
              // Logout Button
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildListDelegate([
                _buildMenuCard(
                  context,
                  'Material Management',
                  Icons.inventory_2,
                  'Manage your raw materials inventory',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MaterialManagementPage(),
                    ),
                  ),
                ),
                _buildMenuCard(
                  context,
                  'Composition Management',
                  Icons.science,
                  'Create and manage material compositions',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CompositionManagementPage(),
                    ),
                  ),
                ),
                _buildMenuCard(
                  context,
                  'Manufacturing Log',
                  Icons.history,
                  'Track manufacturing processes',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManufacturingLogPage(),
                    ),
                  ),
                ),
                _buildMenuCard(
                  context,
                  'Analysis',
                  Icons.analytics,
                  'View detailed analytics',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AnalysisPage(),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    String subtitle,
    VoidCallback onTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Hero(
      tag: title,
      child: Card(
        elevation: 8,
        shadowColor: colorScheme.shadow.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.surface,
                  colorScheme.surface.withOpacity(0.95),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Decorative elements
                Positioned(
                  right: -10,
                  top: -10,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary.withOpacity(0.1),
                    ),
                  ),
                ),
                // Main content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          size: 32,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Hover effect
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: onTap,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme.primary.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 