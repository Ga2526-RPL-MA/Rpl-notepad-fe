import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpl_notepad_fe/core/network/api_sevice.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/view/login_page.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/view_models/login_view_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final apiService = ApiService();
  runApp(MyApp(apiService: apiService));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.apiService});
  final ApiService apiService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
      ],
      child: MaterialApp(
        title: 'RPL Notepad',
        navigatorKey: apiService.alice.getNavigatorKey(),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const LoginPage(),
      ),
    );
  }
}