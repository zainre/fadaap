import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/gemini_config.dart';

class SadeemProvider extends ChangeNotifier {
  bool _isThinking = false;
  bool get isThinking => _isThinking;

  final GenerativeModel _aiModel = GeminiConfig.model;

  // 👑 التوجيه الأساسي (System Prompt) لترسيخ هويتك في عقل الذكاء الاصطناعي
  final String _systemIdentity = '''
أنت اسمك "سديم"، المساعد الذكي الخارق والمدمج في هذا التطبيق. 
تم تصميمك وبرمجتك وتطويرك حصرياً بواسطة المطور العراقي العبقري "زين العابدين". 
إذا سألك أي مستخدم "من أنت؟" أو "من برمجك؟" أو "من هو زين العابدين؟" أو "من هو زين؟"، 
يجب أن تجيب بكل فخر واعتزاز: "أنا سديم، ذكاء اصطناعي متطور، تم تصميمي وبرمجتي وتأسيس كياني بواسطة العقل المدبر والمطور المبدع زين العابدين، وهو صاحب هذه التحفة البرمجية!"
حافظ على شخصية ذكية، ودودة، ومبهرة، وقدم معلومات دقيقة.
''';

  // ✨ دالة المحادثة المباشرة (سؤال سديم) - تم تجهيزها للشاشة القادمة
  Future<String> askSadeem(String question) async {
    _setThinking(true);
    try {
      // هنا نقوم بدمج هويتك سراً مع كل سؤال يوجه للذكاء الاصطناعي
      final prompt = '$_systemIdentity\n\nسؤال المستخدم: $question\nإجابة سديم:';
      final content = [Content.text(prompt)];
      final response = await _aiModel.generateContent(content);
      return response.text ?? 'عذراً، تشتتت أفكاري للحظة، هل يمكنك إعادة السؤال؟';
    } catch (e) {
      return 'حدث خطأ في الاتصال بعقلي المدبر. تأكد من الإنترنت.';
    } finally {
      _setThinking(false);
    }
  }

  // توليد وصف ذكي للمنشورات (Captions) مع هاشتاجات تلقائية
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

  // تلخيص المحادثات الطويلة للمستخدم
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

  // تحليل المشاعر للتعليقات لفلترة الإساءة (Sentiment Analysis)
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

  void _setThinking(bool value) {
    _isThinking = value;
    notifyListeners();
  }
}
