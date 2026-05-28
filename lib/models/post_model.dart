class PostModel {
  final String id;
  final String userId;
  final String caption;
  final String imageUrl;
  final String? aiDescription; // وصف تلقائي للصورة مولد بالذكاء الاصطناعي للمكفوفين
  final List<String> aiTags;    // وسم تلقائي للمنشور (Hashtags) عبر AI
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.userId,
    required this.caption,
    required this.imageUrl,
    this.aiDescription,
    required this.aiTags,
    required this.likesCount,
    required this.commentsCount,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      caption: json['caption'] ?? '',
      imageUrl: json['image_url'] as String,
      aiDescription: json['ai_description'] as String?,
      aiTags: List<String>.from(json['ai_tags'] ?? []),
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'caption': caption,
      'image_url': imageUrl,
      'ai_description': aiDescription,
      'ai_tags': aiTags,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}