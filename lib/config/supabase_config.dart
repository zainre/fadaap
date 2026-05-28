import 'package:supabase_flutter/supabase_flutter.dart';
import 'env_loader.dart';

class SupabaseConfig {
  // دالة تهيئة الاتصال بـ Supabase عند إقلاع التطبيق
  static Future<void> init() async {
    await Supabase.initialize(
      url: EnvLoader.supabaseUrl,
      anonKey: EnvLoader.supabaseAnonKey,
    );
  }

  // اختصار لجلب العميل (Client) لإجراء العمليات بسهولة في الخدمات لاحقاً
  static SupabaseClient get client => Supabase.instance.client;
}