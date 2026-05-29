import 'package:flutter/material.dart';
import '../../../config/supabase_config.dart';
import '../../../models/user_model.dart';
import '../user_profile_screen.dart';

class FollowingListScreen extends StatefulWidget {
  final String userId;

  const FollowingListScreen({super.key, required this.userId});

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
    try {
      final response = await _supabase.from('follows').select('''
        following_id,
        profiles!follows_following_id_fkey(*)
      ''').eq('follower_id', widget.userId);

      setState(() {
        _following = (response as List).map((row) {
          return UserModel.fromJson(row['profiles']);
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
        title: const Text('يتابع'),
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amberAccent))
          : _following.isEmpty
              ? const Center(child: Text('لا يتابع أحداً.', style: TextStyle(color: Colors.white54)))
              : ListView.builder(
                  itemCount: _following.length,
                  itemBuilder: (context, index) {
                    final user = _following[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.avatarUrl.isNotEmpty ? NetworkImage(user.avatarUrl) : null,
                        child: user.avatarUrl.isEmpty ? const Icon(Icons.person) : null,
                      ),
                      title: Text(user.username, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(user.fullName, style: TextStyle(color: Colors.white54)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserProfileScreen(userId: user.id)),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
