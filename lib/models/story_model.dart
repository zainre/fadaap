class StoryModel {
  final String id;
  final String userId;
  final String mediaUrl;
  final bool isVideo;
  final int viewsCount;      
  final int likesCount;      
  final int repliesCount;     // ✨ جديد: عدد الردود على القصة
  final List<String> viewersIds; // ✨ جديد: قائمة بمن شاهد القصة
  final bool isHighlight;     // ✨ جديد: هل القصة محفوظة في الهايلايت؟
  final List<String>? aiTags; 
  final String? aiCaption;    // 🤖 جديد: نص مقترح من سديم يكتب فوق القصة
  final DateTime expiresAt;
  final DateTime createdAt;

  StoryModel({
    required this.id,
    required this.userId,
    required this.mediaUrl,
    this.isVideo = false,
    this.viewsCount = 0,
    this.likesCount = 0,
    this.repliesCount = 0,
    this.viewersIds = const [],
    this.isHighlight = false,
    this.aiTags,
    this.aiCaption,
    required this.expiresAt,
    required this.createdAt,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      mediaUrl: json['media_url'] as String,
      isVideo: json['is_video'] ?? false,
      viewsCount: json['views_count'] ?? 0,
      likesCount: json['likes_count'] ?? 0,
      repliesCount: json['replies_count'] ?? 0,
      viewersIds: List<String>.from(json['viewers_ids'] ?? []),
      isHighlight: json['is_highlight'] ?? false,
      aiTags: json['ai_tags'] != null ? List<String>.from(json['ai_tags']) : [],
      aiCaption: json['ai_caption'] as String?,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'media_url': mediaUrl,
      'is_video': isVideo,
      'views_count': viewsCount,
      'likes_count': likesCount,
      'replies_count': repliesCount,
      'viewers_ids': viewersIds,
      'is_highlight': isHighlight,
      'ai_tags': aiTags,
      'ai_caption': aiCaption,
      'expires_at': expiresAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
