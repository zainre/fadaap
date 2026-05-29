class StoryModel {
  final String id;
  final String userId;
  final String mediaUrl;
  final bool isVideo;
  final int viewsCount;      // ✨ جديد: عدد المشاهدات
  final int likesCount;      // ✨ جديد: عدد الإعجابات
  final List<String>? aiTags; // 🤖 جديد: علامات (Tags) يولدها سديم تلقائياً للصورة
  final DateTime expiresAt;
  final DateTime createdAt;

  StoryModel({
    required this.id,
    required this.userId,
    required this.mediaUrl,
    this.isVideo = false,
    this.viewsCount = 0,
    this.likesCount = 0,
    this.aiTags,
    required this.expiresAt,
    required this.createdAt,
  });

  // تحويل البيانات القادمة من قاعدة البيانات إلى كائن برمجي
  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      mediaUrl: json['media_url'] as String,
      isVideo: json['is_video'] ?? false,
      viewsCount: json['views_count'] ?? 0,
      likesCount: json['likes_count'] ?? 0,
      // جلب العلامات الذكية إن وجدت، وإلا نعطي قائمة فارغة
      aiTags: json['ai_tags'] != null ? List<String>.from(json['ai_tags']) : [],
      expiresAt: DateTime.parse(json['expires_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // تحويل الكائن البرمجي إلى Map لرفعه إلى قاعدة البيانات
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'media_url': mediaUrl,
      'is_video': isVideo,
      'views_count': viewsCount,
      'likes_count': likesCount,
      'ai_tags': aiTags,
      'expires_at': expiresAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
