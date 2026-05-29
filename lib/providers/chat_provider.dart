import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../config/supabase_config.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatModel> _chats = [];
  List<MessageModel> _currentMessages = [];
  bool _isLoading = false;
  RealtimeChannel? _messagesSubscription; // ✨ اشتراك البث الحي

  List<ChatModel> get chats => _chats;
  List<MessageModel> get currentMessages => _currentMessages;
  bool get isLoading => _isLoading;

  final _supabase = SupabaseConfig.client;

  Future<void> fetchUserChats(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      // ✨ جلب فوري للمحادثات
      _supabase.from('chats').stream(primaryKey: ['id']).order('last_message_time', ascending: false).listen((data) {
        _chats = data.where((chat) => (chat['participant_ids'] as List).contains(userId)).map((chat) => ChatModel.fromJson(chat)).toList();
        notifyListeners();
      });
    } catch (e) {
      debugPrint("Error fetching chats: $e");
    } finally {
      _isLoading = false;
    }
  }

  Future<void> fetchMessages(String chatId) async {
    _isLoading = true;
    notifyListeners();
    
    // إلغاء الاشتراك القديم إن وجد لمنع التداخل
    await _messagesSubscription?.unsubscribe();

    try {
      // ✨ بث حي (Realtime) للرسائل! ستظهر الرسالة فوراً بدون تحديث الشاشة
      _supabase.from('messages').stream(primaryKey: ['id']).eq('chat_id', chatId).order('created_at', ascending: true).listen((data) {
        _currentMessages = data.map((msg) => MessageModel.fromJson(msg)).toList();
        notifyListeners();
      });
    } catch (e) {
      debugPrint("Error fetching messages: $e");
    } finally {
      _isLoading = false;
    }
  }

  Future<void> sendMessage(MessageModel message) async {
    try {
      await _supabase.from('messages').insert(message.toJson());
      
      await _supabase.from('chats').update({
        'last_message': message.content,
        'last_message_time': message.createdAt.toIso8601String(),
      }).eq('id', message.chatId);
      
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }
}
