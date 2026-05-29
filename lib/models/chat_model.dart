class ChatModel {
  final String id;
  final List<String> participantIds;
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
      id: json['id'] as String,
      participantIds: List<String>.from(json['participant_ids'] ?? []),
      lastMessage: json['last_message'] ?? '',
      lastMessageSenderId: json['last_message_sender_id'] as String?,
      lastMessageTime: DateTime.parse(json['last_message_time'] as String),
      unreadCount: json['unread_count'] ?? 0,
      isPinned: json['is_pinned'] ?? false,
      aiChatSummary: json['ai_chat_summary'] as String?,
      aiChatMood: json['ai_chat_mood'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participant_ids': participantIds,
      'last_message': lastMessage,
      'last_message_sender_id': lastMessageSenderId,
      'last_message_time': lastMessageTime.toIso8601String(),
      'unread_count': unreadCount,
      'is_pinned': isPinned,
      'ai_chat_summary': aiChatSummary,
      'ai_chat_mood': aiChatMood,
    };
  }
}
