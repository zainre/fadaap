import 'dart:ui';
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
  bool _showBigHeart = false; 

  void _toggleLike() {
    final userId = context.read<AuthProvider>().currentUser?.id ?? '';
    if (userId.isEmpty) return;

    setState(() {
      _isLiked = !_isLiked;
    });
    
    context.read<FeedProvider>().toggleLike(widget.post.id, userId);
  }

  void _handleDoubleTap() {
    if (!_isLiked) _toggleLike();
    setState(() => _showBigHeart = true);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _showBigHeart = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. رأس المنشور
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.amberAccent.withOpacity(0.5), width: 1.5),
                  ),
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.black,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('اسم المستخدم', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5)),
                ),
                // ✨ بصمة زين المخفية في زر الخيارات
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () {},
                    ),
                    const Positioned(
                      right: 4,
                      bottom: 4,
                      child: Text('Z', style: TextStyle(color: Colors.amberAccent, fontSize: 6, fontWeight: FontWeight.bold)),
                    ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeOut(duration: 2.seconds),
                  ],
                ),
              ],
            ),
          ),

          // 2. صورة المنشور مع شريطة الذكاء الاصطناعي وأنيميشن القلب
          GestureDetector(
            onDoubleTap: _handleDoubleTap,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: CachedNetworkImage(
                    imageUrl: widget.post.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const ShimmerLoading(width: double.infinity, height: 400, borderRadius: 0),
                    errorWidget: (context, url, error) => Container(
                      height: 400,
                      color: Colors.grey.shade900,
                      child: const Center(child: Icon(Icons.error_outline, color: Colors.white54, size: 40)),
                    ),
                  ),
                ),

                // شريطة سديم الزجاجية (تظهر إذا كان هناك تحليل للذكاء الاصطناعي)
                if (widget.post.aiDescription != null && widget.post.aiDescription!.isNotEmpty)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.amberAccent.withOpacity(0.4)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 14),
                              SizedBox(width: 6),
                              Text('عُزز بواسطة سديم', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2),
                  ),

                // تأثير القلب الأبيض الكبير
                if (_showBigHeart)
                  const Icon(Icons.favorite, color: Colors.white, size: 120)
                      .animate()
                      .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.2, 1.2), duration: 400.ms, curve: Curves.elasticOut)
                      .then(delay: 200.ms)
                      .fadeOut(duration: 400.ms, curve: Curves.easeOut),
              ],
            ),
          ),

          // 3. شريط التفاعل (إعجاب، تعليق، مشاركة)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                GlowingHeart(
                  isLiked: _isLiked,
                  onTap: _toggleLike,
                ),
                const SizedBox(width: 18),
                GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 26),
                ).animate().scale(delay: 100.ms),
                const SizedBox(width: 18),
                GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.send_outlined, color: Colors.white, size: 26),
                ).animate().scale(delay: 200.ms),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.bookmark_border, color: Colors.white, size: 28),
                ).animate().scale(delay: 300.ms),
              ],
            ),
          ),

          // 4. عدد الإعجابات
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '${widget.post.likesCount + (_isLiked ? 1 : 0)} إعجاب',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ).animate(target: _isLiked ? 1 : 0).shimmer(color: Colors.redAccent),
          ),

          // 5. الوصف والوسوم الذكية
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                children: [
                  const TextSpan(text: 'اسم المستخدم ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: widget.post.caption),
                ],
              ),
            ),
          ),
          
          if (widget.post.aiTags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: widget.post.aiTags.map((tag) => Text(
                  '#$tag',
                  style: TextStyle(color: Colors.amberAccent.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w500),
                )).toList(),
              ).animate().fadeIn(delay: 300.ms),
            ),

          const SizedBox(height: 8),
          
          // وقت النشر
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('منذ ساعتين', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
