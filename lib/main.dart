import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_scan/core/constants/app_colors.dart';
import 'package:warehouse_scan/core/constants/app_routes.dart';
import 'package:warehouse_scan/core/constants/enum.dart';
import 'package:warehouse_scan/core/services/exit_confirmation_service.dart';
import 'package:warehouse_scan/features/auth/login/domain/entities/user_entity.dart';
import 'package:warehouse_scan/features/auth/login/presentation/pages/login_page.dart';
import 'package:warehouse_scan/features/auth/logout/presentation/pages/profile_page.dart';
import 'package:warehouse_scan/features/process/presentation/bloc/processing_bloc.dart';
import 'package:warehouse_scan/features/process/presentation/pages/process_page.dart';
import 'package:warehouse_scan/features/warehouse_scan/presentation/bloc/warehouse_in/warehouse_in_bloc.dart';
import 'package:warehouse_scan/features/warehouse_scan/presentation/bloc/warehouse_out/warehouse_out_bloc.dart';
import 'package:warehouse_scan/features/warehouse_scan/presentation/pages/warehouse_in_page.dart';
import 'package:warehouse_scan/features/warehouse_scan/presentation/pages/warehouse_out_page.dart';
import 'core/di/dependencies.dart' as di;
import 'core/widgets/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize dependencies
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
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Pro Well',
      debugShowCheckedModeBanner: false,
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
        switch (settings.name) {
          
          case AppRoutes.login:
            return MaterialPageRoute(builder: (_) => const LoginPage());

          case AppRoutes.processing:
            final args = settings.arguments as UserEntity;
            return MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => di.sl<ProcessingBloc>(),
                child: ProcessingPage(user: args),
              ),
            );

          case AppRoutes.scan:
            final args = settings.arguments as UserEntity;
            if (args.role == UserRole.warehouseIn) {
              return MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => di.sl<WarehouseInBloc>(param1: args),
                  child: WarehouseInPage(user: args),
                ),
              );
            } else {
              return MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => di.sl<WarehouseOutBloc>(param1: args),
                  child: WarehouseOutPage(user: args),
                ),
              );
          }

          case AppRoutes.profile:
            final args = settings.arguments as UserEntity;
            return MaterialPageRoute(
              builder: (context) => ProfilePage(user: args),
          );
          
          default:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
      },
    );
  }
}