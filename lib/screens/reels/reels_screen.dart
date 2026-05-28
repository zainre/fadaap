import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reels_provider.dart';
import '../../widgets/shimmer_loading.dart';
import 'reel_item.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // جلب الفيديوهات بمجرد فتح الشاشة
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
      body: Consumer<ReelsProvider>(
        builder: (context, reelsProvider, child) {
          if (reelsProvider.isLoading && reelsProvider.reels.isEmpty) {
            return const Center(
              child: ShimmerLoading(width: double.infinity, height: double.infinity, borderRadius: 0),
            );
          }

          if (reelsProvider.reels.isEmpty) {
            // بيانات افتراضية في حال لم تكن هناك بيانات في Supabase لتجربة الواجهة
            return PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: 3,
              itemBuilder: (context, index) {
                return ReelItem(
                  // تمرير بيانات وهمية للتجربة
                  reel: null, 
                  dummyImage: 'https://images.unsplash.com/photo-1518780664697-55e3ad937233?q=80&w=1000&auto=format&fit=crop&grayscale',
                );
              },
            );
          }

          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: reelsProvider.reels.length,
            itemBuilder: (context, index) {
              return ReelItem(reel: reelsProvider.reels[index]);
            },
          );
        },
      ),
    );
  }
}