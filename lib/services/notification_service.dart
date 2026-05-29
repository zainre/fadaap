import 'package:uuid/uuid.dart';
import '../config/supabase_config.dart';
import 'dart:developer' as developer;

class NotificationService {
  static final _supabase = SupabaseConfig.client;

  // إرسال إشعار داخلي مع لمسة سديم الذكية
  static Future<void> sendInAppNotification({
    required String receiverId,
    required String senderId,
    required String senderName, // ✨ لمعرفة اسم المرسل وتوليد إشعار ذكي
    required String type, // 'like', 'comment', 'follow'
    String? postId,
    String? content,
  }) async {
    // لا نرسل إشعاراً للمستخدم إذا تفاعل مع منشوره الخاص
    if (receiverId == senderId) return;

    // ✨ توليد رسالة إشعار فخمة
    String smartMessage = '';
    switch (type) {
      case 'like':
        smartMessage = '✨ أُعجب $senderName بتحفتك الفنية!';
        break;
      case 'comment':
        smartMessage = '💬 ترك $senderName تعليقاً: "$content"';
        break;
      case 'follow':
        smartMessage = '🚀 بدأ $senderName بمتابعتك، رحب به!';
        break;
      default:
        smartMessage = 'لديك إشعار جديد من $senderName';
    }

    try {
      await _supabase.from('notifications').insert({
        'id': const Uuid().v4(),
        'user_id': receiverId,
        'sender_id': senderId,
        'type': type,
        'post_id': postId,
        'content': smartMessage, // ✨ حفظ الرسالة الذكية
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      developer.log('✅ تم إرسال الإشعار بنجاح إلى $receiverId',
          name: 'NotificationService');
    } catch (e) {
      developer.log('❌ خطأ في إرسال الإشعار',
          name: 'NotificationService', error: e);
    }
  }

  // تحديد الإشعار كمقروء عند الضغط عليه
  static Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true}).eq('id', notificationId);
    } catch (e) {
      developer.log('❌ خطأ في تحديث الإشعار',
          name: 'NotificationService', error: e);
    }
  }
}
