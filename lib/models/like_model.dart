class LikeModel {
  final String id;
  final String userId;
  final String? postId;
  final String? reelId;
  final DateTime createdAt;

  LikeModel({
    required this.id,
    required this.userId,
    this.postId,
    this.reelId,
    required this.createdAt,
  });

  factory LikeModel.fromJson(Map<String, dynamic> json) {
    return LikeModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      postId: json['post_id'] as String?,
      reelId: json['reel_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'post_id': postId,
      'reel_id': reelId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}