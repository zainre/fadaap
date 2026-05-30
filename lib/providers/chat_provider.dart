import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../config/supabase_config.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatModel> _chats = [];
  List<MessageModel> _currentMessages = [];
  bool _isLoading = false;
  String? _errorMessage;
  RealtimeChannel? _messagesSubscription;

  // Cache for peer profiles to avoid N+1 queries
  final Map<String, Map<String, dynamic>> _peerProfiles = {};

  List<ChatModel> get chats => _chats;
  List<MessageModel> get currentMessages => _currentMessages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final _supabase = SupabaseConfig.client;

  // Get a cached profile
  Map<String, dynamic>? getPeerProfile(String userId) => _peerProfiles[userId];

  // Batch fetch profiles to solve N+1 issue
  Future<void> loadPeerProfiles(List<String> peerIds) async {
    // Filter out IDs that are already cached
    final idsToFetch = peerIds.where((id) => !_peerProfiles.containsKey(id)).toSet().toList();

    if (idsToFetch.isEmpty) return;

    final stopwatch = Stopwatch()..start();
    try {
      final response = await _supabase
          .from('profiles')
          .select('id, username, avatar_url')
          .inFilter('id', idsToFetch);

      for (var profile in response) {
        _peerProfiles[profile['id'] as String] = profile;
      }
      stopwatch.stop();
      debugPrint('⚡ [Optimized] Batch fetched ${idsToFetch.length} profiles in ${stopwatch.elapsedMilliseconds} ms');
      notifyListeners(); // Notify listeners to rebuild UI with new profiles
    } catch (e) {
      debugPrint("Error fetching peer profiles: $e");
    }
  }

  Future<void> fetchUserChats(String? userId) async {
    if (userId == null || userId.isEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _supabase
          .from('chats')
          .stream(primaryKey: ['id'])
          .order('updated_at', ascending: false) // Assuming updated_at aligns with lastMessageTime in DB
          .listen(
            (data) {
              _isLoading = false;
              _chats = data
                  .where((chat) =>
                      (chat['participant_ids'] as List).contains(userId))
                  .map((chat) => ChatModel.fromJson(chat))
                  .toList();

              // Extract unique peer IDs from loaded chats
              final Set<String> peerIds = {};
              for (var chat in _chats) {
                final peerId = chat.participantIds.firstWhere((id) => id != userId, orElse: () => userId);
                if (peerId != userId) {
                  peerIds.add(peerId);
                }
              }

              // Batch load the missing profiles
              loadPeerProfiles(peerIds.toList());

              notifyListeners();
            },
            onError: (error) {
              _isLoading = false;
              _errorMessage = "حدث خطأ أثناء جلب المحادثات.";
              debugPrint("Error in chats stream: $error");
              notifyListeners();
            },
          );
    } catch (e) {
      _isLoading = false;
      _errorMessage = "حدث خطأ أثناء الاتصال بالمحادثات.";
      debugPrint("Error fetching chats: $e");
      notifyListeners();
    }
  }

  Future<void> fetchMessages(String chatId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await _messagesSubscription?.unsubscribe();

    try {
      _messagesSubscription = _supabase
          .from('messages')
          .stream(primaryKey: ['id'])
          .eq('chat_id', chatId)
          .order('created_at', ascending: true)
          .listen(
            (data) {
              _isLoading = false;
              _currentMessages =
                  data.map((msg) => MessageModel.fromJson(msg)).toList();
              notifyListeners();
            },
            onError: (error) {
              _isLoading = false;
              _errorMessage = "حدث خطأ أثناء جلب الرسائل.";
              debugPrint("Error in messages stream: $error");
              notifyListeners();
            },
          );
    } catch (e) {
      _isLoading = false;
      _errorMessage = "حدث خطأ أثناء الاتصال بالرسائل.";
      debugPrint("Error fetching messages: $e");
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
