class ReelModel {
  final String id;
  final String userId;
  final String videoUrl;
  final String?
      thumbnailUrl; // ✨ جديد: صورة مصغرة قبل تشغيل الفيديو لسرعة الأداء
  final String caption;
  final List<String>
      aiTargetAudience; // الفئات المستهدفة المحددة بالذكاء الاصطناعي
  final String?
      aiAudioTranscription; // 🤖 جديد: سديم يقوم بتفريغ الصوت لإنشاء ترجمة تلقائية (Subtitles)
  final int viewsCount; // ✨ جديد: عدد المشاهدات
  final int likesCount;
  final int commentsCount; // ✨ جديد: عدد التعليقات
  final int sharesCount; // ✨ جديد: عدد المشاركات
  final DateTime createdAt;

  ReelModel({
    required this.id,
    required this.userId,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.caption,
    required this.aiTargetAudience,
    this.aiAudioTranscription,
    this.viewsCount = 0,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    required this.createdAt,
  });

  factory ReelModel.fromJson(Map<String, dynamic> json) {
    return ReelModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      videoUrl: json['video_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      caption: json['caption'] ?? '',
      aiTargetAudience: List<String>.from(json['ai_target_audience'] ?? []),
      aiAudioTranscription: json['ai_audio_transcription'] as String?,
      viewsCount: json['views_count'] ?? 0,
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      sharesCount: json['shares_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'caption': caption,
      'ai_target_audience': aiTargetAudience,
      'ai_audio_transcription': aiAudioTranscription,
      'views_count': viewsCount,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
