import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/gemini_config.dart';
import 'dart:developer' as developer;

class SadeemAiService {
  // ✨ استخدام النماذج المخصصة التي هيأناها مسبقاً
  static final GenerativeModel _model = GeminiConfig.model;
  static final GenerativeModel _visionModel = GeminiConfig.visionModel;

  // تحليل الصور الذكي بدقة عالية باستخدام Vision Model
  static Future<String> analyzeImage(Uint8List imageBytes, String mimeType) async {
    try {
      final prompt = TextPart('أنت مساعد ذكي في تطبيق تواصل اجتماعي اسمه "سديم". صِف هذه الصورة بدقة وبأسلوب فني جذاب في سطرين كحد أقصى.');
      final imagePart = DataPart(mimeType, imageBytes);
      
      final response = await _visionModel.generateContent([
        Content.multi([prompt, imagePart])
      ]);
      
      return response.text ?? 'صورة تم تحميلها على سديم.';
    } catch (e) {
      developer.log('❌ خطأ في تحليل الصورة', name: 'SadeemAI', error: e);
      return 'تعذر تحليل الصورة في الوقت الحالي.';
    }
  }

  // اقتراح ردود سريعة جداً داخل المحادثات
  static Future<List<String>> suggestQuickReplies(String incomingMessage) async {
    try {
      final prompt = 'المستخدم استلم هذه الرسالة: "$incomingMessage". اقترح 3 ردود قصيرة جداً (كلمة أو كلمتين فقط) للرد عليها. افصل بين الردود بفاصلة (,) فقط بدون أي نص إضافي.';
      final response = await _model.generateContent([Content.text(prompt)]);
      
      final text = response.text?.trim() ?? '';
      if (text.isEmpty) return ['👍', 'شكراً', 'تمام'];
      
      return text.split(',').map((e) => e.trim()).toList();
    } catch (e) {
      return ['👍', 'شكراً', 'تمام']; 
    }
  }

  // ✨ ميزة جديدة: فحص المحتوى لمنع الكلمات البذيئة والإساءة
  static Future<bool> isContentSafe(String text) async {
    try {
      final prompt = 'هل يحتوي هذا النص على شتائم، إساءة، أو محتوى غير لائق؟ أجب بـ "نعم" إذا كان مسيئاً، وبـ "لا" إذا كان سليماً. النص: "$text"';
      final response = await _model.generateContent([Content.text(prompt)]);
      
      return !(response.text?.contains('نعم') ?? false);
    } catch (e) {
      return true; // في حال تعطل الذكاء الاصطناعي، نمرر النص لمنع توقف التطبيق
    }
  }
}
