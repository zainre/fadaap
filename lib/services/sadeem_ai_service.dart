import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/gemini_config.dart';

class SadeemAiService {
  static final GenerativeModel _model = GeminiConfig.model;

  // تحليل الصور الذكي (ميزة لضعاف البصر أو لاستخراج الكلمات المفتاحية)
  static Future<String> analyzeImage(Uint8List imageBytes, String mimeType) async {
    try {
      final prompt = TextPart('أنت مساعد ذكي في تطبيق تواصل اجتماعي اسمه "سديم". صِف هذه الصورة بدقة وبأسلوب فني جذاب في سطرين كحد أقصى.');
      final imagePart = DataPart(mimeType, imageBytes);
      
      final response = await _model.generateContent([
        Content.multi([prompt, imagePart])
      ]);
      
      return response.text ?? 'صورة تم تحميلها على سديم.';
    } catch (e) {
      return 'تعذر تحليل الصورة في الوقت الحالي.';
    }
  }

  // اقتراح ردود سريعة جداً داخل المحادثات لتسهيل التواصل
  static Future<List<String>> suggestQuickReplies(String incomingMessage) async {
    try {
      final prompt = 'المستخدم استلم هذه الرسالة: "$incomingMessage". اقترح 3 ردود قصيرة جداً (كلمة أو كلمتين فقط) للرد عليها. افصل بين الردود بفاصلة (,) فقط بدون أي نص إضافي.';
      final response = await _model.generateContent([Content.text(prompt)]);
      
      final text = response.text?.trim() ?? '';
      if (text.isEmpty) return ['👍', 'شكراً', 'تمام'];
      
      return text.split(',').map((e) => e.trim()).toList();
    } catch (e) {
      return ['👍', 'شكراً', 'تمام']; // ردود افتراضية في حال الفشل
    }
  }
}