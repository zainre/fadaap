import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../config/supabase_config.dart';
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
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false;
  String? _recordingPath;
  String? _currentlyPlayingPath;
  bool _isPlaying = false;

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
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final path = '${dir.path}/${const Uuid().v4()}.m4a';
        await _audioRecorder.start(const RecordConfig(), path: path);
        setState(() {
          _isRecording = true;
          _recordingPath = path;
        });
      }
    } catch (e) {
      debugPrint("Error starting record: $e");
    }
  }

  Future<void> _stopRecordingAndSend() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });

      if (path != null) {
        final file = File(path);
        final fileName = '${const Uuid().v4()}.m4a';

        await SupabaseConfig.client.storage
            .from('chats')
            .upload(fileName, file);
        final publicUrl =
            SupabaseConfig.client.storage.from('chats').getPublicUrl(fileName);

        final myId = context.read<AuthProvider>().currentUser?.id;
        if (myId == null) return;

        final message = MessageModel(
          id: const Uuid().v4(),
          chatId: widget.chatId,
          senderId: myId,
          content: '🎤 رسالة صوتية',
          mediaUrl: publicUrl,
          isAiGenerated: false,
          createdAt: DateTime.now(),
        );

        context.read<ChatProvider>().sendMessage(message);
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint("Error stopping record: $e");
    }
  }

  Future<void> _playPauseAudio(String url) async {
    if (_currentlyPlayingPath == url && _isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      await _audioPlayer.play(UrlSource(url));
      setState(() {
        _currentlyPlayingPath = url;
        _isPlaying = true;
      });
      _audioPlayer.onPlayerComplete.listen((event) {
        if (mounted) setState(() => _isPlaying = false);
      });
    }
  }

  void _scrollToBottom() {
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
    _scrollToBottom();
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
              backgroundImage: widget.peerAvatar.isNotEmpty
                  ? NetworkImage(widget.peerAvatar)
                  : null,
              child: widget.peerAvatar.isEmpty
                  ? const Icon(Icons.person, color: Colors.white, size: 20)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(widget.peerName,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isMe
                          ? Colors.amberAccent.withOpacity(0.9)
                          : Colors.white12,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 16),
                      ),
                    ),
                    child: msg.mediaUrl != null &&
                            msg.mediaUrl!.endsWith('.m4a')
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  _currentlyPlayingPath == msg.mediaUrl &&
                                          _isPlaying
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_fill,
                                  color: isMe ? Colors.black : Colors.white,
                                ),
                                onPressed: () => _playPauseAudio(msg.mediaUrl!),
                              ),
                              Text(msg.content,
                                  style: TextStyle(
                                      color:
                                          isMe ? Colors.black : Colors.white)),
                            ],
                          )
                        : Text(
                            msg.content,
                            style: TextStyle(
                                color: isMe ? Colors.black : Colors.white,
                                fontSize: 15,
                                fontWeight:
                                    isMe ? FontWeight.bold : FontWeight.normal),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8)
                    .copyWith(
                        bottom: MediaQuery.of(context).padding.bottom + 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.1))),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.auto_awesome,
                          color: Colors.amberAccent),
                      onPressed: () {
                        // هنا يمكن ربط سديم لاحقاً لتوليد رد ذكي
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('سديم يجهز لك الرد...')));
                      },
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(24)),
                        child: TextField(
                          controller: _msgController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'اكتب رسالة...',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        if (_msgController.text.trim().isNotEmpty) {
                          _sendMessage();
                        }
                      },
                      onLongPress: _startRecording,
                      onLongPressUp: _stopRecordingAndSend,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isRecording
                                ? Colors.redAccent
                                : Colors.amberAccent),
                        child: Icon(
                            _isRecording ? Icons.mic : Icons.send_rounded,
                            color: Colors.black,
                            size: 24),
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
