class LikeModel {
  final String id;
  final String userId;
  final String? postId;
  final String? reelId;
  final String? storyId; // ✨ جديد: لدعم الإعجاب بالقصص
  final String? commentId; // ✨ جديد: لدعم الإعجاب بالتعليقات
  final String reactionType; // ✨ جديد: نوع التفاعل (مثلاً: heart, fire, wow)
  final DateTime createdAt;

  LikeModel({
    required this.id,
    required this.userId,
    this.postId,
    this.reelId,
    this.storyId,
    this.commentId,
    this.reactionType = 'heart', // الافتراضي هو قلب
    required this.createdAt,
  });

  factory LikeModel.fromJson(Map<String, dynamic> json) {
    return LikeModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      postId: json['post_id'] as String?,
      reelId: json['reel_id'] as String?,
      storyId: json['story_id'] as String?,
      commentId: json['comment_id'] as String?,
      reactionType: json['reaction_type'] ?? 'heart',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'post_id': postId,
      'reel_id': reelId,
      'story_id': storyId,
      'comment_id': commentId,
      'reaction_type': reactionType,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
