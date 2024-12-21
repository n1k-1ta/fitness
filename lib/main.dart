import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitness/screens/account_screen.dart';
import 'package:fitness/screens/home_screen.dart';
import 'package:fitness/screens/login_screen.dart';
import 'package:fitness/screens/reset_password_screen.dart';
import 'package:fitness/screens/signup_screen.dart';
import 'package:fitness/screens/verify_email_screen.dart';
import 'package:fitness/services/firebase_streem.dart';
import 'package:fitness/theme.dart'; // Импортируем файл с темой

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Вынесем маршруты в отдельную переменную
    final Map<String, WidgetBuilder> routes = {
      '/': (context) => const FirebaseStream(),
      '/home': (context) => const HomeScreen(),
      '/account': (context) => const AccountScreen(),
      '/login': (context) => const LoginScreen(),
      '/signup': (context) => const SignUpScreen(),
      '/reset_password': (context) => const ResetPasswordScreen(),
      '/verify_email': (context) => const VerifyEmailScreen(),
    };

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme, // Применяем глобальную тему
      routes: routes,
      initialRoute: '/',
    );
  }
}
