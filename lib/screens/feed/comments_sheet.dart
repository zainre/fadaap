import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';

import '../../config/supabase_config.dart';
import '../../models/comment_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/sadeem_ai_service.dart';
import '../../widgets/shimmer_loading.dart';

class CommentsSheet extends StatefulWidget {
  final String postId;

  const CommentsSheet({super.key, required this.postId});

  static void show(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CommentsSheet(postId: postId),
      ),
    );
  }

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final _supabase = SupabaseConfig.client;
  final _commentController = TextEditingController();
  List<CommentModel> _comments = [];
  bool _isLoading = true;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchComments() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('comments')
          .select()
          .eq('post_id', widget.postId)
          .order('created_at', ascending: false);

      setState(() {
        _comments =
            (response as List).map((c) => CommentModel.fromJson(c)).toList();
      });
    } catch (e) {
      debugPrint('Error fetching comments: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _postComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;

    setState(() => _isPosting = true);

    try {
      // الذكاء الاصطناعي للإشراف وتحليل المشاعر
      final isToxic = await SadeemAiService.isContentToxic(content);

      // لو كان التعليق سلبيا جدا، نمنعه!
      if (isToxic) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حجب هذا التعليق لمخالفته إرشادات مجتمع سديم 🛡️'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }

      final newComment = CommentModel(
        id: const Uuid().v4(),
        postId: widget.postId,
        userId: userId,
        content: content,
        aiSentiment: 'positive',
        createdAt: DateTime.now(),
      );

      // Optimistic Update
      setState(() {
        _comments.insert(0, newComment);
        _commentController.clear();
      });

      await _supabase.from('comments').insert(newComment.toJson());
    } catch (e) {
      debugPrint('Error posting comment: $e');
      // In a real app, revert the optimistic update here if insertion fails.
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1)),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('التعليقات',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.white.withOpacity(0.1), height: 1),

              // Comments List
              Expanded(
                child: _isLoading
                    ? ListView.builder(
                        itemCount: 5,
                        itemBuilder: (context, index) => const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: ShimmerLoading(
                              width: double.infinity,
                              height: 60,
                              borderRadius: 8),
                        ),
                      )
                    : _comments.isEmpty
                        ? const Center(
                            child: Text('لا توجد تعليقات بعد.',
                                style: TextStyle(color: Colors.white54)))
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: _comments.length,
                            itemBuilder: (context, index) {
                              final comment = _comments[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const CircleAvatar(
                                      radius: 18,
                                      backgroundImage: NetworkImage(
                                          'https://i.pravatar.cc/150?img=1'),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Text('مستخدم',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14)),
                                              const SizedBox(width: 8),
                                              Text('الآن',
                                                  style: TextStyle(
                                                      color: Colors.grey.shade500,
                                                      fontSize: 12)),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(comment.content,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14)),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.favorite_border,
                                          color: Colors.white54, size: 16),
                                      onPressed: () {},
                                    ),
                                  ],
                                ).animate().fadeIn(delay: (index * 50).ms),
                              );
                            },
                          ),
              ),

              // Input Field
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border(
                      top: BorderSide(
                          color: Colors.white.withOpacity(0.1), width: 1)),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundImage:
                          NetworkImage('https://i.pravatar.cc/150?img=5'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'إضافة تعليق...',
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    _isPosting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.amberAccent))
                        : IconButton(
                            icon: const Icon(Icons.send,
                                color: Colors.amberAccent),
                            onPressed: _postComment,
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
