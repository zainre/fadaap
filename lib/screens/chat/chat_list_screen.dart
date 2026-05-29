import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../config/supabase_config.dart';
import '../../widgets/shimmer_loading.dart';
import 'chat_screen.dart';
import 'new_chat_screen.dart';

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

  // دالة لجلب بيانات الطرف الآخر في المحادثة
  Future<Map<String, dynamic>> _getPeerUser(String peerId) async {
    final response = await SupabaseConfig.client
        .from('profiles')
        .select('username, avatar_url')
        .eq('id', peerId)
        .single();
    return response;
  }

  @override
  Widget build(BuildContext context) {
    final myId = context.watch<AuthProvider>().currentUser?.id;
    final chatProvider = context.watch<ChatProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('الرسائل',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square, color: Colors.amberAccent),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const NewChatScreen()));
            },
          ),
        ],
      ),
      body: chatProvider.isLoading && chatProvider.chats.isEmpty
          ? _buildLoading()
          : chatProvider.chats.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: chatProvider.chats.length,
                  itemBuilder: (context, index) {
                    final chat = chatProvider.chats[index];
                    // تحديد من هو الطرف الآخر في المحادثة
                    final peerId = chat.participantIds
                        .firstWhere((id) => id != myId, orElse: () => myId!);

                    return FutureBuilder<Map<String, dynamic>>(
                      future: _getPeerUser(peerId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return const SizedBox(
                              height: 72); // مساحة فارغة حتى يتم التحميل

                        final peerName = snapshot.data!['username'] ?? 'مستخدم';
                        final peerAvatar = snapshot.data!['avatar_url'] ?? '';

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.grey.shade900,
                            backgroundImage: peerAvatar.isNotEmpty
                                ? NetworkImage(peerAvatar)
                                : null,
                            child: peerAvatar.isEmpty
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                          ),
                          title: Text(peerName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          subtitle: Text(
                            chat.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  chatId: chat.id,
                                  peerId: peerId,
                                  peerName: peerName,
                                  peerAvatar: peerAvatar,
                                ),
                              ),
                            );
                          },
                        )
                            .animate()
                            .fadeIn(delay: (index * 50).ms)
                            .slideX(begin: 0.1);
                      },
                    );
                  },
                ),
    );
  }

  Widget _buildLoading() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const ShimmerLoading(width: 56, height: 56, borderRadius: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerLoading(width: 120, height: 16, borderRadius: 4),
                  SizedBox(height: 8),
                  ShimmerLoading(
                      width: double.infinity, height: 14, borderRadius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline,
              size: 80, color: Colors.grey.shade800),
          const SizedBox(height: 16),
          Text('لا توجد رسائل حتى الآن.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const NewChatScreen())),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.amberAccent),
            child: const Text('بدء محادثة',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ).animate().fadeIn(),
    );
  }
}
