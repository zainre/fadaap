import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/env_loader.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;
  late GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    // إعداد نموذج سديم الذكي
    final apiKey =
        EnvLoader.geminiKeys.isNotEmpty ? EnvLoader.geminiKeys.first : '';

    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(
          'أنت لست مجرد نموذج لغوي، أنت المساعد الذكي الخاص بتطبيق سديم. مهمتك تقديم الإلهام للمستخدمين. أجب باختصار وأسلوب محبب.'),
    );

    _messages.add({
      'sender': 'ai',
      'text':
          'أهلاً بك في غرفة القيادة. أنا المُرشِد الذكي لتطبيق "سديم". كيف يمكنني مساعدتك اليوم؟'
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_msgController.text.trim().isEmpty) return;

    final userText = _msgController.text.trim();
    setState(() {
      _messages.add({'sender': 'user', 'text': userText});
      _isTyping = true;
    });
    _msgController.clear();
    _scrollToBottom();

    try {
      final response = await _model.generateContent([Content.text(userText)]);

      if (response.text != null && mounted) {
        setState(() {
          _messages.add({'sender': 'ai', 'text': response.text!});
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'sender': 'ai',
            'text':
                'عذراً، يبدو أن هناك تشويشاً في الاتصال عبر مجرة سديم. تحقق من المفاتيح.'
          });
        });
        _scrollToBottom();
      }
    } finally {
      if (mounted) setState(() => _isTyping = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.blur_on, color: Colors.amberAccent)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.1, 1.1),
                    duration: 2.seconds),
            const SizedBox(width: 8),
            const Text('مُرشِد سديم',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child:
                          CircularProgressIndicator(color: Colors.amberAccent),
                    ),
                  );
                }

                final msg = _messages[index];
                final isAI = msg['sender'] == 'ai';

                return Align(
                  alignment:
                      isAI ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isAI ? 0 : 20),
                        bottomRight: Radius.circular(isAI ? 20 : 0),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isAI
                                ? Colors.amberAccent.withOpacity(0.15)
                                : Colors.white.withOpacity(0.05),
                            border: Border.all(
                                color: isAI
                                    ? Colors.amberAccent.withOpacity(0.5)
                                    : Colors.white.withOpacity(0.1)),
                          ),
                          child: Text(
                            msg['text']!,
                            style: TextStyle(
                                color:
                                    isAI ? Colors.amber.shade100 : Colors.white,
                                fontSize: 15,
                                height: 1.5),
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1),
                );
              },
            ),
          ),

          // حقل الإدخال الزجاجي
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12)
                        .copyWith(
                            bottom: MediaQuery.of(context).padding.bottom + 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.1))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(25),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: TextField(
                          controller: _msgController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'اسأل سديم...',
                            hintStyle:
                                TextStyle(color: Colors.white.withOpacity(0.4)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _isTyping ? null : _sendMessage,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.amberAccent),
                        child: const Icon(Icons.auto_awesome,
                            color: Colors.black, size: 22),
                      ),
                    ).animate(target: _isTyping ? 0 : 1).scale(),
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
