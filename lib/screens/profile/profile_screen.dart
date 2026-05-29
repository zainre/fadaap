import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shimmer_loading.dart';
import 'edit_profile_screen.dart';
// Note: We don't have separate following/followers list screens built yet,
// so clicking them will just show a snackbar for now.

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return GlassCard(
          borderRadius: 24.0,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade600,
                      borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              const Text('الإعدادات الشاملة',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildSettingTile(
                  Icons.person_outline, 'تعديل الحساب (الاسم، اليوزر، البايو)',
                  () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EditProfileScreen()));
              }),
              _buildSettingTile(
                  Icons.auto_awesome, 'تفضيلات سديم (الذكاء الاصطناعي)', () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قيد التطوير...')));
              }),
              _buildSettingTile(Icons.lock_outline, 'الخصوصية والأمان', () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قيد التطوير...')));
              }),
              _buildSettingTile(Icons.notifications_none, 'الإشعارات', () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قيد التطوير...')));
              }),
              const Divider(color: Colors.white24, height: 30),
              _buildSettingTile(Icons.logout, 'تسجيل الخروج', () {
                Navigator.pop(context);
                context.read<AuthProvider>().logout();
                Navigator.of(context).popUntil((route) => route.isFirst);
              }, isDestructive: true),
              const SizedBox(height: 20),
            ],
          ),
        )
            .animate()
            .slideY(begin: 1.0, duration: 400.ms, curve: Curves.easeOutCubic);
      },
    );
  }

  Widget _buildSettingTile(IconData icon, String title, VoidCallback onTap,
      {bool isDestructive = false}) {
    return ListTile(
      leading:
          Icon(icon, color: isDestructive ? Colors.redAccent : Colors.white),
      title: Text(title,
          style: TextStyle(
              color: isDestructive ? Colors.redAccent : Colors.white,
              fontSize: 16)),
      trailing:
          const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final userPosts = context
        .watch<FeedProvider>()
        .posts
        .where((p) => p.userId == user?.id)
        .toList();

    if (user == null) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(user.username,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 1, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
            onPressed: () => _showSettingsModal(context),
          ).animate().fadeIn(delay: 200.ms).scale(),
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
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                              colors: [Colors.white, Colors.grey]),
                        ),
                        child: CircleAvatar(
                          radius: 42,
                          backgroundColor: Colors.black,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: user.avatarUrl.isNotEmpty
                                ? NetworkImage(user.avatarUrl)
                                : const NetworkImage(
                                        'https://i.pravatar.cc/150?img=11')
                                    as ImageProvider,
                          ),
                        ),
                      )
                          .animate()
                          .scale(duration: 600.ms, curve: Curves.easeOutBack),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatColumn('منشورات', userPosts.length.toString(), () {}),
                            _buildStatColumn('متابعون', user.followersCount.toString(), () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قائمة المتابعين قيد التطوير')));
                            }),
                            _buildStatColumn('يتابع', user.followingCount.toString(), () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قائمة المتابَعين قيد التطوير')));
                            }),
                          ],
                        ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 2. الاسم والنبذة (Bio)
                  Text(user.fullName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18))
                      .animate()
                      .fadeIn(delay: 400.ms),
                  const SizedBox(height: 6),
                  Text(user.bio,
                          style: TextStyle(
                              color: Colors.grey.shade300,
                              fontSize: 14,
                              height: 1.4))
                      .animate()
                      .fadeIn(delay: 500.ms),
                  const SizedBox(height: 20),

                  // 3. تحليل الذكاء الاصطناعي للاهتمامات
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    borderRadius: 16,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.auto_awesome,
                                color: Colors.amberAccent, size: 24)
                            .animate(
                                onPlay: (controller) =>
                                    controller.repeat(reverse: true))
                            .scale(
                                begin: const Offset(0.9, 0.9),
                                end: const Offset(1.1, 1.1),
                                duration: 1.seconds),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('تحليل سديم AI',
                                  style: TextStyle(
                                      color: Colors.amberAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                user.aiInterestsSummary ??
                                    'يبدو أنك مهتم بالتقنية والفنون البصرية وتطوير الذات.',
                                style: TextStyle(
                                    color: Colors.grey.shade300,
                                    fontSize: 13,
                                    height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                  const SizedBox(height: 20),

                  // 4. أزرار التعديل
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const EditProfileScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white10,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('تعديل الملف الشخصي',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ).animate().fadeIn(delay: 700.ms),
                ],
              ),
            ),
          ),

          // 5. شبكة المنشورات
          SliverPadding(
            padding: const EdgeInsets.only(top: 8, bottom: 90),
            sliver: userPosts.isEmpty
                ? const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text('لا توجد منشورات بعد.',
                            style:
                                TextStyle(color: Colors.white54, fontSize: 16)),
                      ),
                    ),
                  )
                : SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return CachedNetworkImage(
                          imageUrl: userPosts[index].imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const ShimmerLoading(
                              width: double.infinity,
                              height: double.infinity,
                              borderRadius: 0),
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

  Widget _buildStatColumn(String label, String count, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(count,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
        ],
      ),
    );
  }
}
