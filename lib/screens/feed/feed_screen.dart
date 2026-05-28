import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/feed_provider.dart';
import '../../widgets/animated_story_circle.dart';
import '../../widgets/shimmer_loading.dart';
import 'story_viewer.dart';
import 'post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    // جلب المنشورات بمجرد فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedProvider>().fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.black,
      backgroundColor: Colors.white,
      onRefresh: () => context.read<FeedProvider>().fetchPosts(),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // قسم القصص (Stories) بالتدفق الأفقي
          SliverToBoxAdapter(
            child: SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                itemCount: 8, // مؤقت لحين دمج بيانات القصص الحقيقية
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Column(
                      children: [
                        AnimatedStoryCircle(
                          // صورة افتراضية للتجربة
                          imageUrl: 'https://i.pravatar.cc/150?img=${index + 10}',
                          hasUnviewedStory: index < 3, // أول 3 أشخاص لديهم قصة غير مقروءة
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, a, b) => const StoryViewer(),
                                transitionsBuilder: (context, a, b, child) => FadeTransition(opacity: a, child: child),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 6),
                        Text(
                          index == 0 ? 'قصتك' : 'مستخدم $index',
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                        ),
                      ],
                    ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.2), // حركة دخول متتابعة
                  );
                },
              ),
            ),
          ),
          
          // خط فاصل زجاجي خفيف
          SliverToBoxAdapter(
            child: Divider(color: Colors.white.withOpacity(0.1), thickness: 1, height: 1),
          ),

          // قسم المنشورات (Posts)
          Consumer<FeedProvider>(
            builder: (context, feedProvider, child) {
              if (feedProvider.isLoading && feedProvider.posts.isEmpty) {
                // تأثير التحميل الوامض للمنشورات
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: const ShimmerLoading(width: double.infinity, height: 350, borderRadius: 20),
                    ),
                    childCount: 3,
                  ),
                );
              }

              if (feedProvider.posts.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text('لا توجد منشورات حتى الآن.', style: TextStyle(color: Colors.white)),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = feedProvider.posts[index];
                    return PostCard(post: post)
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.1, curve: Curves.easeOutCubic);
                  },
                  childCount: feedProvider.posts.length,
                ),
              );
            },
          ),
          
          // مسافة فارغة بالأسفل حتى لا يغطي شريط التنقل على آخر منشور
          const SliverToBoxAdapter(child: SizedBox(height: 90)),
        ],
      ),
    );
  }
}