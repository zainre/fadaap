class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final int likesCount; // ✨ جديد: عدد الإعجابات بالتعليق
  final bool isPinned; // ✨ جديد: تثبيت التعليق المميز
  final String aiSentiment; 
  final String? aiSuggestedReply; // 🤖 جديد: رد مقترح من سديم لصاحب المنشور
  final bool hasAiModerationFlag; // 🤖 جديد: علم أحمر إذا كان التعليق يحتوي على إساءة
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    this.likesCount = 0,
    this.isPinned = false,
    required this.aiSentiment,
    this.aiSuggestedReply,
    this.hasAiModerationFlag = false,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      likesCount: json['likes_count'] ?? 0,
      isPinned: json['is_pinned'] ?? false,
      aiSentiment: json['ai_sentiment'] ?? 'neutral',
      aiSuggestedReply: json['ai_suggested_reply'] as String?,
      hasAiModerationFlag: json['has_ai_moderation_flag'] ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'content': content,
      'likes_count': likesCount,
      'is_pinned': isPinned,
      'ai_sentiment': aiSentiment,
      'ai_suggested_reply': aiSuggestedReply,
      'has_ai_moderation_flag': hasAiModerationFlag,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
