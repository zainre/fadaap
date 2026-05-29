import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/reel_model.dart';
import '../../widgets/glowing_heart.dart';

class ReelItem extends StatefulWidget {
  final ReelModel? reel;
  final String? dummyImage; 

  const ReelItem({super.key, this.reel, this.dummyImage});

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> with SingleTickerProviderStateMixin {
  bool _isLiked = false;
  late AnimationController _slowZoomController;
  bool _showAiDetails = false;

  @override
  void initState() {
    super.initState();
    // أنيميشن تكبير بطيء جداً لمحاكاة حركة الفيديو
    _slowZoomController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20), // أبطأ ليكون أكثر انسيابية
    )..forward();
  }

  @override
  void dispose() {
    _slowZoomController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
  }

  // ✨ نافذة سديم الذكية لتحليل الريلز
  void _showAiAnalysis(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                border: Border(top: BorderSide(color: Colors.amberAccent.withOpacity(0.4), width: 1.5)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 36)
                      .animate(onPlay: (c) => c.repeat(reverse: true)).scale(duration: 1.seconds),
                  const SizedBox(height: 16),
                  const Text('تحليل سديم AI للمقطع', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildAiInsightTile(Icons.people_alt, 'الجمهور المستهدف', 'المهتمون بالفنون البصرية والتصوير الفوتوغرافي.'),
                  _buildAiInsightTile(Icons.insights, 'توقع التفاعل', 'عالٍ جداً نظراً لجودة التكوين والإضاءة المذهلة.'),
                  _buildAiInsightTile(Icons.subtitles, 'التفريغ الصوتي', 'لا يوجد نص منطوق في هذا الجزء من المقطع.'),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAiInsightTile(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ).animate().fadeIn().slideX(begin: 0.1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.reel?.videoUrl ?? widget.dummyImage ?? '';
    final caption = widget.reel?.caption ?? 'رحلة بين النجوم، استكشاف المجهول في عالم سديم... ✨';
    final aiTags = widget.reel?.aiTargetAudience ?? ['تصوير', 'فن', 'أبيض وأسود'];
    final likesCount = (widget.reel?.likesCount ?? 1240) + (_isLiked ? 1 : 0);

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. خلفية الفيديو / الصورة مع حركة التكبير البطيئة
        AnimatedBuilder(
          animation: _slowZoomController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_slowZoomController.value * 0.1), 
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.15),
                colorBlendMode: BlendMode.darken,
              ),
            );
          },
        ),

        // 2. تدرج لوني في الأسفل لضمان وضوح النصوص
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.6,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.9),
                ],
              ),
            ),
          ),
        ),

        // 3. معلومات الفيديو في الزاوية اليسرى السفلية
        Positioned(
          bottom: 100, 
          left: 16,
          right: 80, 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // معلومات المستخدم
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.amberAccent.withOpacity(0.5), width: 1.5),
                    ),
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=15'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'اسم المستخدم',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
                  ),
                  const SizedBox(width: 12),
                  // زر المتابعة الزجاجي
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('متابعة', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1),
              
              const SizedBox(height: 16),
              
              // الوصف (Caption)
              Text(
                caption,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4, shadows: [Shadow(color: Colors.black, blurRadius: 5)]),
              ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),

              const SizedBox(height: 16),

              // الوسوم الذكية (AI Target Audience)
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: aiTags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amberAccent.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 12),
                      const SizedBox(width: 6),
                      Text(tag, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )).toList(),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
            ],
          ),
        ),

        // 4. أزرار التفاعل في الجهة اليمنى
        Positioned(
          bottom: 100,
          right: 12,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                children: [
                  GlowingHeart(isLiked: _isLiked, onTap: _toggleLike, size: 38),
                  const SizedBox(height: 4),
                  Text('$likesCount', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black, blurRadius: 5)])),
                ],
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
              
              const SizedBox(height: 24),
              
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 34),
                    onPressed: () {}, 
                  ),
                  const Text('128', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black, blurRadius: 5)])),
                ],
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

              const SizedBox(height: 24),

              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 34),
                    onPressed: () {},
                  ),
                  const Text('مشاركة', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black, blurRadius: 5)])),
                ],
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),

              const SizedBox(height: 30),

              // ✨ أيقونة الذكاء الاصطناعي الأنيقة
              GestureDetector(
                onTap: () => _showAiAnalysis(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amberAccent.withOpacity(0.2),
                    border: Border.all(color: Colors.amberAccent.withOpacity(0.5), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: Colors.amberAccent.withOpacity(0.2), blurRadius: 15, spreadRadius: 2)
                    ],
                  ),
                  child: const Icon(Icons.psychology, color: Colors.white, size: 28),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 2.seconds),
            ],
          ),
        ),
      ],
    );
  }
}
