import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shimmer_loading.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null) {
        context.read<ChatProvider>().fetchUserChats(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.8),
        elevation: 0,
        title: const Text('الرسائل', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology, color: Colors.amberAccent),
            tooltip: 'نظرة سديم العامة',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.amberAccent),
                      SizedBox(width: 10),
                      Expanded(child: Text('سديم: معظم محادثاتك اليوم إيجابية وتدور حول التقنية!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                    ],
                  ),
                  backgroundColor: Colors.white,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 2.seconds),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          if (chatProvider.isLoading && chatProvider.chats.isEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 6,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: const ShimmerLoading(width: double.infinity, height: 85, borderRadius: 16),
              ),
            );
          }

          if (chatProvider.chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)),
                    child: const Icon(Icons.radar, color: Colors.amberAccent, size: 70)
                        .animate(onPlay: (c) => c.repeat(reverse: false))
                        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.3, 1.3), duration: 2.seconds)
                        .fadeOut(duration: 2.seconds),
                  ),
                  const SizedBox(height: 24),
                  const Text('لا توجد محادثات في الرادار.', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('ابدأ بالتواصل لتفعيل الذكاء الاصطناعي!', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                ],
              ),
            ).animate().fadeIn(duration: 800.ms);
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            itemCount: chatProvider.chats.length,
            itemBuilder: (context, index) {
              final chat = chatProvider.chats[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, a, b) => ChatScreen(chatId: chat.id),
                        transitionsBuilder: (context, a, b, child) => FadeTransition(opacity: a, child: child),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: GlassCard(
                    padding: const EdgeInsets.all(14),
                    borderRadius: 16,
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 2),
                          ),
                          child: const CircleAvatar(
                            radius: 28,
                            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=8'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('اسم الصديق', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 6),
                              Text(
                                chat.lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        if (chat.aiChatSummary != null)
                          const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 18)
                              .animate(onPlay: (c) => c.repeat(reverse: true)).scale(duration: 1.seconds)
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1),
              );
            },
          );
        },
      ),
    );
  }
}
