import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../config/supabase_config.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatModel> _chats = [];
  List<MessageModel> _currentMessages = [];
  bool _isLoading = false;

  List<ChatModel> get chats => _chats;
  List<MessageModel> get currentMessages => _currentMessages;
  bool get isLoading => _isLoading;

  final _supabase = SupabaseConfig.client;

  // جلب قائمة المحادثات للمستخدم
  Future<void> fetchUserChats(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _supabase
          .from('chats')
          .select()
          .contains('participant_ids', [userId])
          .order('last_message_time', ascending: false);
      
      _chats = (response as List).map((chat) => ChatModel.fromJson(chat)).toList();
    } catch (e) {
      debugPrint("Error fetching chats: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // جلب الرسائل لمحادثة معينة
  Future<void> fetchMessages(String chatId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .eq('chat_id', chatId)
          .order('created_at', ascending: true);
      
      _currentMessages = (response as List).map((msg) => MessageModel.fromJson(msg)).toList();
    } catch (e) {
      debugPrint("Error fetching messages: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // إرسال رسالة جديدة
  Future<void> sendMessage(MessageModel message) async {
    try {
      await _supabase.from('messages').insert(message.toJson());
      _currentMessages.add(message);
      
      // تحديث آخر رسالة في جدول المحادثات
      await _supabase.from('chats').update({
        'last_message': message.content,
        'last_message_time': message.createdAt.toIso8601String(),
      }).eq('id', message.chatId);
      
      notifyListeners();
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }
}