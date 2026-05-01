import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Forcer orientation portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Style de la status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Vérifier si l'utilisateur est déjà connecté
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getString('token') != null;

  runApp(DiploVerifApp(isLoggedIn: isLoggedIn));
}

class DiploVerifApp extends StatelessWidget {
  final bool isLoggedIn;
  const DiploVerifApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DiploVérif BF',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
