import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;

class EnvLoader {
  // دالة تهيئة تحميل ملف البيئة مع تتبع الأخطاء
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: ".env");
      developer.log('✅ تم تحميل المفاتيح السرية بنجاح', name: 'Sadeem-EnvLoader');
    } catch (e) {
      developer.log('❌ خطأ قاتل: لم يتم العثور على ملف .env', name: 'Sadeem-EnvLoader', error: e);
    }
  }

  // جلب رابط Supabase
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  // جلب مفتاح الأمان لـ Supabase
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // جلب جميع مفاتيح Gemini كقائمة وتصفية الفارغ منها
  static List<String> get geminiKeys {
    return [
      dotenv.env['GEMINI_KEY_1'] ?? '',
      dotenv.env['GEMINI_KEY_2'] ?? '',
      dotenv.env['GEMINI_KEY_3'] ?? '',
      dotenv.env['GEMINI_KEY_4'] ?? '',
    ].where((key) => key.isNotEmpty).toList();
  }

  // ✨ فحص سريع للتأكد من سلامة البيئة
  static bool get isEnvValid => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty && geminiKeys.isNotEmpty;
}
