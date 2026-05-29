import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // تأكد من إضافة هذه المكتبة
import '../widgets/glass_nav_bar.dart';
import 'feed/feed_screen.dart';
import 'reels/reels_screen.dart';
import 'profile/profile_screen.dart';
import 'chat/chat_list_screen.dart';
import 'ai_assistant_screen.dart';
import 'notifications/notifications_screen.dart';
import 'explore/explore_screen.dart';

class SadeemCenterScreen extends StatefulWidget {
  const SadeemCenterScreen({super.key});

  @override
  State<SadeemCenterScreen> createState() => _SadeemCenterScreenState();
}

class _SadeemCenterScreenState extends State<SadeemCenterScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // قائمة الشاشات (تم تعريفها داخل الـ build لكي نستطيع استدعاء دالة بناء الشاشة السحرية)
    final List<Widget> screens = [
      const FeedScreen(),
      const ExploreScreen(), // 🧭 تم تفعيل شاشة الاكتشاف
      _buildMagicCreationHub(), // 🔮 استبدلنا النص العادي بمركز سديم السحري
      const ReelsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true, // مهم جداً لجعل شريط التنقل الزجاجي يطفو فوق المحتوى

      appBar: _currentIndex == 0
          ? AppBar(
              backgroundColor: Colors.black.withOpacity(0.8),
              title: const Text('ســديــم',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_outlined),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NotificationsScreen()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.send_outlined),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ChatListScreen()),
                    );
                  },
                ),
              ],
            )
          : null,

      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),

      bottomNavigationBar: GlassNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  // 🔮 الدالة التي تبني مركز سديم السحري (الخيار الأوسط)
  Widget _buildMagicCreationHub() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          colors: [
            Color(0xFF151528),
            Colors.black
          ], // تدرج لوني يعطي عمقاً فخماً
          radius: 1.5,
          center: Alignment.center,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // تأثير الضوء الخلفي النابض
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.amber.withOpacity(0.08),
                      blurRadius: 120,
                      spreadRadius: 60)
                ],
              ),
            )
                .animate(
                    onPlay: (controller) => controller.repeat(reverse: true))
                .scale(duration: 2.seconds),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // أيقونة سديم الرئيسية
              const Icon(Icons.blur_on, size: 90, color: Colors.white)
                  .animate(
                      onPlay: (controller) => controller.repeat(reverse: true))
                  .scale(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1.1, 1.1),
                      duration: 2.seconds)
                  .shimmer(color: Colors.amberAccent, duration: 3.seconds),
              const SizedBox(height: 24),

              const Text('ماذا تريد أن تبدع الآن؟',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1))
                  .animate()
                  .fadeIn(delay: 200.ms)
                  .slideY(begin: 0.2),
              const SizedBox(height: 50),

              // شبكة الخيارات الإبداعية
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  _buildMagicOption(
                      Icons.edit_document, 'منشور', Colors.blueAccent, 300),
                  _buildMagicOption(
                      Icons.camera_rounded, 'قصة', Colors.pinkAccent, 400),
                  _buildMagicOption(
                      Icons.movie_creation, 'ريلز', Colors.purpleAccent, 500),
                  _buildMagicOption(
                      Icons.auto_awesome, 'سؤال سديم', Colors.amberAccent, 600),
                ],
              ),
            ],
          ),

          // ✨ توقيع المطور (زين العابدين) الأسطوري المخفي
          Positioned(
            bottom: 130, // مرفوع قليلاً لكي لا يغطيه شريط التنقل الزجاجي
            child: Column(
              children: [
                const Text(
                  '✨ Crafted with magic by Zain',
                  style: TextStyle(
                    fontFamily:
                        'monospace', // خط مميز يعطي طابع البرمجة والفخامة
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.amberAccent,
                    letterSpacing: 1.5,
                  ),
                )
                    .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true))
                    .shimmer(duration: 2.seconds, color: Colors.white)
                    .slideY(begin: 0.1, duration: 800.ms),
                const SizedBox(height: 6),
                Container(
                  width: 50,
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.amberAccent,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.amberAccent,
                          blurRadius: 10,
                          spreadRadius: 2)
                    ],
                  ),
                )
                    .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true))
                    .scaleX(duration: 1.seconds),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // دالة بناء الأزرار بستايل النيون والزجاج
  Widget _buildMagicOption(
      IconData icon, String title, Color color, int delay) {
    return GestureDetector(
      onTap: () {
        // سيتم ربط هذه الأزرار بشاشات الإضافة لاحقاً
      },
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.1), blurRadius: 20, spreadRadius: 1),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: color),
            const SizedBox(height: 14),
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      )
          .animate()
          .fadeIn(delay: delay.ms)
          .slideY(begin: 0.1)
          .shimmer(delay: (delay + 500).ms, color: Colors.white24),
    );
  }
}
