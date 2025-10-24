import 'package:flutter/material.dart';
import 'package:hrgo_app/features/login/domain/auth_service.dart';
import 'package:hrgo_app/features/login/login_screen.dart';
import 'package:hrgo_app/features/main_navigation_screen/bottom_main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthApiService();
  final hasSession = await authService.checkSession();

  runApp(MainApp(isLoggedIn: hasSession));
}

class MainApp extends StatelessWidget {
  final bool isLoggedIn;

  const MainApp({required this.isLoggedIn, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? BottomMainNavigationScreen() : LoginScreen(),
    );
  }
}
