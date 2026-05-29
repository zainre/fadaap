import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class ImageGenerationService {
  // ⚠️ REPLACE WITH YOUR OPENAI API KEY
  static const String _openAiApiKey = 'YOUR_OPENAI_API_KEY';
  static const String _endpoint = 'https://api.openai.com/v1/images/generations';

  static Future<String?> generateCinematicImage(String prompt) async {
    try {
      if (_openAiApiKey == 'YOUR_OPENAI_API_KEY') {
        developer.log('⚠️ الرجاء إضافة مفتاح OpenAI API الفعلي.', name: 'ImageGenerationService');
        // Return a placeholder or mock image if key is missing during dev
        return 'https://via.placeholder.com/1024x1024.png?text=OpenAI+Key+Required';
      }

      final enhancedPrompt = "Cinematic, highly detailed, photorealistic: $prompt";

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAiApiKey',
        },
        body: jsonEncode({
          'model': 'dall-e-3',
          'prompt': enhancedPrompt,
          'n': 1,
          'size': '1024x1024',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final imageUrl = data['data'][0]['url'] as String;
        developer.log('✅ تم توليد الصورة بنجاح.', name: 'ImageGenerationService');
        return imageUrl;
      } else {
        developer.log('❌ فشل توليد الصورة: ${response.statusCode} - ${response.body}', name: 'ImageGenerationService');
        return null;
      }
    } catch (e) {
      developer.log('❌ خطأ في الاتصال بـ OpenAI', name: 'ImageGenerationService', error: e);
      return null;
    }
  }
}
