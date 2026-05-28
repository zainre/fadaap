import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'config/env_loader.dart';
import 'config/supabase_config.dart';
import 'config/gemini_config.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';

import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/feed_provider.dart';
import 'providers/reels_provider.dart';
import 'providers/sadeem_provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/sadeem_center.dart'; // تأكد أن هذا هو اسم ملف المركز لديك

void main() async {
  // حماية التطبيق: إذا حدث خطأ يظهر على الشاشة بدلاً من الشاشة البيضاء
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await EnvLoader.init();
    await SupabaseConfig.init();
    GeminiConfig.init();

    runApp(
      // تغليف التطبيق بمزودات الحالة لتعمل كل الشاشات
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => FeedProvider()),
          ChangeNotifierProvider(create: (_) => ReelsProvider()),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
          ChangeNotifierProvider(create: (_) => SadeemProvider()),
        ],
        child: const SadeemApp(),
      ),
    );
  } catch (e, stacktrace) {
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Text(
                "حدث خطأ يمنع التشغيل:\n\n$e\n\n$stacktrace",
                style: const TextStyle(color: Colors.red, fontSize: 14),
                textDirection: TextDirection.ltr,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SadeemApp extends StatelessWidget {
  const SadeemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}

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

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      final auth = context.read<AuthProvider>();
      await auth.loadCurrentUser();

      // التوجيه الذكي: إذا مسجل دخول يذهب للرئيسية، وإلا لشاشة الدخول
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.blur_on, size: 80, color: Colors.white)
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(begin: const Offset(0.7, 0.7), end: const Offset(1.1, 1.1), duration: 2000.ms),
            const SizedBox(height: 30),
            const Text(
              'ســديــم',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                letterSpacing: 6,
                color: Colors.white,
              ),
            ).animate().fadeIn(duration: 1000.ms),
            const SizedBox(height: 30),
            const SizedBox(
              width: 120,
              child: LinearProgressIndicator(
                backgroundColor: Color(0xFF1A1A1A),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ).animate().fadeIn(delay: 600.ms, duration: 800.ms),
          ],
        ),
      ),
    );
  }
}
