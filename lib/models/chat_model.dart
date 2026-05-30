class ChatModel {
  final String id;
  final List<String> participantIds;
  final bool isAiChat;
  final String lastMessage;
  final String? lastMessageSenderId; // لمعرفة من أرسل آخر رسالة
  final DateTime lastMessageTime;
  final int unreadCount; // ✨ جديد: عدد الرسائل غير المقروءة
  final bool isPinned; // ✨ جديد: هل المحادثة مثبتة في الأعلى؟
  final String? aiChatSummary;
  final String?
      aiChatMood; // 🤖 جديد: تحليل سديم لمزاج المحادثة (ودية، عملية، إلخ)

  ChatModel({
    required this.id,
    required this.participantIds,
    this.isAiChat = false,
    required this.lastMessage,
    this.lastMessageSenderId,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isPinned = false,
    this.aiChatSummary,
    this.aiChatMood,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as String? ?? '',
      participantIds: List<String>.from(json['participant_ids'] ?? []),
      isAiChat: json['is_ai_chat'] as bool? ?? false,
      lastMessage: json['last_message'] as String? ?? '',
      lastMessageSenderId: json['last_message_sender_id'] as String?,
      lastMessageTime: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now() : DateTime.now(),
      unreadCount: json['unread_count'] as int? ?? 0,
      isPinned: json['is_pinned'] as bool? ?? false,
      aiChatSummary: json['ai_chat_summary'] as String?,
      aiChatMood: json['ai_chat_mood'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participant_ids': participantIds,
      'is_ai_chat': isAiChat,
      'last_message': lastMessage,
      'last_message_sender_id': lastMessageSenderId,
      'updated_at': lastMessageTime.toIso8601String(),
      'unread_count': unreadCount,
      'is_pinned': isPinned,
      'ai_chat_summary': aiChatSummary,
      'ai_chat_mood': aiChatMood,
    };
  }
}
