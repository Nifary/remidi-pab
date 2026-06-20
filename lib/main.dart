import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/register_screen.dart';
import 'screens/login_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SpaceNewsApp());
}

class SpaceNewsApp extends StatelessWidget {
  const SpaceNewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpaceNews Core',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D1B2A),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D1B2A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/register': (_) => const RegisterScreen(),
        '/login': (_) => const LoginScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/welcome': (_) => const WelcomeScreen(),
        '/main': (_) => const MainScreen(),
      },
    );
  }
}
