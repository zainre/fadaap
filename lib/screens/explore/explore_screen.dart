import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../config/supabase_config.dart';
import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/shimmer_loading.dart';
// Note: You can tap on a post to see its details or open it in a full-screen view.
// For now, we'll just display a beautiful staggered grid.

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _supabase = SupabaseConfig.client;
  List<PostModel> _trendingPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTrendingPosts();
  }

  Future<void> _fetchTrendingPosts() async {
    final currentUserId = context.read<AuthProvider>().currentUser?.id;
    if (currentUserId == null) return;

    setState(() => _isLoading = true);

    try {
      // Fetch posts, ideally from users you DO NOT follow, ordered by likes_count to get "Trending"
      // Since complex queries requiring joins on follows table can be tricky without an RPC,
      // we will fetch top posts globally and exclude the current user's posts.

      final response = await _supabase
          .from('posts')
          .select()
          .neq('user_id', currentUserId)
          .order('likes_count', ascending: false)
          .limit(20);

      setState(() {
        _trendingPosts = (response as List).map((p) => PostModel.fromJson(p)).toList();
      });
    } catch (e) {
      debugPrint('Error fetching trending posts: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('اكتشف', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // TODO: Navigate to search screen
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amberAccent))
          : _trendingPosts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.explore_off, size: 80, color: Colors.white24),
                      const SizedBox(height: 16),
                      const Text('لا توجد منشورات رائجة حالياً.', style: TextStyle(color: Colors.white54, fontSize: 16)),
                    ],
                  ).animate().fadeIn(),
                )
              : RefreshIndicator(
                  color: Colors.black,
                  backgroundColor: Colors.amberAccent,
                  onRefresh: _fetchTrendingPosts,
                  child: MasonryGridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    itemCount: _trendingPosts.length,
                    itemBuilder: (context, index) {
                      final post = _trendingPosts[index];
                      // Use a staggered effect based on index
                      final isLarge = index % 3 == 0;

                      return GestureDetector(
                        onTap: () {
                          // TODO: Open Post Detail Screen
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(isLarge ? 12 : 8),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Stack(
                            fit: StackFit.passthrough,
                            children: [
                              CachedNetworkImage(
                                imageUrl: post.imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => ShimmerLoading(
                                  width: double.infinity,
                                  height: isLarge ? 300 : 150,
                                  borderRadius: 0,
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: isLarge ? 300 : 150,
                                  color: Colors.grey.shade900,
                                  child: const Icon(Icons.error, color: Colors.white54),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                left: 8,
                                child: Row(
                                  children: [
                                    const Icon(Icons.favorite, color: Colors.white, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${post.likesCount}',
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1),
                      );
                    },
                  ),
                ),
    );
  }
}
