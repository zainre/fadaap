import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StoryViewer extends StatefulWidget {
  const StoryViewer({super.key});

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _currentStoryIndex = 0;
  bool _isUIHidden = false; // للتحكم بإخفاء الواجهة عند الضغط المطول
  bool _isLiked = false; // لحالة زر الإعجاب

  // بيانات افتراضية عالية الدقة
  final List<String> _storyImages = [
    'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?q=80&w=1000&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1511367461989-f85a21fda167?q=80&w=1000&auto=format&fit=crop',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6), // 6 ثوانٍ للقصة
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
        _isLiked = false; // إعادة ضبط الإعجاب للقصة الجديدة
        _animationController.reset();
        _animationController.forward();
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void _previousStory() {
    if (_currentStoryIndex > 0) {
      setState(() {
        _currentStoryIndex--;
        _isLiked = false;
        _animationController.reset();
        _animationController.forward();
      });
    }
  }

  // التحكم باللمس الذكي (يمين، يسار، ضغط مطول)
  void _onTapDown(TapDownDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dx = details.globalPosition.dx;

    if (dx < screenWidth / 3) {
      _previousStory();
    } else {
      _nextStory();
    }
  }

  void _onLongPressStart(LongPressStartDetails details) {
    _animationController.stop();
    setState(() => _isUIHidden = true); // إخفاء الواجهة
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    _animationController.forward();
    setState(() => _isUIHidden = false); // إظهار الواجهة
  }

  // إغلاق القصة عند السحب للأسفل
  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (details.primaryDelta! > 7) {
      Navigator.of(context).pop();
    }
  }

  // واجهة سديم للرد الذكي (تنبثق من الأسفل)
  void _showSadeemAiReply() {
    _animationController.stop(); // إيقاف القصة أثناء كتابة الرد
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                border: Border(
                    top: BorderSide(
                        color: Colors.amberAccent.withOpacity(0.5), width: 2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome,
                          color: Colors.amberAccent, size: 32)
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(duration: 1.seconds),
                  const SizedBox(height: 16),
                  const Text('سديم يحلل الصورة...',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  // اقتراحات الذكاء الاصطناعي
                  _buildAiReplyOption('صورة تخطف الأنفاس! ✨'),
                  _buildAiReplyOption('زاوية التصوير احترافية جداً 📸'),
                  _buildAiReplyOption('مكان رائع، أين هذا؟ 🤔'),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    ).whenComplete(
        () => _animationController.forward()); // إكمال القصة عند إغلاق النافذة
  }

  Widget _buildAiReplyOption(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.1),
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('تم إرسال الرد الذكي بنجاح! 🚀'),
                backgroundColor: Color(0xFF0095F6)),
          );
        },
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    ).animate().fadeIn().slideX(begin: 0.2);
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
        onLongPressStart: _onLongPressStart,
        onLongPressEnd: _onLongPressEnd,
        onVerticalDragUpdate: _onVerticalDragUpdate,
        child: Stack(
          children: [
            // 1. صورة القصة
            Positioned.fill(
              child: Image.network(
                _storyImages[_currentStoryIndex],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.white));
                },
              )
                  .animate(key: ValueKey(_currentStoryIndex))
                  .fadeIn(duration: 400.ms),
            ),

            // 2. التدرج اللوني (الظل) لضمان وضوح النصوص
            AnimatedOpacity(
              opacity: _isUIHidden ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 3. شريط التقدم العلوي
            AnimatedOpacity(
              opacity: _isUIHidden ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Positioned(
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
                            if (index < _currentStoryIndex)
                              value = 1.0;
                            else if (index == _currentStoryIndex)
                              value = _animationController.value;

                            return ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: value,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                                minHeight: 3,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 4. معلومات المستخدم وزر الإغلاق
            AnimatedOpacity(
              opacity: _isUIHidden ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Positioned(
                top: 70,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.amberAccent),
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundImage:
                            NetworkImage('https://i.pravatar.cc/150?img=12'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text('اسم المستخدم',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 5)
                            ])),
                    const SizedBox(width: 8),
                    Text('2 س',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 28),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),

            // 5. البصمة الأسطورية (Zain Easter Egg)
            AnimatedOpacity(
              opacity: _isUIHidden ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Positioned(
                bottom: 100,
                right: 20,
                child: const Text(
                  '✨ Sadeem x Zain',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white38,
                    letterSpacing: 1,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .shimmer(duration: 3.seconds, color: Colors.amberAccent),
              ),
            ),

            // 6. مربع الرد الذكي وزر الإعجاب في الأسفل
            AnimatedOpacity(
              opacity: _isUIHidden ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Positioned(
                bottom: 24,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    // مربع الرد الذكي
                    Expanded(
                      child: GestureDetector(
                        onTap: _showSadeemAiReply,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.auto_awesome,
                                          color: Colors.amberAccent, size: 22)
                                      .animate(
                                          onPlay: (c) =>
                                              c.repeat(reverse: true))
                                      .scale(),
                                  const SizedBox(width: 12),
                                  const Text('رد باستخدام سديم AI...',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // زر الإعجاب (Like)
                    GestureDetector(
                      onTap: () => setState(() => _isLiked = !_isLiked),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isLiked
                              ? Colors.redAccent.withOpacity(0.2)
                              : Colors.white.withOpacity(0.1),
                        ),
                        child: Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_border,
                          color: _isLiked ? Colors.redAccent : Colors.white,
                          size: 28,
                        )
                            .animate(target: _isLiked ? 1 : 0)
                            .scale(
                                end: const Offset(1.2, 1.2), duration: 200.ms)
                            .then()
                            .scale(end: const Offset(1.0, 1.0)),
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
