import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class RealtimeService {
  static final _supabase = SupabaseConfig.client;

  // الاستماع المباشر للرسائل الجديدة في محادثة معينة
  static RealtimeChannel listenToChat(String chatId, Function(Map<String, dynamic>) onNewMessage) {
    return _supabase
        .channel('public:messages:chat_id=eq.$chatId')
        .on(
          RealtimeListenTypes.postgresChanges,
          ChannelFilter(
            event: 'INSERT', 
            schema: 'public', 
            table: 'messages', 
            filter: 'chat_id=eq.$chatId'
          ),
          (payload, [ref]) {
            onNewMessage(payload['new']);
          },
        )
        .subscribe();
  }

  // الاستماع اللحظي للإشعارات الخاصة بالمستخدم (إعجابات، تعليقات، متابعات)
  static RealtimeChannel listenToNotifications(String userId, Function(Map<String, dynamic>) onNotification) {
    return _supabase
        .channel('public:notifications:user_id=eq.$userId')
        .on(
          RealtimeListenTypes.postgresChanges,
          ChannelFilter(
            event: 'INSERT', 
            schema: 'public', 
            table: 'notifications', 
            filter: 'user_id=eq.$userId'
          ),
          (payload, [ref]) {
            onNotification(payload['new']);
          },
        )
        .subscribe();
  }
}