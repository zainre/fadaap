import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reels_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/shimmer_loading.dart';
import 'reel_item.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        context.read<ReelsProvider>().fetchReels(currentUserId: authProvider.currentUser!.id);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Reels',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: 1.5,
                shadows: [Shadow(color: Colors.black, blurRadius: 10)])),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined,
                color: Colors.white, size: 28),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('الرجاء استخدام شاشة الإضافة المركزية +'))
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: Consumer<ReelsProvider>(
        builder: (context, reelsProvider, child) {
          if (reelsProvider.isLoading && reelsProvider.reels.isEmpty) {
            return const Center(
              child: ShimmerLoading(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 0),
            );
          }

          if (reelsProvider.reels.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.videocam_off, color: Colors.white54, size: 64),
                  const SizedBox(height: 16),
                  Text('لا توجد مقاطع ريلز حتى الآن', style: TextStyle(color: Colors.grey.shade400, fontSize: 18)),
                ],
              ),
            );
          }

          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              // Track view
              final reel = reelsProvider.reels[index];
              reelsProvider.recordView(reel.id);
            },
            itemCount: reelsProvider.reels.length,
            itemBuilder: (context, index) {
              return ReelItem(
                reel: reelsProvider.reels[index],
                isActive: _currentPage == index,
              );
            },
          );
        },
      ),
    );
  }
}
