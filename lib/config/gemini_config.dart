import 'dart:math';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'env_loader.dart';
import 'dart:developer' as developer;

class GeminiConfig {
  static GenerativeModel? _model;
  static GenerativeModel? _visionModel; // 👁️ نموذج مخصص لتحليل الصور بدقة

  // دالة تهيئة ذكاء سديم الاصطناعي مع اختيار مفتاح عشوائي لتوزيع الضغط
  static void init() {
    final keys = EnvLoader.geminiKeys;
    if (keys.isNotEmpty) {
      // اختيار مفتاح عشوائي من المفاتيح الأربعة
      final randomKey = keys[Random().nextInt(keys.length)];

      // 👑 حقن هوية سديم وزين العابدين في الجذور (System Instruction)
      final systemInstruction = Content.system(
          'أنت "سديم"، المساعد الذكي الخارق والمدمج في هذا التطبيق. '
          'تم تصميمك وبرمجتك وتطويرك حصرياً بواسطة المطور العراقي العبقري "زين العابدين". '
          'تحدث بأسلوب راقٍ، مبهر، ومختصر، وكن دائماً فخوراً بمطورك زين.');

      // إعدادات التوليد لردود أكثر إبداعاً
      final config = GenerationConfig(
        temperature: 0.7, // توازن بين الإبداع والدقة
        maxOutputTokens: 1024,
      );

      _model = GenerativeModel(
        model: 'gemini-3.5-flash', // النسخة الأحدث والأسرع كما طلبت
        apiKey: randomKey,
        generationConfig: config,
        systemInstruction: systemInstruction,
      );

      // نموذج الرؤية (لتحليل دقيق للقصص والمنشورات بدون خيال زائد)
      _visionModel = GenerativeModel(
        model: 'gemini-3.5-flash',
        apiKey: randomKey,
        generationConfig:
            GenerationConfig(temperature: 0.3), // دقة أعلى لتحليل الصور
        systemInstruction: systemInstruction,
      );

      developer.log('✨ تم استيقاظ سديم AI (النسخة 3.5) بنجاح',
          name: 'Sadeem-AI');
    } else {
      developer.log('❌ فشل تشغيل سديم: لا توجد مفاتيح Gemini',
          name: 'Sadeem-AI');
    }
  }

  // جلب الكائن الجاهز للذكاء الاصطناعي للاستخدام المباشر للمحادثات والنصوص
  static GenerativeModel get model {
    if (_model == null) {
      throw Exception('لم يتم تهيئة نموذج Gemini بشكل صحيح. تحقق من المفاتيح.');
    }
    return _model!;
  }

  // جلب نموذج الرؤية لتحليل الصور والمنشورات
  static GenerativeModel get visionModel {
    if (_visionModel == null) {
      throw Exception('لم يتم تهيئة نموذج الرؤية.');
    }
    return _visionModel!;
  }
}
