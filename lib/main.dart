import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raw_material_management/core/theme/app_theme.dart';
import 'package:raw_material_management/core/theme/theme_bloc.dart';
import 'package:raw_material_management/features/auth/presentation/pages/login_page.dart';
import 'package:raw_material_management/features/home/presentation/pages/home_page.dart';
import 'package:raw_material_management/features/inventory/data/models/material_model.dart';
import 'package:raw_material_management/features/composition/data/models/composition_model.dart';
import 'package:raw_material_management/features/manufacturing/data/models/manufacturing_log_model.dart';
import 'package:raw_material_management/features/inventory/presentation/bloc/material_bloc.dart';
import 'package:raw_material_management/features/composition/presentation/bloc/composition_bloc.dart';
import 'package:raw_material_management/features/manufacturing/presentation/bloc/manufacturing_log_bloc.dart';
import 'package:raw_material_management/features/inventory/data/repositories/material_repository_impl.dart';
import 'package:raw_material_management/features/composition/data/repositories/composition_repository_impl.dart';
import 'package:raw_material_management/features/manufacturing/data/repositories/manufacturing_log_repository_impl.dart';
import 'package:raw_material_management/core/services/hive_service.dart';
import 'package:raw_material_management/core/services/google_sheets_service.dart';
import 'package:raw_material_management/core/network/network_info.dart';
import 'package:raw_material_management/core/network/network_info_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  
  // Register Hive Adapters
  Hive.registerAdapter(MaterialModelAdapter());
  Hive.registerAdapter(CompositionModelAdapter());
  Hive.registerAdapter(MaterialCompositionAdapter());
  Hive.registerAdapter(ManufacturingLogModelAdapter());
  Hive.registerAdapter(MaterialUsageAdapter());
  
  // Open Hive Boxes
  await Hive.openBox<MaterialModel>('materials');
  await Hive.openBox<CompositionModel>('compositions');
  await Hive.openBox<ManufacturingLogModel>('manufacturing_logs');

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize NetworkInfo
  final networkInfo = NetworkInfoImpl(Connectivity());

  // Initialize Google Sheets Service
  final sheetsService = await GoogleSheetsService.create();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SharedPreferences>(
          create: (context) => prefs,
        ),
        RepositoryProvider<NetworkInfo>(
          create: (context) => networkInfo,
        ),
        RepositoryProvider<GoogleSheetsService>(
          create: (context) => sheetsService,
        ),
      ],
      child: MyApp(
        networkInfo: networkInfo,
        sheetsService: sheetsService,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final NetworkInfo networkInfo;
  final GoogleSheetsService sheetsService;

  const MyApp({
    super.key,
    required this.networkInfo,
    required this.sheetsService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Theme Bloc
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc(
            context.read<SharedPreferences>(),
          )..add(LoadTheme()),
        ),
        
        // Material Bloc
        BlocProvider<MaterialBloc>(
          create: (context) => MaterialBloc(
            MaterialRepositoryImpl(
              hiveService: HiveService<MaterialModel>(
                Hive.box<MaterialModel>('materials'),
              ),
              sheetsService: sheetsService,
              networkInfo: networkInfo,
            ),
          )..add(LoadMaterials()),
        ),
        
        // Composition Bloc
        BlocProvider<CompositionBloc>(
          create: (context) => CompositionBloc(
            CompositionRepositoryImpl(
              hiveService: HiveService<CompositionModel>(
                Hive.box<CompositionModel>('compositions'),
              ),
              sheetsService: sheetsService,
              networkInfo: networkInfo,
            ),
          )..add(LoadCompositions()),
        ),
        
        // Manufacturing Log Bloc
        BlocProvider<ManufacturingLogBloc>(
          create: (context) => ManufacturingLogBloc(
            ManufacturingLogRepositoryImpl(
              hiveService: HiveService<ManufacturingLogModel>(
                Hive.box<ManufacturingLogModel>('manufacturing_logs'),
              ),
              sheetsService: sheetsService,
              networkInfo: networkInfo,
            ),
          )..add(LoadManufacturingLogs()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Raw Material Management',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode,
            debugShowCheckedModeBanner: false,
            initialRoute: '/login',
            routes: {
              '/login': (context) => const LoginPage(),
              '/home': (context) => const HomePage(),
            },
          );
        },
      ),
    );
  }
}
