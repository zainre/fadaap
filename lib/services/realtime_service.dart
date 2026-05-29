import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class RealtimeService {
  static final _supabase = SupabaseConfig.client;

  // الاستماع المباشر للرسائل الجديدة في محادثة معينة
  static RealtimeChannel listenToChat(
      String chatId, Function(Map<String, dynamic>) onNewMessage) {
    return _supabase.channel('public:messages:chat_id=eq.$chatId').onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'messages',
      filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'chat_id', value: chatId),
      callback: (payload) {
        onNewMessage(payload.newRecord);
      },
    ).subscribe();
  }

  // الاستماع اللحظي للإشعارات (إعجابات، تعليقات، متابعات)
  static RealtimeChannel listenToNotifications(
      String userId, Function(Map<String, dynamic>) onNotification) {
    return _supabase.channel('public:notifications:user_id=eq.$userId').onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'notifications',
      filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'user_id', value: userId),
      callback: (payload) {
        onNotification(payload.newRecord);
      },
    ).subscribe();
  }

  // ✨ ميزة جديدة: الاستماع لمن يكتب الآن في المحادثة (Typing Indicator)
  static RealtimeChannel listenToTyping(
      String chatId, Function(Map<String, dynamic>) onTyping) {
    final channel = _supabase.channel('typing:$chatId');
    channel.onBroadcast(
      event: 'typing',
      callback: (payload) {
        onTyping(payload);
      },
    ).subscribe();
    return channel;
  }
}
