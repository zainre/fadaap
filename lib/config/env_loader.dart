import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvLoader {
  // دالة تهيئة تحميل ملف البيئة
  static Future<void> init() async {
    await dotenv.load(fileName: ".env");
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
}