import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/gemini_config.dart';
import 'dart:developer' as developer;

class SadeemAiService {
  static final GenerativeModel _model = GeminiConfig.model;
  static final GenerativeModel _visionModel = GeminiConfig.visionModel;

  // 🖼️ تحليل الصور الذكي بدقة عالية باستخدام Vision Model
  static Future<String> analyzeImage(
      Uint8List imageBytes, String mimeType) async {
    try {
      final prompt = TextPart(
          'أنت مساعد ذكي في تطبيق تواصل اجتماعي اسمه "سديم". صِف هذه الصورة بدقة وبأسلوب فني جذاب في سطرين كحد أقصى.');
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

  // 📝 توليد تعليقات توضيحية ذكية (Smart Captions)
  static Future<String> generateSmartCaption(String imageDescription) async {
    try {
      final prompt =
          'بناءً على وصف الصورة التالي: "$imageDescription"، اكتب تعليقًا (Caption) جذابًا ومناسبًا لمنشور انستقرام أو سديم، مع تضمين 3 إلى 5 هاشتاقات ذات صلة. اجعله تفاعليًا.';
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'لحظة مميزة من سديم ✨';
    } catch (e) {
      developer.log('❌ خطأ في توليد الكابشن', name: 'SadeemAI', error: e);
      return 'لحظة مميزة من سديم ✨';
    }
  }

  // 💬 اقتراح ردود سريعة جداً داخل المحادثات
  static Future<List<String>> suggestQuickReplies(
      String incomingMessage) async {
    try {
      final prompt =
          'المستخدم استلم هذه الرسالة: "$incomingMessage". اقترح 3 ردود قصيرة جداً (كلمة أو كلمتين فقط) للرد عليها. افصل بين الردود بفاصلة (,) فقط بدون أي نص إضافي.';
      final response = await _model.generateContent([Content.text(prompt)]);

      final text = response.text?.trim() ?? '';
      if (text.isEmpty) return ['👍', 'شكراً', 'تمام'];

      return text.split(',').map((e) => e.trim()).toList();
    } catch (e) {
      return ['👍', 'شكراً', 'تمام'];
    }
  }

  // 🛡️ AI Moderation Shield: فحص المحتوى لمنع الكلمات البذيئة والإساءة
  static Future<bool> isContentToxic(String text) async {
    try {
      final prompt =
          'قم بتحليل النص التالي لتحديد ما إذا كان يحتوي على تنمر، كراهية، شتائم، أو محتوى غير لائق (Toxic). أجب بكلمة واحدة فقط: "نعم" إذا كان سامًا/مسيئًا، أو "لا" إذا كان نظيفًا ومقبولًا. النص: "$text"';
      final response = await _model.generateContent([Content.text(prompt)]);

      final result = response.text?.trim().toLowerCase() ?? 'لا';
      return result.contains('نعم');
    } catch (e) {
      developer.log('❌ خطأ في فلترة المحتوى', name: 'SadeemAI', error: e);
      return false; // Fail open to not block users if AI goes down
    }
  }

  // 🤖 AI Chat Companion: الدردشة مع مساعد سديم الشخصي
  static Stream<String> streamAiCompanionResponse(List<Content> chatHistory) async* {
    try {
      // Adding a system prompt as the first message to define the persona
      final personaContent = Content.text('أنت "سديم"، مساعد ذكي ومحبب، ورفيق للمستخدم داخل تطبيق التواصل الاجتماعي "سديم". أنت لست ذكاءً اصطناعيًا عامًا بل أنت روح التطبيق. إجاباتك يجب أن تكون دافئة، ودية، وباللغة العربية، ويفضل بلهجة عامية لطيفة قريبة للقلب. حافظ على ردود مختصرة ومفيدة.');

      final fullHistory = [personaContent, ...chatHistory];

      final responseStream = _model.generateContentStream(fullHistory);

      await for (final chunk in responseStream) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } catch (e) {
      developer.log('❌ خطأ في بث رد مساعد سديم', name: 'SadeemAI', error: e);
      yield 'عذرًا، يبدو أني أواجه مشكلة في التركيز الآن. حاول مرة أخرى! 😅';
    }
  }
}
