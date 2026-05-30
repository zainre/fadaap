class UserModel {
  final String id;
  final String username;
  final String fullName;
  final String email;
  final String avatarUrl;
  final String bio;
  final int followersCount; // ✨ جديد: عدد المتابعين
  final int followingCount; // ✨ جديد: عدد المتابَعين
  final bool isVerified; // ✨ جديد: علامة التوثيق للحسابات المميزة
  final bool isOnline; // ✨ جديد: حالة الاتصال للدردشة
  final DateTime? lastSeen; // ✨ جديد: آخر ظهور
  final String?
      aiAvatarUrl; // 🤖 جديد: نسخة فنية من صورتك مولدة بالذكاء الاصطناعي
  final String? aiInterestsSummary;
  final bool developerBadge; // 👑 جديد: وسام المطور الآمن (Easter Egg)
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.avatarUrl,
    required this.bio,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isVerified = false,
    this.isOnline = true,
    this.lastSeen,
    this.aiAvatarUrl,
    this.aiInterestsSummary,
    this.developerBadge = false,
    required this.createdAt,
  });

  // تحويل البيانات القادمة من Supabase (Map) إلى كائن برمجى (Object)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      followersCount: json['followers_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      isVerified: json['is_verified'] as bool? ?? false,
      isOnline: json['is_online'] as bool? ?? false,
      lastSeen: json['last_seen'] != null
          ? DateTime.tryParse(json['last_seen'].toString())
          : null,
      aiAvatarUrl: json['ai_avatar_url'] as String?,
      aiInterestsSummary: json['ai_interests_summary'] as String?,
      // 🔒 التعديل الأمني: القيمة تؤخذ مباشرة من الخادم لمنع التلاعب عبر الكود المحمل على الهاتف
      developerBadge: json['developer_badge'] as bool? ?? false,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

  // تحويل الكائن البرمجي إلى Map لرفعه إلى Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'email': email,
      'avatar_url': avatarUrl,
      'bio': bio,
      'followers_count': followersCount,
      'following_count': followingCount,
      'is_verified': isVerified,
      'is_online': isOnline,
      'last_seen': lastSeen?.toIso8601String(),
      'ai_avatar_url': aiAvatarUrl,
      'ai_interests_summary': aiInterestsSummary,
      'developer_badge': developerBadge,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
