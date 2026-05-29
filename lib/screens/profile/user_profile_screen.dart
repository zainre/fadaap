import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/user_model.dart';
import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../config/supabase_config.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/glass_card.dart';
// سيتم استدعاء شاشة المحادثة هنا قريباً عند بنائها

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _supabase = SupabaseConfig.client;
  UserModel? _user;
  List<PostModel> _posts = [];
  bool _isLoading = true;
  bool _isFollowing = false;
  int _followersCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final currentUserId = context.read<AuthProvider>().currentUser?.id;
    
    try {
      // 1. جلب بيانات المستخدم الحقيقية
      final userData = await _supabase.from('profiles').select().eq('id', widget.userId).single();
      _user = UserModel.fromJson(userData);

      // 2. جلب منشوراته الحقيقية
      final postsData = await _supabase.from('posts').select().eq('user_id', widget.userId).order('created_at', ascending: false);
      _posts = (postsData as List).map((p) => PostModel.fromJson(p)).toList();

      // 3. التحقق من المتابعة إذا كان جدول follows موجوداً
      if (currentUserId != null) {
        try {
          final followCheck = await _supabase.from('follows')
              .select()
              .eq('follower_id', currentUserId)
              .eq('following_id', widget.userId)
              .maybeSingle();
          _isFollowing = followCheck != null;
          
          final followersData = await _supabase.from('follows').select('id').eq('following_id', widget.userId);
          _followersCount = (followersData as List).length;
        } catch (_) {
          // في حال لم يتم إنشاء جدول follows بعد في Supabase
        }
      }
    } catch (e) {
      debugPrint("Error fetching user profile: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFollow() async {
    final currentUserId = context.read<AuthProvider>().currentUser?.id;
    if (currentUserId == null) return;

    setState(() {
      _isFollowing = !_isFollowing;
      _followersCount += _isFollowing ? 1 : -1;
    });

    try {
      if (_isFollowing) {
        await _supabase.from('follows').insert({
          'follower_id': currentUserId,
          'following_id': widget.userId,
          'created_at': DateTime.now().toIso8601String(),
        });
      } else {
        await _supabase.from('follows')
            .delete()
            .eq('follower_id', currentUserId)
            .eq('following_id', widget.userId);
      }
    } catch (e) {
      // Revert on error
      setState(() {
        _isFollowing = !_isFollowing;
        _followersCount += _isFollowing ? 1 : -1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: Colors.amberAccent)));
    }

    if (_user == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black),
        body: const Center(child: Text('المستخدم غير موجود', style: TextStyle(color: Colors.white))),
      );
    }

    final isMe = context.read<AuthProvider>().currentUser?.id == widget.userId;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_user!.username, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (_user!.developerBadge) const SizedBox(width: 6),
            if (_user!.developerBadge) const Icon(Icons.verified, color: Colors.amberAccent, size: 18),
          ],
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: Colors.grey.shade900,
                        backgroundImage: _user!.avatarUrl.isNotEmpty ? NetworkImage(_user!.avatarUrl) : null,
                        child: _user!.avatarUrl.isEmpty ? const Icon(Icons.person, size: 40, color: Colors.white54) : null,
                      ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                      
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatColumn('منشورات', _posts.length.toString()),
                            _buildStatColumn('متابعون', _followersCount.toString()),
                            _buildStatColumn('يتابع', _user!.followingCount.toString()),
                          ],
                        ).animate().fadeIn().slideX(begin: 0.1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(_user!.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(_user!.bio.isNotEmpty ? _user!.bio : 'لا توجد نبذة.', style: TextStyle(color: Colors.grey.shade300, fontSize: 14)),
                  const SizedBox(height: 20),
                  
                  if (!isMe)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _toggleFollow,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isFollowing ? Colors.white10 : Colors.amberAccent,
                              foregroundColor: _isFollowing ? Colors.white : Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(_isFollowing ? 'إلغاء المتابعة' : 'متابعة', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // قريباً: سينتقل لشاشة الدردشة
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري فتح قناة الاتصال...')));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white10,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('مراسلة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 300.ms),
                ],
              ),
            ),
          ),
          
          SliverPadding(
            padding: const EdgeInsets.only(top: 8),
            sliver: _posts.isEmpty
                ? const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text('لا توجد منشورات بعد.', style: TextStyle(color: Colors.white54)),
                      ),
                    ),
                  )
                : SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return CachedNetworkImage(
                          imageUrl: _posts[index].imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const ShimmerLoading(width: double.infinity, height: double.infinity, borderRadius: 0),
                        ).animate().fadeIn(delay: (index * 50).ms);
                      },
                      childCount: _posts.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(count, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
      ],
    );
  }
}
