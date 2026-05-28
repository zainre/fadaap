import 'dart:math';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'env_loader.dart';

class GeminiConfig {
  static GenerativeModel? _model;

  // دالة تهيئة ذكاء سديم الاصطناعي مع اختيار مفتاح عشوائي لتوزيع الضغط
  static void init() {
    final keys = EnvLoader.geminiKeys;
    if (keys.isNotEmpty) {
      // اختيار مفتاح عشوائي من المفاتيح الأربعة
      final randomKey = keys[Random().nextInt(keys.length)];
      
      _model = GenerativeModel(
        model: 'gemini-3.5-flash',
        apiKey: randomKey,
      );
    }
  }

  // جلب الكائن الجاهز للذكاء الاصطناعي للاستخدام المباشر
  static GenerativeModel get model {
    if (_model == null) {
      throw Exception('لم يتم تهيئة نموذج Gemini بشكل صحيح. تحقق من المفاتيح.');
    }
    return _model!;
  }
}