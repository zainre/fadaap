import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/reel_model.dart';
import '../../widgets/glowing_heart.dart';

class ReelItem extends StatefulWidget {
  final ReelModel? reel;
  final String? dummyImage; // للتجربة قبل ربط قاعدة البيانات

  const ReelItem({super.key, this.reel, this.dummyImage});

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> with SingleTickerProviderStateMixin {
  bool _isLiked = false;
  late AnimationController _slowZoomController;

  @override
  void initState() {
    super.initState();
    // أنيميشن تكبير بطيء جداً لمحاكاة حركة الفيديو
    _slowZoomController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
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
    // هنا يمكن ربط الإعجاب بالـ Provider لاحقاً
  }

  @override
  Widget build(BuildContext context) {
    // جلب البيانات أو استخدام الوهمية
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
              scale: 1.0 + (_slowZoomController.value * 0.1), // تكبير حتى 10%
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.2),
                colorBlendMode: BlendMode.darken, // تعتيم بسيط لإبراز النص الأبيض
              ),
            );
          },
        ),

        // 2. تدرج لوني في الأسفل لضمان وضوح النصوص
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height / 2,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.9),
                ],
              ),
            ),
          ),
        ),

        // 3. معلومات الفيديو في الزاوية اليسرى السفلية
        Positioned(
          bottom: 90, // مرتفع قليلاً لعدم التداخل مع GlassNavBar
          left: 16,
          right: 80, // ترك مساحة لأزرار اليمين
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // معلومات المستخدم
              Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=15'),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'اسم المستخدم',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(width: 12),
                  // زر المتابعة
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('متابعة', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ],
              ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2),
              
              const SizedBox(height: 12),
              
              // الوصف (Caption)
              Text(
                caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),

              const SizedBox(height: 12),

              // الوسوم الذكية (AI Target Audience) محاطة بإطار زجاجي ناعم
              Wrap(
                spacing: 8.0,
                children: aiTags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(tag, style: const TextStyle(color: Colors.white, fontSize: 11)),
                    ],
                  ),
                )).toList(),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
            ],
          ),
        ),

        // 4. أزرار التفاعل في الجهة اليمنى
        Positioned(
          bottom: 90,
          right: 8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // زر الإعجاب (مع تأثير النبض الفخم)
              Column(
                children: [
                  GlowingHeart(isLiked: _isLiked, onTap: _toggleLike, size: 35),
                  const SizedBox(height: 4),
                  Text('$likesCount', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
              
              const SizedBox(height: 20),
              
              // زر التعليقات
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 32),
                    onPressed: () {}, // فتح التعليقات
                  ),
                  const Text('128', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),

              const SizedBox(height: 20),

              // زر المشاركة
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.send_outlined, color: Colors.white, size: 32),
                    onPressed: () {},
                  ),
                  const Text('مشاركة', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),

              const SizedBox(height: 20),

              // أيقونة الذكاء الاصطناعي (ميزة تحليل محتوى الريل أو تلخيصه)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 10, spreadRadius: 2)
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.psychology, color: Colors.white, size: 30),
                  onPressed: () {
                    // فتح نافذة الذكاء الاصطناعي المنبثقة
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('سديم AI: هذا الفيديو يستهدف محبي الفن والتصوير.', style: TextStyle(color: Colors.black)),
                        backgroundColor: Colors.white,
                      ),
                    );
                  },
                ),
              ).animate().fadeIn(delay: 600.ms).scale(),
            ],
          ),
        ),
      ],
    );
  }
}