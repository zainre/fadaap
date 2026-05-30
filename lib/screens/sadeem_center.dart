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
import 'create/create_post_screen.dart';

class SadeemCenterScreen extends StatefulWidget {
  const SadeemCenterScreen({super.key});

  @override
  State<SadeemCenterScreen> createState() => _SadeemCenterScreenState();
}

class _SadeemCenterScreenState extends State<SadeemCenterScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const FeedScreen(),
    const ExploreScreen(),
    const AIAssistantScreen(), // ✨ المركز مخصص حصرياً للذكاء الاصطناعي
    const ReelsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
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
                  icon: const Icon(Icons.add_box_outlined, color: Colors.white),
                  onPressed: () {
                    // Navigate to Create Post
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreatePostScreen()),
                    );
                  },
                ),
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

      // استخدمنا Stack مع Offstage و AnimatedOpacity للحفاظ على حالة الصفحات
      // وتوفير حركة انتقال سلسة في نفس الوقت بدلاً من IndexedStack المباشر
      body: Stack(
        children: List.generate(_screens.length, (index) {
          final bool isActive = _currentIndex == index;
          return Offstage(
            offstage: !isActive,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isActive ? 1.0 : 0.0,
              curve: Curves.easeOutCubic,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.05),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: isActive ? const AlwaysStoppedAnimation(1.0) : const AlwaysStoppedAnimation(0.0),
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: _screens[index],
              ),
            ),
          );
        }),
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
}
