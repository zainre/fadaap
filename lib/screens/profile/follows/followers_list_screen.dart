import 'package:flutter/material.dart';
import '../../../config/supabase_config.dart';
import '../../../models/user_model.dart';
import '../user_profile_screen.dart';

class FollowersListScreen extends StatefulWidget {
  final String userId;

  const FollowersListScreen({super.key, required this.userId});

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
    try {
      final response = await _supabase.from('follows').select('''
        follower_id,
        profiles!follows_follower_id_fkey(*)
      ''').eq('following_id', widget.userId);

      setState(() {
        _followers = (response as List).map((row) {
          return UserModel.fromJson(row['profiles']);
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
        title: const Text('المتابعون'),
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amberAccent))
          : _followers.isEmpty
              ? const Center(child: Text('لا يوجد متابعون.', style: TextStyle(color: Colors.white54)))
              : ListView.builder(
                  itemCount: _followers.length,
                  itemBuilder: (context, index) {
                    final user = _followers[index];
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
