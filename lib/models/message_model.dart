class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final String? mediaUrl; // ✨ جديد: لدعم إرسال الصور والمقاطع الصوتية
  final String? replyToMessageId; // ✨ جديد: للرد على رسالة محددة
  final bool isRead; // ✨ جديد: مؤشر قراءة الرسالة
  final bool isAiGenerated; // هل الرسالة مقتبسة أو مولدة عبر ذكاء سديم الاصطناعي؟
  final String? aiTranslation; // 🤖 جديد: ترجمة سديم التلقائية للرسائل
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    this.mediaUrl,
    this.replyToMessageId,
    this.isRead = false,
    required this.isAiGenerated,
    this.aiTranslation,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      chatId: json['chat_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      mediaUrl: json['media_url'] as String?,
      replyToMessageId: json['reply_to_message_id'] as String?,
      isRead: json['is_read'] ?? false,
      isAiGenerated: json['is_ai_generated'] ?? false,
      aiTranslation: json['ai_translation'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
      'media_url': mediaUrl,
      'reply_to_message_id': replyToMessageId,
      'is_read': isRead,
      'is_ai_generated': isAiGenerated,
      'ai_translation': aiTranslation,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
