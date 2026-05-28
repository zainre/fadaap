import 'package:flutter/material.dart';
import 'config/env_loader.dart';
import 'config/supabase_config.dart';
import 'config/gemini_config.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() async {
  // التأكد من تهيئة واجهات فلاتر البرمجية قبل تشغيل أي كود خلفي
  WidgetsFlutterBinding.ensureInitialized();

  // تشغيل وتهيئة الإعدادات الثلاثية المتكاملة
  await EnvLoader.init();
  await SupabaseConfig.init();
  GeminiConfig.init();

  runApp(const SadeemApp());
}

class SadeemApp extends StatelessWidget {
  const SadeemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // تطبيق الثيم الأسود والأبيض الموحد
      home: const SplashScreen(),
    );
  }
}

// الشاشة الترحيبية الأولى للتطبيق المليئة بالأنيميشن الفخم
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

  // دالة محاكاة وقت التحميل ثم الانتقال السلس
  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      // لاحقاً هنا سنقوم بالتوجيه إلى شاشة تسجيل الدخول login_screen
      // حالياً سيبقى في الشاشة لحين بناء شاشات الـ Auth في الخطوة القادمة
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
            // النص الرئيسي محاط بأنيميشن تكبير وتلاشي مع وميض فضي فخم
            Text(
              AppConstants.appName,
              style: const TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.w900,
                letterSpacing: 6,
                color: Colors.white,
              ),
            )
            .animate()
            .fadeIn(duration: 1000.ms)
            .scale(begin: const Offset(0.7, 0.7), end: const Offset(1.0, 1.0), duration: 1000.ms, curve: Curves.easeOutBack)
            .then()
            .shimmer(duration: 1500.ms, color: Colors.grey.shade700),

            const SizedBox(height: 30),

            // مؤشر تحميل خطي مخصص باللون الأبيض يظهر بأنيميشن تدريجي ناعم
            SizedBox(
              width: 120,
              child: const LinearProgressIndicator(
                backgroundColor: Color(0xFF1A1A1A),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
              .animate()
              .fadeIn(delay: 600.ms, duration: 800.ms),
            ),
          ],
        ),
      ),
    );
  }
}