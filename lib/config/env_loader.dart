import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;

class EnvLoader {
  // دالة تهيئة تحميل ملف البيئة مع تتبع الأخطاء
  static Future<void> init() async {
    try {
      // ✨ التعديل هنا: إضافة مسار assets/ لكي يعثر التطبيق على الملف
      await dotenv.load(fileName: "assets/.env");
      developer.log('✅ تم تحميل المفاتيح السرية بنجاح',
          name: 'Sadeem-EnvLoader');
    } catch (e) {
      developer.log('❌ خطأ قاتل: لم يتم العثور على ملف .env',
          name: 'Sadeem-EnvLoader', error: e);
      // رمي الخطأ لكي تتوقف عملية الإقلاع إذا لم توجد مفاتيح (لكي يعمل التنبيه بشكل صحيح)
      throw Exception('تعذر تحميل ملف المفاتيح السرية assets/.env');
    }
  }

  // جلب رابط Supabase
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  // جلب مفتاح الأمان لـ Supabase
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // جلب جميع مفاتيح Gemini كقائمة وتصفية الفارغ منها
  static List<String> get geminiKeys {
    // استخدمنا ميزة التحقق من التهيئة لتجنب خطأ NotInitializedError مستقبلاً
    if (!dotenv.isInitialized) return [];

    return [
      dotenv.env['GEMINI_KEY_1'] ?? '',
      dotenv.env['GEMINI_KEY_2'] ?? '',
      dotenv.env['GEMINI_KEY_3'] ?? '',
      dotenv.env['GEMINI_KEY_4'] ?? '',
    ].where((key) => key.isNotEmpty).toList();
  }

  // فحص سريع للتأكد من سلامة البيئة
  static bool get isEnvValid =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      geminiKeys.isNotEmpty;
}
