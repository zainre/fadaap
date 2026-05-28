class UserModel {
  final String id;
  final String username;
  final String fullName;
  final String email;
  final String avatarUrl;
  final String bio;
  final String? aiInterestsSummary; // ملخص ذكي لاهتمامات المستخدم تم إنشاؤه بواسطة AI
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.avatarUrl,
    required this.bio,
    this.aiInterestsSummary,
    required this.createdAt,
  });

  // تحويل البيانات القادمة من Supabase (Map) إلى كائن برمجى (Object)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] ?? '',
      bio: json['bio'] ?? '',
      aiInterestsSummary: json['ai_interests_summary'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
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
      'ai_interests_summary': aiInterestsSummary,
      'created_at': createdAt.toIso8601String(),
    };
  }
}