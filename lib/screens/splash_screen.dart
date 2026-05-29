import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/sadeem_center.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      final auth = context.read<AuthProvider>();
      await auth.loadCurrentUser();

      if (auth.isAuthenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SadeemCenterScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.blur_on, size: 90, color: Colors.amberAccent)
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.1, 1.1),
                      duration: 2.seconds,
                    )
                    .shimmer(duration: 2.seconds, color: Colors.white),
                const SizedBox(height: 30),
                const Text(
                  'ســديــم',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 8,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.amberAccent, blurRadius: 15)],
                  ),
                ).animate().fadeIn(duration: 1.seconds).slideY(begin: 0.2),
                const SizedBox(height: 40),
                const SizedBox(
                  width: 140,
                  height: 3,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amberAccent),
                  ),
                ).animate().fadeIn(delay: 600.ms, duration: 800.ms),
              ],
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: const Text(
                AppConstants.zainSignature,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white38,
                  letterSpacing: 1.5,
                ),
              ).animate().fadeIn(delay: 1.seconds).shimmer(
                delay: 1.5.seconds,
                duration: 2.seconds,
                color: Colors.amberAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
