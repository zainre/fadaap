import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/gemini_config.dart';

class SadeemProvider extends ChangeNotifier {
  bool _isThinking = false;
  bool get isThinking => _isThinking;

  // استخدام النماذج التي هيأناها في ملف الإعدادات
  final GenerativeModel _aiModel = GeminiConfig.model;
  final GenerativeModel _visionModel = GeminiConfig.visionModel; // 👁️ نموذج الرؤية

  Future<String> askSadeem(String question) async {
    _setThinking(true);
    try {
      // الهوية محقونة مسبقاً في Config، لا داعي لتكرارها هنا!
      final content = [Content.text(question)];
      final response = await _aiModel.generateContent(content);
      return response.text ?? 'عذراً، تشتتت أفكاري للحظة، هل يمكنك إعادة السؤال؟';
    } catch (e) {
      return 'حدث خطأ في الاتصال بعقلي المدبر. تأكد من الإنترنت.';
    } finally {
      _setThinking(false);
    }
  }

  Future<String> generateSmartCaption(String topic) async {
    _setThinking(true);
    try {
      final prompt = 'اكتب وصفاً جذاباً واحترافياً لمنشور على وسائل التواصل الاجتماعي حول "$topic". أضف 5 هاشتاجات مناسبة في النهاية. لا تضف أي مقدمات، فقط الوصف.';
      final content = [Content.text(prompt)];
      final response = await _aiModel.generateContent(content);
      return response.text ?? 'لم أتمكن من توليد الوصف، حاول مجدداً.';
    } catch (e) {
      return 'حدث خطأ في الاتصال بالذكاء الاصطناعي.';
    } finally {
      _setThinking(false);
    }
  }

  Future<String> summarizeChat(List<String> messages) async {
    if (messages.isEmpty) return 'لا توجد رسائل لتلخيصها.';
    _setThinking(true);
    try {
      final chatText = messages.join('\n');
      final prompt = 'قم بتلخيص هذه المحادثة في سطرين فقط وبشكل مفيد:\n$chatText';
      final content = [Content.text(prompt)];
      final response = await _aiModel.generateContent(content);
      return response.text ?? 'تعذر التلخيص.';
    } catch (e) {
      return 'حدث خطأ أثناء التلخيص.';
    } finally {
      _setThinking(false);
    }
  }

  Future<String> analyzeSentiment(String comment) async {
    try {
      final prompt = 'حلل المشاعر في هذا التعليق: "$comment". أجب بكلمة واحدة فقط: إيجابي، سلبي، أو محايد.';
      final content = [Content.text(prompt)];
      final response = await _aiModel.generateContent(content);
      return response.text?.trim() ?? 'محايد';
    } catch (e) {
      return 'محايد';
    }
  }

  // ✨ ميزة جديدة وخرافية: تحليل الصور بالذكاء الاصطناعي لاستخراج الهاشتاجات!
  Future<List<String>> analyzeImageForTags(DataPart imagePart) async {
    _setThinking(true);
    try {
      final prompt = TextPart("حلل هذه الصورة واستخرج منها 5 كلمات مفتاحية (هاشتاجات) دقيقة باللغة العربية. افصل بينها بفاصلة فقط بدون علامة #.");
      final response = await _visionModel.generateContent([
        Content.multi([prompt, imagePart])
      ]);
      
      final text = response.text ?? '';
      if (text.isNotEmpty) {
        return text.split(',').map((e) => e.trim()).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Vision AI Error: $e");
      return [];
    } finally {
      _setThinking(false);
    }
  }

  void _setThinking(bool value) {
    _isThinking = value;
    notifyListeners();
  }
}
