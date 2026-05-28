import '../config/supabase_config.dart';

class SupabaseService {
  static final _supabase = SupabaseConfig.client;

  // دالة مساعدة للبحث الشامل في التطبيق (تبحث عن المستخدمين)
  static Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];
    
    try {
      final response = await _supabase
          .from('users')
          .select('id, username, full_name, avatar_url')
          .ilike('username', '%$query%') // بحث غير حساس لحالة الأحرف
          .limit(10);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // دالة للتحقق من اتصال قاعدة البيانات
  static Future<bool> checkConnection() async {
    try {
      await _supabase.from('users').select('id').limit(1);
      return true;
    } catch (e) {
      return false;
    }
  }
}