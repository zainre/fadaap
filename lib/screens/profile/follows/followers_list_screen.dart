import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/supabase_config.dart';
import '../../models/user_model.dart';
import '../../widgets/shimmer_loading.dart';
import '../user_profile_screen.dart'; // We'll navigate here when tapping a user

class FollowersListScreen extends StatefulWidget {
  final String userId;
  final String username;

  const FollowersListScreen({super.key, required this.userId, required this.username});

  @override
  State<FollowersListScreen> createState() => _FollowersListScreenState();
}

class _FollowersListScreenState extends State<FollowersListScreen> {
  final _supabase = SupabaseConfig.client;
  List<UserModel> _followers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFollowers();
  }

  Future<void> _fetchFollowers() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase.from('follows').select('''
            follower_id,
            profiles!follows_follower_id_fkey (*)
          ''').eq('following_id', widget.userId);

      setState(() {
        _followers = (response as List).map((data) {
          return UserModel.fromJson(data['profiles'] as Map<String, dynamic>);
        }).toList();
      });
    } catch (e) {
      debugPrint("Error fetching followers: $e");
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
        title: Text('متابعو ${widget.username}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
          : _followers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people_alt_outlined, size: 80, color: Colors.white24),
                      const SizedBox(height: 16),
                      const Text('لا يوجد متابعون حتى الآن.', style: TextStyle(color: Colors.white54, fontSize: 16)),
                    ],
                  ).animate().fadeIn(),
                )
              : ListView.builder(
                  itemCount: _followers.length,
                  itemBuilder: (context, index) {
                    final user = _followers[index];
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
                        // For a complete flow, we should navigate to the UserProfileScreen, assuming it exists or we build a basic one
                        Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileScreen(userId: user.id)));
                      },
                    ).animate().fadeIn(delay: (index * 50).ms);
                  },
                ),
    );
  }
}
