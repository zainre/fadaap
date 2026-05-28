import 'package:uuid/uuid.dart';
import '../config/supabase_config.dart';

class NotificationService {
  static final _supabase = SupabaseConfig.client;

  // إرسال إشعار داخلي في التطبيق
  static Future<void> sendInAppNotification({
    required String receiverId,
    required String senderId,
    required String type, // 'like', 'comment', 'follow'
    String? postId,
    String? content,
  }) async {
    // لا نرسل إشعاراً للمستخدم إذا تفاعل مع منشوره الخاص
    if (receiverId == senderId) return;

    try {
      await _supabase.from('notifications').insert({
        'id': const Uuid().v4(),
        'user_id': receiverId,
        'sender_id': senderId,
        'type': type,
        'post_id': postId,
        'content': content,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // طباعة الخطأ بصمت لتجنب إيقاف تجربة المستخدم
    }
  }

  // تحديد الإشعار كمقروء عند الضغط عليه
  static Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase.from('notifications').update({'is_read': true}).eq('id', notificationId);
    } catch (e) {
      // تجاهل الخطأ
    }
  }
}