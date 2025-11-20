import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:rpl_notepad_fe/core/widgets/no_connection_page.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, PlatformDispatcher, kDebugMode;
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:rpl_notepad_fe/core/di/injection.dart';
import 'package:rpl_notepad_fe/core/network/api_service.dart';
import 'package:rpl_notepad_fe/core/router/navigation_service.dart';
import 'package:rpl_notepad_fe/core/services/auth_service.dart';
import 'package:rpl_notepad_fe/core/services/notification_service.dart';
import 'package:rpl_notepad_fe/core/widgets/splash_screen.dart';
import 'package:rpl_notepad_fe/core/widgets/not_found_page.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/view/login_page.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/view/register_page.dart';
import 'package:rpl_notepad_fe/features/discussion/presentation/view/discussion_page.dart';
import 'package:rpl_notepad_fe/features/discussion/presentation/viewmodel/discussion_viewmodel.dart';
import 'package:rpl_notepad_fe/features/home/presentation/view/home_page.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/view_models/login_view_model.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/view_models/register_view_model.dart';
import 'package:rpl_notepad_fe/features/admin/presentation/view/admin_dashboard_page.dart';
import 'package:rpl_notepad_fe/features/admin/presentation/view/add_class_page.dart';
import 'package:rpl_notepad_fe/features/admin/presentation/viewmodel/add_class_view_model.dart';

// CORS
void enableCorsForWeb() {
  if (kIsWeb) {}
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Crashlytics
  if (!kIsWeb) {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      !kDebugMode,
    );
  }

  // Enable CORS for web
  enableCorsForWeb();

  // Use path-based URLs
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  try {
    // Initialize dependencies first
    await setupDependencyInjection();

    // Verify critical dependencies
    final getIt = GetIt.instance;
    await AuthService.init();

    // Initialize notifications
    if (!kIsWeb) {
      await NotificationService.instance.init();
      await NotificationService.instance.requestPermissions();
    }

    if (kIsWeb) {
      runApp(const MyApp());
      return;
    }

    // Alice (HTTP Inspector)
    final alice = getIt<ApiService>().alice;
    alice.setNavigatorKey(navigatorKey);

    // Get initial connectivity state
    final connectivityResult = await Connectivity().checkConnectivity();

    runApp(
      StreamBuilder<List<ConnectivityResult>>(
        stream: Connectivity().onConnectivityChanged,
        initialData: connectivityResult,
        builder: (context, snapshot) {
          final isDisconnectedByType =
              snapshot.data?.contains(ConnectivityResult.none) ?? true;

          if (isDisconnectedByType) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: NoConnectionPage(),
            );
          }

          return FutureBuilder<bool>(
            future: _hasInternet(),
            builder: (context, internetSnap) {
              final reachabilityChecked =
                  internetSnap.connectionState == ConnectionState.done;
              final reachable = internetSnap.data == true;

              if (reachabilityChecked && !reachable) {
                return const MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: NoConnectionPage(),
                );
              }

              return const MyApp();
            },
          );
        },
      ),
    );
  } catch (e, s) {
    if (!kIsWeb) {
      await FirebaseCrashlytics.instance.recordError(e, s, fatal: true);
    }
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Failed to initialize the app. Please try again later.',
            ),
          ),
        ),
      ),
    );
  }
}

Future<bool> _hasInternet() async {
  try {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 3),
      ),
    );
    final res = await dio.get('https://www.gstatic.com/generate_204');
    return res.statusCode == 204 || res.statusCode == 200;
  } catch (_) {
    return false;
  }
}

class AppWithDebug extends StatelessWidget {
  final Widget child;

  const AppWithDebug({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              getIt<ApiService>().alice.showInspector();
            },
            backgroundColor: Colors.black,
            mini: true,
            child: const Icon(Icons.bug_report, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<LoginViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<RegisterViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<DiscussionViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<AddClassViewModel>()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'RPL Notepad',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        builder: (context, child) {
          final content = child ?? const SizedBox.shrink();
          return AppWithDebug(child: content);
        },
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (_) => const NotFoundPage(),
          settings: settings,
        ),
        initialRoute: kIsWeb ? null : '/splash',
        onGenerateRoute: (settings) {
          final name = settings.name ?? '/login';

          if (name == '/splash') {
            return MaterialPageRoute(
              builder: (_) => const SplashScreen(),
              settings: const RouteSettings(name: '/splash'),
            );
          }

          if (!AuthService.isLoggedIn) {
            switch (name) {
              case '/register':
                return MaterialPageRoute(
                  builder: (_) => const RegisterPage(),
                  settings: settings,
                );
              case '/login':
                getIt<LoginViewModel>().reset();
                return MaterialPageRoute(
                  builder: (_) => const LoginPage(),
                  settings: settings,
                );
              default:
                const protected = <String>{
                  '/home',
                  '/discussion',
                  '/admin',
                  '/admin/add-class',
                };
                if (protected.contains(name)) {
                  getIt<LoginViewModel>().reset();
                  return MaterialPageRoute(
                    builder: (_) => const LoginPage(),
                    settings: const RouteSettings(name: '/login'),
                  );
                }
                return null;
            }
          }

          final isAdmin = AuthService.isAdmin;

          if (!isAdmin && (name == '/admin' || name.startsWith('/admin/'))) {
            return MaterialPageRoute(
              builder: (_) => const HomePage(),
              settings: const RouteSettings(name: '/home'),
            );
          }

          if (isAdmin && name == '/home') {
            return MaterialPageRoute(
              builder: (_) => const AdminDashboardPage(),
              settings: const RouteSettings(name: '/admin'),
            );
          }

          switch (name) {
            case '/login':
              getIt<LoginViewModel>().reset();
              return MaterialPageRoute(
                builder: (_) => const LoginPage(),
                settings: const RouteSettings(name: '/login'),
              );
            case '/register':
              return MaterialPageRoute(
                builder: (_) => const RegisterPage(),
                settings: const RouteSettings(name: '/register'),
              );
            case '/home':
              return MaterialPageRoute(
                builder: (_) => const HomePage(),
                settings: settings,
              );
            case '/discussion':
              return MaterialPageRoute(
                builder: (_) => const DiscussionPage(),
                settings: settings,
              );
            case '/admin':
              return MaterialPageRoute(
                builder: (_) => const AdminDashboardPage(),
                settings: settings,
              );
            case '/admin/add-class':
              return MaterialPageRoute(
                builder: (_) => const AddClassPage(),
                settings: settings,
              );
            default:
              return null;
          }
        },
      ),
    );
  }
}
