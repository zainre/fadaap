import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/post_model.dart';
import '../../providers/feed_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/glowing_heart.dart';
import '../../widgets/shimmer_loading.dart';

class PostCard extends StatefulWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with SingleTickerProviderStateMixin {
  bool _isLiked = false;
  bool _showBigHeart = false; // لإظهار قلب كبير عند النقر المزدوج على الصورة

  void _toggleLike() {
    final userId = context.read<AuthProvider>().currentUser?.id ?? '';
    if (userId.isEmpty) return;

    setState(() {
      _isLiked = !_isLiked;
    });
    
    // إرسال التحديث لقاعدة البيانات عبر البروفايدر
    context.read<FeedProvider>().toggleLike(widget.post.id, userId);
  }

  void _handleDoubleTap() {
    if (!_isLiked) _toggleLike();
    setState(() => _showBigHeart = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showBigHeart = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.black, // خلفية سوداء للمنشور
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. رأس المنشور (صورة المستخدم، اسمه، وزر الخيارات)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey.shade900,
                  backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=12'), // صورة افتراضية
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('اسم المستخدم', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      // إظهار إذا كان هناك وصف تلقائي للصورة عبر الذكاء الاصطناعي
                      if (widget.post.aiDescription != null && widget.post.aiDescription!.isNotEmpty)
                        Text('✨ تم التحليل بواسطة سديم AI', style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // 2. صورة المنشور (مع أنيميشن النقر المزدوج)
          GestureDetector(
            onDoubleTap: _handleDoubleTap,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CachedNetworkImage(
                  imageUrl: widget.post.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const ShimmerLoading(width: double.infinity, height: 350, borderRadius: 0),
                  errorWidget: (context, url, error) => Container(
                    height: 350,
                    color: Colors.grey.shade900,
                    child: const Center(child: Icon(Icons.error_outline, color: Colors.white, size: 40)),
                  ),
                ),
                // تأثير القلب الأبيض الكبير عند النقر المزدوج
                if (_showBigHeart)
                  const Icon(Icons.favorite, color: Colors.white, size: 100)
                      .animate()
                      .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.2, 1.2), duration: 300.ms, curve: Curves.elasticOut)
                      .fadeOut(delay: 500.ms, duration: 300.ms),
              ],
            ),
          ),

          // 3. شريط التفاعل (إعجاب، تعليق، مشاركة)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                GlowingHeart(
                  isLiked: _isLiked,
                  onTap: _toggleLike,
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    // فتح التعليقات لاحقاً
                  },
                  child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 26),
                ).animate().scale(delay: 100.ms),
                const SizedBox(width: 16),
                const Icon(Icons.send_outlined, color: Colors.white, size: 26).animate().scale(delay: 200.ms),
                const Spacer(),
                const Icon(Icons.bookmark_border, color: Colors.white, size: 28).animate().scale(delay: 300.ms),
              ],
            ),
          ),

          // 4. عدد الإعجابات
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '${widget.post.likesCount + (_isLiked ? 1 : 0)} إعجاب',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),

          // 5. الوصف (Caption) والوسوم الذكية (AI Tags)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white, fontSize: 13),
                children: [
                  const TextSpan(text: 'اسم المستخدم ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: widget.post.caption),
                ],
              ),
            ),
          ),
          
          // عرض الوسوم المولدة بالذكاء الاصطناعي إن وجدت
          if (widget.post.aiTags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 6.0,
                children: widget.post.aiTags.map((tag) => Text(
                  '#$tag',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                )).toList(),
              ),
            ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}