import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import '../../models/post_model.dart'; // Using PostModel instead of ReelModel
import '../../widgets/glowing_heart.dart';
import '../../providers/reels_provider.dart';
import '../../providers/auth_provider.dart';
import '../feed/comments_sheet.dart';

class ReelItem extends StatefulWidget {
  final PostModel? reel;
  final String? dummyImage;
  final bool isActive;

  const ReelItem(
      {super.key, this.reel, this.dummyImage, this.isActive = false});

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _slowZoomController;
  VideoPlayerController? _videoPlayerController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();

    _initVideoPlayer();

    // أنيميشن تكبير بطيء جداً لمحاكاة حركة الفيديو (في حال كان هناك dummyImage)
    _slowZoomController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..forward();
  }

  void _initVideoPlayer() {
    if (widget.reel?.imageUrl != null && widget.reel?.mediaType == 'video') {
      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(widget.reel!.imageUrl))
            ..initialize().then((_) {
              setState(() {
                _isVideoInitialized = true;
              });
              _videoPlayerController!.setLooping(true);
              if (widget.isActive) {
                _videoPlayerController!.play();
              }
            });
    }
  }

  @override
  void didUpdateWidget(covariant ReelItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        _videoPlayerController?.play();
      } else {
        _videoPlayerController?.pause();
        _videoPlayerController?.seekTo(Duration.zero);
      }
    }
  }

  @override
  void dispose() {
    _slowZoomController.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  void _toggleLike() {
    final userId = context.read<AuthProvider>().currentUser?.id ?? '';
    if (userId.isEmpty || widget.reel == null) return;
    context.read<ReelsProvider>().toggleReelLike(widget.reel!.id, userId);
  }

  void _toggleSave() {
    final userId = context.read<AuthProvider>().currentUser?.id ?? '';
    if (userId.isEmpty || widget.reel == null) return;
    context.read<ReelsProvider>().toggleSaveReel(widget.reel!.id, userId);
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
                border: Border(
                    top: BorderSide(
                        color: Colors.amberAccent.withOpacity(0.4),
                        width: 1.5)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome,
                          color: Colors.amberAccent, size: 36)
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(duration: 1.seconds),
                  const SizedBox(height: 16),
                  const Text('تحليل سديم AI للمقطع',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildAiInsightTile(Icons.people_alt, 'الجمهور المستهدف',
                      'المهتمون بالفنون البصرية والتصوير الفوتوغرافي.'),
                  _buildAiInsightTile(Icons.insights, 'توقع التفاعل',
                      'عالٍ جداً نظراً لجودة التكوين والإضاءة المذهلة.'),
                  _buildAiInsightTile(Icons.subtitles, 'التفريغ الصوتي',
                      'لا يوجد نص منطوق في هذا الجزء من المقطع.'),
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
                Text(title,
                    style: const TextStyle(
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 4),
                Text(desc,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ).animate().fadeIn().slideX(begin: 0.1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final caption = widget.reel?.caption ??
        'رحلة بين النجوم، استكشاف المجهول في عالم سديم... ✨';
    final aiTags = widget.reel?.aiTags ?? ['تصوير', 'فن', 'أبيض وأسود'];

    // Get state from provider for optimistic UI
    final reelsProvider = context.watch<ReelsProvider>();
    final isLiked = widget.reel != null ? reelsProvider.isReelLiked(widget.reel!.id) : false;
    final isSaved = widget.reel != null ? reelsProvider.isReelSaved(widget.reel!.id) : false;

    final likesCount = (widget.reel?.likesCount ?? 0) + (isLiked ? 1 : 0); // simplistic optimistic count

    return GestureDetector(
      onTap: () {
        if (_videoPlayerController != null && _isVideoInitialized) {
          if (_videoPlayerController!.value.isPlaying) {
            _videoPlayerController!.pause();
          } else {
            _videoPlayerController!.play();
          }
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. خلفية الفيديو / الصورة
          if (_isVideoInitialized && _videoPlayerController != null)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoPlayerController!.value.size.width,
                  height: _videoPlayerController!.value.size.height,
                  child: VideoPlayer(_videoPlayerController!),
                ),
              ),
            )
          else if (widget.dummyImage != null)
            AnimatedBuilder(
              animation: _slowZoomController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_slowZoomController.value * 0.1),
                  child: Image.network(
                    widget.dummyImage!,
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.15),
                    colorBlendMode: BlendMode.darken,
                  ),
                );
              },
            )
          else
            Container(color: Colors.black),

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
                        border: Border.all(
                            color: Colors.amberAccent.withOpacity(0.5),
                            width: 1.5),
                      ),
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            NetworkImage('https://i.pravatar.cc/150?img=15'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'اسم المستخدم',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.5),
                    ),
                    const SizedBox(width: 12),
                    // زر المتابعة الزجاجي
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('متابعة',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
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
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.4,
                      shadows: [Shadow(color: Colors.black, blurRadius: 5)]),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),

                const SizedBox(height: 16),

                // الوسوم الذكية (AI Target Audience)
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: aiTags
                      .map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.amberAccent.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.auto_awesome,
                                    color: Colors.amberAccent, size: 12),
                                const SizedBox(width: 6),
                                Text(tag,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ))
                      .toList(),
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
                    GlowingHeart(
                        isLiked: isLiked, onTap: _toggleLike, size: 38),
                    const SizedBox(height: 4),
                    Text('$likesCount',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 5)
                            ])),
                  ],
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                const SizedBox(height: 24),

                Column(
                  children: [
                    IconButton(
                      icon: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: isSaved ? Colors.amberAccent : Colors.white,
                          size: 34),
                      onPressed: _toggleSave,
                    ),
                    const Text('حفظ',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 5)
                            ])),
                  ],
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),

                const SizedBox(height: 24),

                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_rounded,
                          color: Colors.white, size: 34),
                      onPressed: () {
                        if (widget.reel != null) {
                          CommentsSheet.show(context, widget.reel!.id);
                        }
                      },
                    ),
                    Text('${widget.reel?.commentsCount ?? 0}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 5)
                            ])),
                  ],
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                const SizedBox(height: 24),

                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 34),
                      onPressed: () {},
                    ),
                    const Text('مشاركة',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 5)
                            ])),
                  ],
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),

                const SizedBox(height: 30),

                // ✨ أيقونة الذكاء الاصطناعي الأنيقة
                GestureDetector(
                  onTap: () => _showAiAnalysis(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.amberAccent.withOpacity(0.2),
                      border: Border.all(
                          color: Colors.amberAccent.withOpacity(0.5),
                          width: 1.5),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.amberAccent.withOpacity(0.2),
                            blurRadius: 15,
                            spreadRadius: 2)
                      ],
                    ),
                    child: const Icon(Icons.psychology,
                        color: Colors.white, size: 28),
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.1, 1.1),
                    duration: 2.seconds),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
