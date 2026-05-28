class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final String aiSentiment; // تحليل ذكاء اصطناعي للتعليق (إيجابي، سلبي، محايد)
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.aiSentiment,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      aiSentiment: json['ai_sentiment'] ?? 'neutral',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'content': content,
      'ai_sentiment': aiSentiment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}