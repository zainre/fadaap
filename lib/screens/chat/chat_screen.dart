import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/message_model.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String peerId;
  final String peerName;
  final String peerAvatar;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.peerId,
    required this.peerName,
    required this.peerAvatar,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // جلب الرسائل والاستماع للبث المباشر (Realtime)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().fetchMessages(widget.chatId);
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final myId = context.read<AuthProvider>().currentUser?.id;
    if (myId == null) return;

    final message = MessageModel(
      id: const Uuid().v4(),
      chatId: widget.chatId,
      senderId: myId,
      content: text,
      isAiGenerated: false,
      createdAt: DateTime.now(),
    );

    context.read<ChatProvider>().sendMessage(message);
    _msgController.clear();
    
    // النزول لأسفل المحادثة
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final myId = context.watch<AuthProvider>().currentUser?.id;
    final messages = context.watch<ChatProvider>().currentMessages;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.black,
              backgroundImage: widget.peerAvatar.isNotEmpty ? NetworkImage(widget.peerAvatar) : null,
              child: widget.peerAvatar.isEmpty ? const Icon(Icons.person, color: Colors.white, size: 20) : null,
            ),
            const SizedBox(width: 10),
            Text(widget.peerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg.senderId == myId;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.amberAccent.withOpacity(0.9) : Colors.white12,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 16),
                      ),
                    ),
                    child: Text(
                      msg.content,
                      style: TextStyle(color: isMe ? Colors.black : Colors.white, fontSize: 15, fontWeight: isMe ? FontWeight.bold : FontWeight.normal),
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1),
                );
              },
            ),
          ),
          
          // حقل إدخال الرسالة
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8).copyWith(bottom: MediaQuery.of(context).padding.bottom + 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.auto_awesome, color: Colors.amberAccent),
                      onPressed: () {
                        // هنا يمكن ربط سديم لاحقاً لتوليد رد ذكي
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سديم يجهز لك الرد...')));
                      },
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(24)),
                        child: TextField(
                          controller: _msgController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'اكتب رسالة...',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.amberAccent),
                        child: const Icon(Icons.send_rounded, color: Colors.black, size: 24),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
