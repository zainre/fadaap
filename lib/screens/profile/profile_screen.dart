import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shimmer_loading.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final userPosts = context.watch<FeedProvider>().posts.where((p) => p.userId == user?.id).toList();

    if (user == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(user.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              // فتح قائمة الإعدادات الجانبية
            },
          ).animate().fadeIn(delay: 200.ms),
        ],
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
                  // 1. الصورة الشخصية والإحصائيات
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey.shade900,
                          backgroundImage: user.avatarUrl.isNotEmpty 
                              ? NetworkImage(user.avatarUrl) 
                              : const NetworkImage('https://i.pravatar.cc/150?img=11') as ImageProvider,
                        ),
                      ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                      
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatColumn('منشورات', userPosts.length.toString()),
                            _buildStatColumn('متابعون', '12.4K'), // بيانات افتراضية للتصميم
                            _buildStatColumn('يتابع', '845'),
                          ],
                        ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 2. الاسم والنبذة (Bio)
                  Text(user.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))
                      .animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 4),
                  Text(user.bio, style: const TextStyle(color: Colors.white, fontSize: 14))
                      .animate().fadeIn(delay: 500.ms),
                  const SizedBox(height: 16),

                  // 3. تحليل الذكاء الاصطناعي للاهتمامات
                  GlassCard(
                    padding: const EdgeInsets.all(12),
                    borderRadius: 12,
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            user.aiInterestsSummary ?? 'سديم AI: يبدو أنك مهتم بالتقنية والفنون البصرية.',
                            style: TextStyle(color: Colors.grey.shade300, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
                  const SizedBox(height: 16),

                  // 4. أزرار التعديل والمشاركة
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, a, b) => const EditProfileScreen(),
                                transitionsBuilder: (context, a, b, child) => FadeTransition(opacity: a, child: child),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('تعديل الملف الشخصي', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white.withOpacity(0.3)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('مشاركة الملف', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 700.ms),
                ],
              ),
            ),
          ),

          // 5. شبكة المنشورات (Grid)
          SliverPadding(
            padding: const EdgeInsets.only(top: 8, bottom: 90), // مسافة لشريط التنقل
            sliver: userPosts.isEmpty
                ? const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text('لا توجد منشورات بعد.', style: TextStyle(color: Colors.white)),
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
                          imageUrl: userPosts[index].imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const ShimmerLoading(width: double.infinity, height: double.infinity, borderRadius: 0),
                        ).animate().fadeIn(delay: (index * 50).ms);
                      },
                      childCount: userPosts.length,
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