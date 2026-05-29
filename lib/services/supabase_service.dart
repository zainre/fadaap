import '../config/supabase_config.dart';
import 'dart:developer' as developer;

class SupabaseService {
  static final _supabase = SupabaseConfig.client;

  // ✨ الإصلاح الحرج: تم تغيير 'users' إلى 'profiles' لحل مشكلة الانهيار
  // ✨ البحث المتقدم: يبحث في اليوزر نيم والاسم الكامل معاً!
  static Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];
    
    try {
      final response = await _supabase
          .from('profiles') // كان users سابقاً وكان سيسبب خطأ
          .select('id, username, full_name, avatar_url, developer_badge')
          .or('username.ilike.%$query%,full_name.ilike.%$query%') // بحث مزدوج قوي
          .limit(10);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      developer.log('❌ خطأ في البحث عن المستخدمين', name: 'SupabaseService', error: e);
      return [];
    }
  }

  // التحقق من اتصال قاعدة البيانات
  static Future<bool> checkConnection() async {
    try {
      // فحص سريع وآمن لا يستهلك بيانات
      await _supabase.from('profiles').select('id').limit(1);
      return true;
    } catch (e) {
      developer.log('❌ فشل الاتصال بقاعدة البيانات', name: 'SupabaseService', error: e);
      return false;
    }
  }
}
