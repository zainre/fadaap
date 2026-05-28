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
      _generateQuickReplies("مرحباً، كيف حالك اليوم؟"); // محاكاة لآخر رسالة
    });
  }

  // توليد ردود سريعة عبر سديم AI
  Future<void> _generateQuickReplies(String lastMessage) async {
    final replies = await SadeemAiService.suggestQuickReplies(lastMessage);
    if (mounted) {
      setState(() {
        _quickReplies = replies;
      });
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
      isAiGenerated: aiText != null, // تحديد إذا كانت الرسالة من الذكاء الاصطناعي
      createdAt: DateTime.now(),
    );

    _messageController.clear();
    setState(() => _quickReplies = []); // إخفاء الردود السريعة بعد الإرسال

    await context.read<ChatProvider>().sendMessage(newMessage);
    
    // التمرير لأسفل عند إرسال رسالة جديدة
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0, // لأننا نستخدم reverse: true في القائمة
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=8'),
            ),
            const SizedBox(width: 10),
            const Text('اسم الصديق', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.summarize_outlined, color: Colors.white),
            tooltip: 'تلخيص المحادثة',
            onPressed: () async {
              // استدعاء دالة التلخيص من Provider
              final messages = context.read<ChatProvider>().currentMessages.map((m) => m.content).toList();
              final summary = await context.read<SadeemProvider>().summarizeChat(messages);
              if (mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.grey.shade900,
                    title: const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.white),
                        SizedBox(width: 8),
                        Text('ملخص سديم الذكي', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    content: Text(summary, style: const TextStyle(color: Colors.white)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('حسناً', style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. قائمة الرسائل
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                final messages = chatProvider.currentMessages.reversed.toList(); // الأحدث بالأسفل
                
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, // يبدأ من الأسفل
                  padding: const EdgeInsets.all(16.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == currentUserId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.white : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(20),
                            topRight: const Radius.circular(20),
                            bottomLeft: Radius.circular(isMe ? 20 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 20),
                          ),
                          border: isMe ? null : Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.content,
                              style: TextStyle(
                                color: isMe ? Colors.black : Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            if (msg.isAiGenerated)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.auto_awesome, color: isMe ? Colors.grey.shade700 : Colors.grey.shade400, size: 12),
                                    const SizedBox(width: 4),
                                    Text('رد ذكي', style: TextStyle(color: isMe ? Colors.grey.shade700 : Colors.grey.shade400, fontSize: 10)),
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

          // 2. الردود السريعة المقترحة بالذكاء الاصطناعي (تظهر فوق صندوق الإدخال)
          if (_quickReplies.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _quickReplies.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                    child: ActionChip(
                      backgroundColor: Colors.black,
                      side: BorderSide(color: Colors.white.withOpacity(0.3)),
                      label: Text(_quickReplies[index], style: const TextStyle(color: Colors.white)),
                      onPressed: () => _sendMessage(aiText: _quickReplies[index]),
                    ).animate().fadeIn(delay: (index * 100).ms).scale(),
                  );
                },
              ),
            ),

          // 3. منطقة إدخال النص
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // زر استخدام الذكاء الاصطناعي لكتابة الرسالة
                  IconButton(
                    icon: const Icon(Icons.auto_awesome, color: Colors.white),
                    onPressed: () {
                       // ميزة كتابة رسالة كاملة بالذكاء الاصطناعي
                      _messageController.text = "اكتب لي رسالة اعتذار أنيقة...";
                    },
                  ),
                  
                  // حقل الإدخال
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: Colors.white),
                        onChanged: (val) {
                          setState(() {
                            _isTyping = val.isNotEmpty;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'اكتب رسالة...',
                          hintStyle: TextStyle(color: Colors.grey),
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
                      color: _isTyping ? Colors.white : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send, color: _isTyping ? Colors.black : Colors.grey.shade600),
                      onPressed: _isTyping ? () => _sendMessage() : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}