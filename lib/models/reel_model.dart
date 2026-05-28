class ReelModel {
  final String id;
  final String userId;
  final String videoUrl;
  final String caption;
  final List<String> aiTargetAudience; // الفئات المستهدفة للفيديو المحددة بالذكاء الاصطناعي لرفع التفاعل
  final int likesCount;
  final DateTime createdAt;

  ReelModel({
    required this.id,
    required this.userId,
    required this.videoUrl,
    required this.caption,
    required this.aiTargetAudience,
    required this.likesCount,
    required this.createdAt,
  });

  factory ReelModel.fromJson(Map<String, dynamic> json) {
    return ReelModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      videoUrl: json['video_url'] as String,
      caption: json['caption'] ?? '',
      aiTargetAudience: List<String>.from(json['ai_target_audience'] ?? []),
      likesCount: json['likes_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'video_url': videoUrl,
      'caption': caption,
      'ai_target_audience': aiTargetAudience,
      'likes_count': likesCount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}