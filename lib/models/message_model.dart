class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final bool isAiGenerated; // هل الرسالة مقتبسة أو مولدة عبر ذكاء سديم الاصطناعي؟
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.isAiGenerated,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      chatId: json['chat_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      isAiGenerated: json['is_ai_generated'] ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
      'is_ai_generated': isAiGenerated,
      'created_at': createdAt.toIso8601String(),
    };
  }
}