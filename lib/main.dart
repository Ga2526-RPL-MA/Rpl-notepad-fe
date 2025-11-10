import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/usecases/add_sub_answer_usecase.dart';
import 'package:rpl_notepad_fe/core/di/injection.dart';
import 'package:rpl_notepad_fe/core/network/api_service.dart';
import 'package:rpl_notepad_fe/core/services/auth_service.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/view/login_page.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/view/register_page.dart';
import 'package:rpl_notepad_fe/features/home/presentation/view/home_page.dart';
import 'package:rpl_notepad_fe/features/discussion/presentation/view/discussion_page.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/view_models/login_view_model.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/view_models/register_view_model.dart';
import 'package:rpl_notepad_fe/features/discussion/presentation/viewmodel/discussion_viewmodel.dart';

//Cors
void enableCorsForWeb() {
  if (kIsWeb) {}
}

// Global key for navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable CORS for web
  enableCorsForWeb();

  try {
    // Initialize dependencies first
    await setupDependencyInjection();
    
    // Verify critical dependencies
    final getIt = GetIt.instance;
    if (!getIt.isRegistered<AddSubAnswerUsecase>()) {
      throw Exception('AddSubAnswerUsecase not registered!');
    }
    await AuthService.init();
    
    //  Alice 
    final alice = getIt<ApiService>().alice;
    alice.setNavigatorKey(navigatorKey);
    
    runApp(const MyApp());
  } catch (e, stackTrace) {
    print('Error during app initialization: $e');
    print('Stack trace: $stackTrace');
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
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'RPL Notepad',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Inter',
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return AppWithDebug(child: child!);
        },
        home: _getLandingPage(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const HomePage(),
          '/discussion': (context) => const DiscussionPage(),
        },
      ),
    );
  }

  Widget _getLandingPage() {
    // Check if user is already authenticated
    if (AuthService.isLoggedIn) {
      return FutureBuilder(
        future: Future.delayed(Duration.zero),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Navigate to home
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed('/home');
            });
          }
          // Show a loading indicator or empty container while navigating
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      );
    }
    return const LoginPage();
  }
}
