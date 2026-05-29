import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../config/supabase_config.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatModel> _chats = [];
  List<MessageModel> _currentMessages = [];
  bool _isLoading = false;
  RealtimeChannel? _messagesSubscription;

  List<ChatModel> get chats => _chats;
  List<MessageModel> get currentMessages => _currentMessages;
  bool get isLoading => _isLoading;

  final _supabase = SupabaseConfig.client;

  Future<void> fetchUserChats(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _supabase
          .from('chats')
          .stream(primaryKey: ['id'])
          .order('updated_at', ascending: false) // Assuming updated_at aligns with lastMessageTime in DB
          .listen((data) {
            _chats = data
                .where((chat) =>
                    (chat['participant_ids'] as List).contains(userId))
                .map((chat) => ChatModel.fromJson(chat))
                .toList();
            notifyListeners();
          });
    } catch (e) {
      debugPrint("Error fetching chats: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMessages(String chatId) async {
    _isLoading = true;
    notifyListeners();

    await _messagesSubscription?.unsubscribe();

    try {
      _supabase
          .from('messages')
          .stream(primaryKey: ['id'])
          .eq('chat_id', chatId)
          .order('created_at', ascending: true)
          .listen((data) {
            _currentMessages =
                data.map((msg) => MessageModel.fromJson(msg)).toList();
            notifyListeners();
          });
    } catch (e) {
      debugPrint("Error fetching messages: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(MessageModel message) async {
    try {
      await _supabase.from('messages').insert(message.toJson());

      await _supabase.from('chats').update({
        'last_message': message.content.isEmpty ? 'Audio Message' : message.content,
        'updated_at': message.createdAt.toIso8601String(),
        'last_message_sender_id': message.senderId,
      }).eq('id', message.chatId);
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }

  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      await _supabase
          .from('messages')
          .update({'is_read': true})
          .eq('chat_id', chatId)
          .neq('sender_id', userId)
          .eq('is_read', false);
    } catch (e) {
      debugPrint("Error marking messages as read: $e");
    }
  }

  @override
  void dispose() {
    _messagesSubscription?.unsubscribe();
    super.dispose();
  }
}
