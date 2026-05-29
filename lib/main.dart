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
import 'providers/story_provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/sadeem_center.dart';
import 'screens/splash_screen.dart';

void main() async {
  // حماية التطبيق: شاشة خطأ فخمة بدلاً من الشاشة الرمادية/البيضاء المزعجة
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.black,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.amberAccent, size: 50),
              const SizedBox(height: 16),
              const Text('عذراً، حدث تداخل في سديم!',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(details.exceptionAsString(),
                  style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                  textDirection: TextDirection.ltr),
            ],
          ),
        ),
      ),
    );
  };

  try {
    WidgetsFlutterBinding.ensureInitialized();
    await EnvLoader.init();
    await SupabaseConfig.init();
    GeminiConfig.init();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => FeedProvider()),
          ChangeNotifierProvider(create: (_) => ReelsProvider()),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
          ChangeNotifierProvider(create: (_) => SadeemProvider()),
          ChangeNotifierProvider(create: (_) => StoryProvider()),
        ],
        child: const SadeemApp(),
      ),
    );
  } catch (e, stacktrace) {
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.black, // ثيم مظلم مريح
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Text(
                "حدث خطأ يمنع التشغيل:\n\n$e\n\n$stacktrace",
                style: const TextStyle(color: Colors.redAccent, fontSize: 14),
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
      // ✨ دعم اللغة العربية واتجاه اليمين لليسار بشكل أصلي
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}

