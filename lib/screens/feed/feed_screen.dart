import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/feed_provider.dart';
import '../../providers/story_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/animated_story_circle.dart';
import '../../widgets/shimmer_loading.dart';
import 'story_viewer.dart';
import 'post_card.dart';
import '../create/create_story_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedProvider>().fetchPosts();
      context.read<StoryProvider>().fetchStories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.black,
      backgroundColor: Colors.amberAccent,
      onRefresh: () async {
        await context.read<FeedProvider>().fetchPosts();
        if (mounted) {
          await context.read<StoryProvider>().fetchStories();
        }
      },
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ✨ تحية سديم الذكية (تظهر في أعلى الـ Feed)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'مرحباً بك في سديم! موجزك اليوم مليء بالإلهام.',
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2),
            ),
          ),

          // قسم القصص (Stories)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 115,
              child: Consumer<StoryProvider>(
                builder: (context, storyProvider, child) {
                  if (storyProvider.isLoading && storyProvider.stories.isEmpty) {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      itemCount: 5,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(right: 18.0),
                        child: const ShimmerLoading(width: 65, height: 65, borderRadius: 32.5),
                      ),
                    );
                  }

                  // تجميع القصص حسب المستخدم
                  final storiesByUser = <String, List>{};
                  for (var story in storyProvider.stories) {
                    if (!storiesByUser.containsKey(story.userId)) {
                      storiesByUser[story.userId] = [];
                    }
                    storiesByUser[story.userId]!.add(story);
                  }

                  final userIds = storiesByUser.keys.toList();
                  final currentUserId = context.read<AuthProvider>().currentUser?.id;

                  // التأكد من وضع قصة المستخدم الحالي أولاً (في حال وجدت أو لإنشاء قصة جديدة)
                  if (currentUserId != null) {
                    userIds.remove(currentUserId);
                    userIds.insert(0, currentUserId);
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: userIds.isEmpty ? 1 : userIds.length + (currentUserId != null && !userIds.contains(currentUserId) ? 1 : 0),
                    itemBuilder: (context, index) {
                      final userId = userIds.isNotEmpty && index < userIds.length ? userIds[index] : currentUserId;
                      final userStories = userId != null ? storiesByUser[userId] ?? [] : [];

                      final isCurrentUser = userId == currentUserId;
                      final hasUnviewed = userStories.isNotEmpty; // في تطبيق حقيقي نتحقق مما إذا كان المستخدم شاهدها

                      // في تطبيق حقيقي نجلب صورة واسم المستخدم بناءً على الـ userId
                      final imageUrl = userStories.isNotEmpty ? userStories.first.mediaUrl : 'https://i.pravatar.cc/150?img=${index + 10}';

                      return Padding(
                        padding: const EdgeInsets.only(right: 18.0),
                        child: Column(
                          children: [
                            AnimatedStoryCircle(
                              imageUrl: imageUrl,
                              hasUnviewedStory: hasUnviewed,
                              onTap: () {
                                if (userStories.isEmpty && isCurrentUser) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const CreateStoryScreen()),
                                  );
                                } else if (userStories.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, a, b) => const StoryViewer(),
                                      transitionsBuilder: (context, a, b, child) => FadeTransition(opacity: a, child: child),
                                    ),
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isCurrentUser ? 'قصتك' : 'مستخدم $index',
                              style: TextStyle(
                                color: isCurrentUser ? Colors.white : Colors.grey.shade400,
                                fontSize: 12,
                                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: (index * 100).ms).scale(begin: const Offset(0.8, 0.8)),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          
          // خط فاصل رفيع جداً
          SliverToBoxAdapter(
            child: Divider(color: Colors.white.withOpacity(0.05), thickness: 1, height: 20),
          ),

          // قسم المنشورات (Posts)
          Consumer<FeedProvider>(
            builder: (context, feedProvider, child) {
              if (feedProvider.isLoading && feedProvider.posts.isEmpty) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: const ShimmerLoading(width: double.infinity, height: 400, borderRadius: 16),
                    ),
                    childCount: 3,
                  ),
                );
              }

              if (feedProvider.posts.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt_outlined, color: Colors.white24, size: 80)
                            .animate(onPlay: (c) => c.repeat(reverse: true)).scale(),
                        const SizedBox(height: 16),
                        const Text('العالم ينتظر إبداعك!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('لا توجد منشورات حتى الآن.', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                      ],
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = feedProvider.posts[index];
                    return PostCard(post: post)
                        .animate()
                        .fadeIn(duration: 600.ms, delay: (index * 100).ms)
                        .slideY(begin: 0.1, curve: Curves.easeOutCubic);
                  },
                  childCount: feedProvider.posts.length,
                ),
              );
            },
          ),
          
          // مسافة فارغة بالأسفل
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
