import 'package:flutter/material.dart';
import '../widgets/glass_nav_bar.dart';
import 'feed/feed_screen.dart';
import 'reels/reels_screen.dart';
import 'profile/profile_screen.dart';
import 'chat/chat_list_screen.dart';

class SadeemCenterScreen extends StatefulWidget {
  const SadeemCenterScreen({super.key});

  @override
  State<SadeemCenterScreen> createState() => _SadeemCenterScreenState();
}

class _SadeemCenterScreenState extends State<SadeemCenterScreen> {
  int _currentIndex = 0;

  // قائمة الشاشات
  final List<Widget> _screens = [
    const FeedScreen(),
    const Center(child: Text('البحث الذكي', style: TextStyle(color: Colors.white, fontSize: 24))), 
    const Center(child: Text('إضافة منشور', style: TextStyle(color: Colors.white, fontSize: 24))), 
    const ReelsScreen(), 
    const ProfileScreen(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true, // مهم جداً لجعل شريط التنقل الزجاجي يطفو فوق المحتوى
      
      // شريط علوي زجاجي بسيط يظهر في الرئيسية فقط
      appBar: _currentIndex == 0 
        ? AppBar(
            backgroundColor: Colors.black.withOpacity(0.8),
            title: const Text('ســديــم', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
            actions: [
              IconButton(
                icon: const Icon(Icons.send_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatListScreen()),
                  );
                },
              ),
            ],
          )
        : null,

      // استخدام IndexedStack للحفاظ على حالة كل شاشة عند التنقل
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      // شريط التنقل الزجاجي الذي صممناه سابقاً
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
