class PostModel {
  final String id;
  final String userId;
  final String caption;
  final String imageUrl;
  final String? location; // ✨ جديد: الموقع الجغرافي للمنشور
  final String? aiDescription; // وصف تلقائي للصورة مولد بالذكاء الاصطناعي
  final List<String> aiTags; // وسم تلقائي للمنشور (Hashtags) عبر AI
  final int likesCount;
  final int commentsCount;
  final int sharesCount; // ✨ جديد: عدد المشاركات
  final int savesCount; // ✨ جديد: عدد مرات الحفظ في المفضلة
  final bool hasAiModerationFlag; // 🤖 جديد: نظام سديم لفلترة الصور غير اللائقة
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.userId,
    required this.caption,
    required this.imageUrl,
    this.location,
    this.aiDescription,
    required this.aiTags,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.savesCount = 0,
    this.hasAiModerationFlag = false,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      caption: json['caption'] ?? '',
      imageUrl: json['image_url'] as String,
      location: json['location'] as String?,
      aiDescription: json['ai_description'] as String?,
      aiTags: List<String>.from(json['ai_tags'] ?? []),
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      sharesCount: json['shares_count'] ?? 0,
      savesCount: json['saves_count'] ?? 0,
      hasAiModerationFlag: json['has_ai_moderation_flag'] ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'caption': caption,
      'image_url': imageUrl,
      'location': location,
      'ai_description': aiDescription,
      'ai_tags': aiTags,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
      'saves_count': savesCount,
      'has_ai_moderation_flag': hasAiModerationFlag,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
