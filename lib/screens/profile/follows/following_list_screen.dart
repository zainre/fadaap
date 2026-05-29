import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/supabase_config.dart';
import '../../models/user_model.dart';
import '../../widgets/shimmer_loading.dart';
import '../user_profile_screen.dart';

class FollowingListScreen extends StatefulWidget {
  final String userId;
  final String username;

  const FollowingListScreen({super.key, required this.userId, required this.username});

  @override
  State<FollowingListScreen> createState() => _FollowingListScreenState();
}

class _FollowingListScreenState extends State<FollowingListScreen> {
  final _supabase = SupabaseConfig.client;
  List<UserModel> _following = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFollowing();
  }

  Future<void> _fetchFollowing() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase.from('follows').select('''
            following_id,
            profiles!follows_following_id_fkey (*)
          ''').eq('follower_id', widget.userId);

      setState(() {
        _following = (response as List).map((data) {
          return UserModel.fromJson(data['profiles'] as Map<String, dynamic>);
        }).toList();
      });
    } catch (e) {
      debugPrint("Error fetching following: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text('يتابعهم ${widget.username}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    ShimmerLoading(width: 50, height: 50, borderRadius: 25),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerLoading(width: 150, height: 16, borderRadius: 4),
                          SizedBox(height: 8),
                          ShimmerLoading(width: 100, height: 12, borderRadius: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : _following.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_search_outlined, size: 80, color: Colors.white24),
                      const SizedBox(height: 16),
                      const Text('لا يتابع أحداً حتى الآن.', style: TextStyle(color: Colors.white54, fontSize: 16)),
                    ],
                  ).animate().fadeIn(),
                )
              : ListView.builder(
                  itemCount: _following.length,
                  itemBuilder: (context, index) {
                    final user = _following[index];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey.shade900,
                        backgroundImage: user.avatarUrl.isNotEmpty ? NetworkImage(user.avatarUrl) : null,
                        child: user.avatarUrl.isEmpty ? const Icon(Icons.person, color: Colors.white54) : null,
                      ),
                      title: Text(user.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text(user.fullName, style: TextStyle(color: Colors.grey.shade500)),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileScreen(userId: user.id)));
                      },
                    ).animate().fadeIn(delay: (index * 50).ms);
                  },
                ),
    );
  }
}
