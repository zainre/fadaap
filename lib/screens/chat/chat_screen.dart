import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../../models/message_model.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sadeem_provider.dart';
import '../../services/sadeem_ai_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<String> _quickReplies = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().fetchMessages(widget.chatId);
      _generateQuickReplies("مرحباً، كيف حالك اليوم؟"); 
    });
  }

  Future<void> _generateQuickReplies(String lastMessage) async {
    final replies = await SadeemAiService.suggestQuickReplies(lastMessage);
    if (mounted) {
      setState(() => _quickReplies = replies);
    }
  }

  void _sendMessage({String? aiText}) async {
    final text = aiText ?? _messageController.text.trim();
    if (text.isEmpty) return;

    final userId = context.read<AuthProvider>().currentUser?.id ?? '';
    if (userId.isEmpty) return;

    final newMessage = MessageModel(
      id: const Uuid().v4(),
      chatId: widget.chatId,
      senderId: userId,
      content: text,
      isAiGenerated: aiText != null, 
      createdAt: DateTime.now(),
    );

    _messageController.clear();
    setState(() {
      _quickReplies = []; 
      _isTyping = false;
    });

    await context.read<ChatProvider>().sendMessage(newMessage);
    
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  // ✨ ميزة الكاتب السحري (تنبثق من الأسفل)
  void _showMagicCompose() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final TextEditingController promptController = TextEditingController();
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  border: Border(top: BorderSide(color: Colors.amberAccent.withOpacity(0.3), width: 1)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.amberAccent),
                        SizedBox(width: 10),
                        Text('ماذا تريد أن يكتب لك سديم؟', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: promptController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'مثال: اكتب اعتذاراً لبقاً عن التأخير...',
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            // محاكاة وضع النص (لاحقاً نربطها بـ AI Service)
                            _messageController.text = "[مسودة سديم]: بناءً على طلبك، أعتذر جداً عن التأخير، سأكون معك قريباً.";
                            _isTyping = true;
                          });
                        },
                        child: const Text('كتابة سحرية', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthProvider>().currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            CircleAvatar(radius: 18, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=8')),
            SizedBox(width: 10),
            Text('اسم الصديق', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.summarize_outlined, color: Colors.amberAccent),
            tooltip: 'تلخيص المحادثة',
            onPressed: () async {
              final messages = context.read<ChatProvider>().currentMessages.map((m) => m.content).toList();
              final summary = await context.read<SadeemProvider>().summarizeChat(messages);
              if (mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.grey.shade900,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.amberAccent),
                        SizedBox(width: 8),
                        Text('ملخص سديم الذكي', style: TextStyle(color: Colors.white, fontSize: 18)),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(summary, style: const TextStyle(color: Colors.white, height: 1.5)),
                        const SizedBox(height: 24),
                        // ✨ البصمة المخفية (Zain's Easter Egg)
                        const Text(
                          '✨ Powered by Zain\'s AI',
                          style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.white38),
                        ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(color: Colors.amberAccent, duration: 2.seconds),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('حسناً', style: TextStyle(color: Colors.amberAccent)),
                      )
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF0F0F1A), Colors.black],
            radius: 1.5,
            center: Alignment.center,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  final messages = chatProvider.currentMessages.reversed.toList(); 
                  
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(16.0),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == currentUserId;

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.white : Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: Radius.circular(isMe ? 20 : 0),
                              bottomRight: Radius.circular(isMe ? 0 : 20),
                            ),
                            // تمييز رسائل الذكاء الاصطناعي بحدود ذهبية مضيئة
                            border: msg.isAiGenerated 
                                ? Border.all(color: Colors.amberAccent.withOpacity(0.5), width: 1.5)
                                : isMe ? null : Border.all(color: Colors.white.withOpacity(0.1)),
                            boxShadow: msg.isAiGenerated 
                                ? [BoxShadow(color: Colors.amberAccent.withOpacity(0.1), blurRadius: 10, spreadRadius: 1)]
                                : [],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.content,
                                style: TextStyle(
                                  color: isMe ? Colors.black : Colors.white,
                                  fontSize: 15,
                                  height: 1.3,
                                ),
                              ),
                              if (msg.isAiGenerated)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.auto_awesome, color: isMe ? Colors.amber.shade700 : Colors.amberAccent, size: 12),
                                      const SizedBox(width: 4),
                                      Text('سُيغت بواسطة سديم', style: TextStyle(color: isMe ? Colors.amber.shade700 : Colors.amberAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ).animate().fadeIn().slideY(begin: 0.1),
                      );
                    },
                  );
                },
              ),
            ),

            // الردود السريعة (Neon Pills)
            if (_quickReplies.isNotEmpty)
              SizedBox(
                height: 55,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: _quickReplies.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                      child: GestureDetector(
                        onTap: () => _sendMessage(aiText: _quickReplies[index]),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.amberAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.amberAccent.withOpacity(0.3)),
                          ),
                          alignment: Alignment.center,
                          child: Text(_quickReplies[index], style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold)),
                        ).animate().fadeIn(delay: (index * 100).ms).scale(),
                      ),
                    );
                  },
                ),
              ),

            // منطقة الإدخال
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // ✨ زر الكاتب السحري
                    IconButton(
                      icon: const Icon(Icons.auto_awesome, color: Colors.amberAccent),
                      onPressed: _showMagicCompose,
                    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 2.seconds),
                    
                    // حقل الإدخال
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(color: Colors.white),
                          onChanged: (val) {
                            setState(() => _isTyping = val.isNotEmpty);
                          },
                          decoration: const InputDecoration(
                            hintText: 'اكتب رسالتك...',
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // زر الإرسال
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: _isTyping ? Colors.white : Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.send_rounded, color: _isTyping ? Colors.black : Colors.white54, size: 22),
                        onPressed: _isTyping ? () => _sendMessage() : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
