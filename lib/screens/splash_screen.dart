import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _navigate();
  }

  Future<void> _navigate() async {
    // Mandatory 3-second delay
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final loggedIn = await AuthService.isLoggedIn();
    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      loggedIn ? '/main' : '/register',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo placeholder (replace with asset when available)
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF00ACC1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00ACC1).withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'SpaceNews Core',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Advanced International News Portal',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 60),
              const CircularProgressIndicator(
                color: Color(0xFF00ACC1),
                strokeWidth: 2.5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
