import 'package:supabase_flutter/supabase_flutter.dart';
import 'env_loader.dart';
import 'dart:developer' as developer;

class SupabaseConfig {
  // دالة تهيئة الاتصال بـ Supabase عند إقلاع التطبيق
  static Future<void> init() async {
    try {
      await Supabase.initialize(
        url: EnvLoader.supabaseUrl,
        anonKey: EnvLoader.supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce, // ✨ أمان عالي لتسجيل الدخول
        ),
        realtimeClientOptions: const RealtimeClientOptions(
          eventsPerSecond: 10, // ✨ تحديثات أسرع (مهم جداً لسرعة الدردشة)
        ),
      );
      developer.log('☁️ تم الاتصال بقاعدة بيانات Supabase بنجاح',
          name: 'Sadeem-DB');
    } catch (e) {
      developer.log('❌ خطأ في الاتصال بقاعدة البيانات',
          name: 'Sadeem-DB', error: e);
    }
  }

  // اختصار لجلب العميل (Client) لإجراء العمليات بسهولة في الخدمات لاحقاً
  static SupabaseClient get client => Supabase.instance.client;

  // ✨ اختصارات جديدة لتسهيل الكود في باقي الملفات
  static GoTrueClient get auth => Supabase.instance.client.auth;
  static SupabaseStorageClient get storage => Supabase.instance.client.storage;
}
