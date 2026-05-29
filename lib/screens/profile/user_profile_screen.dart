import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/supabase_config.dart';
import '../../models/user_model.dart';
import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/shimmer_loading.dart';
import 'follows/followers_list_screen.dart';
import 'follows/following_list_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() => _isLoading = true);
    try {
      final userRes = await _supabase.from('profiles').select().eq('id', widget.userId).single();
      _user = UserModel.fromJson(userRes);

      final postsRes = await _supabase.from('posts').select().eq('user_id', widget.userId).order('created_at', ascending: false);
      _posts = (postsRes as List).map((p) => PostModel.fromJson(p)).toList();

      final currentUserId = context.read<AuthProvider>().currentUser?.id;
      if (currentUserId != null) {
        final followRes = await _supabase.from('follows').select().eq('follower_id', currentUserId).eq('following_id', widget.userId).maybeSingle();
        _isFollowing = followRes != null;
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
    });

    try {
      if (_isFollowing) {
        await _supabase.from('follows').insert({'follower_id': currentUserId, 'following_id': widget.userId});
      } else {
        await _supabase.from('follows').delete().eq('follower_id', currentUserId).eq('following_id', widget.userId);
      }
    } catch (e) {
      // Revert optimistic update
      setState(() {
        _isFollowing = !_isFollowing;
      });
      debugPrint("Error toggling follow: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: Colors.amberAccent)));
    }

    if (_user == null) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: Text("المستخدم غير موجود", style: TextStyle(color: Colors.white))));
    }

    final isMe = context.read<AuthProvider>().currentUser?.id == _user!.id;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(_user!.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
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
                        child: _user!.avatarUrl.isEmpty ? const Icon(Icons.person, color: Colors.white54, size: 40) : null,
                      ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatColumn('منشورات', _posts.length.toString(), () {}),
                            _buildStatColumn('متابعون', _user!.followersCount.toString(), () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => FollowersListScreen(userId: _user!.id, username: _user!.username)));
                            }),
                            _buildStatColumn('يتابع', _user!.followingCount.toString(), () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => FollowingListScreen(userId: _user!.id, username: _user!.username)));
                            }),
                          ],
                        ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Text(_user!.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 6),
                  Text(_user!.bio, style: TextStyle(color: Colors.grey.shade300, fontSize: 14, height: 1.4)).animate().fadeIn(delay: 500.ms),
                  const SizedBox(height: 20),

                  if (!isMe)
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _toggleFollow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFollowing ? Colors.white10 : Colors.amberAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(_isFollowing ? 'إلغاء المتابعة' : 'متابعة',
                            style: TextStyle(color: _isFollowing ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ).animate().fadeIn(delay: 600.ms),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(top: 8, bottom: 90),
            sliver: _posts.isEmpty
                ? const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text('لا توجد منشورات بعد.', style: TextStyle(color: Colors.white54, fontSize: 16)),
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

  Widget _buildStatColumn(String label, String count, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(count, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
        ],
      ),
    );
  }
}
