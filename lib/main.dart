import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_routes.dart';
import 'core/di/dependencies.dart' as di;
import 'core/localization/language_bloc.dart';
import 'core/services/exit_confirmation_service.dart';
import 'core/services/navigation_service.dart';
import 'features/auth/login/domain/entities/user_entity.dart';
import 'features/auth/login/presentation/pages/login_page.dart';
import 'features/auth/logout/presentation/pages/profile_page.dart';
import 'features/batch_scan/presentation/bloc/batch_scan_bloc.dart';
import 'features/batch_scan/presentation/pages/batch_scan_page.dart';
import 'features/inventory_check/presentation/bloc/inventory_check_bloc.dart';
import 'features/inventory_check/presentation/pages/inventory_check_page.dart';
import 'features/process/presentation/bloc/processing_bloc.dart';
import 'features/process/presentation/pages/process_page.dart';
import 'features/warehouse_menu/presentation/pages/warehouse_menu_page.dart';
import 'features/warehouse_scan/presentation/bloc/warehouse_in/warehouse_in_bloc.dart';
import 'features/warehouse_scan/presentation/bloc/warehouse_out/warehouse_out_bloc.dart';
import 'features/warehouse_scan/presentation/pages/warehouse_in_page.dart';
import 'features/warehouse_scan/presentation/pages/warehouse_out_page.dart';
import 'core/widgets/splash_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final BackButtonService _backButtonService = BackButtonService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _backButtonService.initialize(_navigatorKey.currentContext!);
    });
  }

  @override
  void dispose() {
    _backButtonService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LanguageBloc>.value(
      value: di.sl<LanguageBloc>(),
      child: BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, languageState) {
          return MaterialApp(
            navigatorKey: _navigatorKey,
            title: 'Pro Well',
            debugShowCheckedModeBanner: false,
            locale: languageState.locale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('zh', ''),
              Locale('zh', 'CN'),
              Locale('zh', 'TW'),
            ],
            theme: ThemeData(
              primaryColor: AppColors.primary,
              colorScheme: ColorScheme.fromSwatch().copyWith(
                primary: AppColors.primary,
                secondary: AppColors.accent,
              ),
              fontFamily: 'Poppins',
              scaffoldBackgroundColor: AppColors.scaffoldBackground,
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                systemOverlayStyle: SystemUiOverlayStyle.light,
              ),
            ),
            initialRoute: AppRoutes.splash,
            onGenerateRoute: (settings) {
              final args = settings.arguments as UserEntity?;
              
              switch (settings.name) {
                case AppRoutes.splash:
                  return MaterialPageRoute(builder: (_) => const SplashScreen());
                  
                case AppRoutes.login:
                  return MaterialPageRoute(builder: (_) => const LoginPage());
                  
                case AppRoutes.warehouseMenu:
                  return MaterialPageRoute(builder: (_) => WarehouseMenuPage(user: args!));
                  
                case AppRoutes.warehouseIn:
                  NavigationService().setLastWarehouseRoute(AppRoutes.warehouseIn);
                  return MaterialPageRoute(
                    settings: settings,
                    builder: (context) => BlocProvider(
                      create: (context) => di.sl<WarehouseInBloc>(param1: args),
                      child: WarehouseInPage(user: args!),
                    ),
                  );
                  
                case AppRoutes.warehouseOut:
                  NavigationService().setLastWarehouseRoute(AppRoutes.warehouseOut);
                  return MaterialPageRoute(
                    settings: settings,
                    builder: (context) => BlocProvider(
                      create: (context) => di.sl<WarehouseOutBloc>(param1: args),
                      child: WarehouseOutPage(user: args!),
                    ),
                  );
                  
                case AppRoutes.processingwarehouseIn:
                case AppRoutes.processingwarehouseOut:
                  return MaterialPageRoute(
                    settings: settings,
                    builder: (_) => BlocProvider(
                      create: (context) => di.sl<ProcessingBloc>(),
                      child: ProcessingPage(user: args!),
                    ),
                  );
                  
                case AppRoutes.profile:
                  return MaterialPageRoute(
                    settings: settings,
                    builder: (_) => ProfilePage(user: args!),
                  );

                case AppRoutes.inventoryCheck:
                  return MaterialPageRoute(
                    settings: settings,
                    builder: (context) => BlocProvider(
                      create: (context) => di.sl<InventoryCheckBloc>(param1: args),
                      child: InventoryCheckPage(user: args!),
                    ),
                  );
                  
                case AppRoutes.batchScan:
                  NavigationService().setLastWarehouseRoute(AppRoutes.batchScan);
                  return MaterialPageRoute(
                    settings: settings,
                    builder: (context) => BlocProvider(
                      create: (context) => di.sl<BatchScanBloc>(param1: args),
                      child: BatchScanPage(user: args!),
                    ),
                  );
                          
                default:
                  return MaterialPageRoute(
                    settings: settings,
                    builder: (_) => const LoginPage());
              }
            },
          );
        },
      ),
    );
  }
}