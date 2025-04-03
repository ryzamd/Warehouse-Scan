import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:warehouse_scan/core/constants/app_colors.dart';
import 'package:warehouse_scan/core/constants/app_routes.dart';
import 'package:warehouse_scan/core/services/exit_confirmation_service.dart';
import 'package:warehouse_scan/features/auth/login/domain/entities/user_entity.dart';
import 'package:warehouse_scan/features/auth/login/presentation/pages/login_page.dart';
import 'core/di/dependencies.dart' as di;

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
      initialRoute: AppRoutes.login,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.login:
            return MaterialPageRoute(builder: (_) => const LoginPage());
          case AppRoutes.processing:
            // Temporary placeholder route
            final args = settings.arguments as UserEntity;
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: Text('Processing - ${args.name}')),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Welcome, ${args.name}!'),
                      const SizedBox(height: 20),
                      Text('User ID: ${args.userId}'),
                      const SizedBox(height: 20),
                      Text('Role: ${args.role.toString()}'),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          default:
            return MaterialPageRoute(builder: (_) => const LoginPage());
        }
      },
    );
  }
}