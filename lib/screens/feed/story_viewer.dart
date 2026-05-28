import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StoryViewer extends StatefulWidget {
  const StoryViewer({super.key});

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _currentStoryIndex = 0;
  
  // بيانات افتراضية للقصص (صور عالية الدقة باللونين الأبيض والأسود)
  final List<String> _storyImages = [
    'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?q=80&w=1000&auto=format&fit=crop&grayscale', // صورة طبيعة أبيض وأسود
    'https://images.unsplash.com/photo-1511367461989-f85a21fda167?q=80&w=1000&auto=format&fit=crop&grayscale', // صورة أخرى
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // مدة عرض القصة 5 ثوانٍ
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
      }
    });

    _animationController.forward();
  }

  void _nextStory() {
    if (_currentStoryIndex < _storyImages.length - 1) {
      setState(() {
        _currentStoryIndex++;
        _animationController.reset();
        _animationController.forward();
      });
    } else {
      Navigator.of(context).pop(); // إغلاق القصص إذا انتهت
    }
  }

  void _previousStory() {
    if (_currentStoryIndex > 0) {
      setState(() {
        _currentStoryIndex--;
        _animationController.reset();
        _animationController.forward();
      });
    }
  }

  void _onTapDown(TapDownDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dx = details.globalPosition.dx;

    // تقسيم الشاشة للتحكم باللمس (اليسار للرجوع، اليمين للتقدم)
    if (dx < screenWidth / 3) {
      _previousStory();
    } else {
      _nextStory();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: _onTapDown,
        onLongPressDown: (_) => _animationController.stop(), // إيقاف المؤقت عند الضغط المطول
        onLongPressUp: () => _animationController.forward(), // استئناف عند رفع الإصبع
        child: Stack(
          children: [
            // صورة القصة
            Positioned.fill(
              child: Image.network(
                _storyImages[_currentStoryIndex],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                },
              ).animate(key: ValueKey(_currentStoryIndex)).fadeIn(duration: 300.ms),
            ),

            // تدرج لوني أسود بالأسفل والأعلى لضمان وضوح النصوص وشريط التقدم
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.5),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
            ),

            // شريط التقدم العلوي (Progress Bars)
            Positioned(
              top: 50,
              left: 10,
              right: 10,
              child: Row(
                children: List.generate(
                  _storyImages.length,
                  (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          double value = 0.0;
                          if (index < _currentStoryIndex) {
                            value = 1.0;
                          } else if (index == _currentStoryIndex) {
                            value = _animationController.value;
                          }
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: value,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              minHeight: 2.5,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // معلومات المستخدم (الصورة والاسم) وزر الإغلاق
            Positioned(
              top: 70,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'اسم المستخدم',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // مربع الذكاء الاصطناعي (ميزة تفاعلية إضافية)
            Positioned(
              bottom: 30,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'اكتب رداً باستخدام ذكاء سديم...',
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}