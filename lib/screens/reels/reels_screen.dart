import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reels_provider.dart';
import '../../widgets/shimmer_loading.dart';
import 'reel_item.dart';
import '../create/create_reel_screen.dart';

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
      context.read<ReelsProvider>().fetchReels();
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
      extendBodyBehindAppBar: true, // للسماح للريلز بالمرور خلف الـ AppBar

      // ✨ شريط علوي شفاف وفخم
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
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreateReelScreen()),
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
            return PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: 3,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return ReelItem(
                  reel: null,
                  dummyImage:
                      'https://images.unsplash.com/photo-1518780664697-55e3ad937233?q=80&w=1000&auto=format&fit=crop',
                  isActive: _currentPage == index,
                );
              },
            );
          }

          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
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
