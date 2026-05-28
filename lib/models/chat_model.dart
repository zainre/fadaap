class ChatModel {
  final String id;
  final List<String> participantIds;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String? aiChatSummary; // تلخيص ذكي للمحادثة الطويلة لتذكير المستخدم بأبرز النقاط

  ChatModel({
    required this.id,
    required this.participantIds,
    required this.lastMessage,
    required this.lastMessageTime,
    this.aiChatSummary,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as String,
      participantIds: List<String>.from(json['participant_ids'] ?? []),
      lastMessage: json['last_message'] ?? '',
      lastMessageTime: DateTime.parse(json['last_message_time'] as String),
      aiChatSummary: json['ai_chat_summary'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participant_ids': participantIds,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime.toIso8601String(),
      'ai_chat_summary': aiChatSummary,
    };
  }
}