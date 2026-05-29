import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../../config/supabase_config.dart';
import '../../widgets/shimmer_loading.dart';
import 'chat_screen.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  void _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isLoading = true);
    final results = await SupabaseService.searchUsers(query);

    // إخفاء المستخدم الحالي من نتائج البحث (لا يمكنه محادثة نفسه)
    final myId = context.read<AuthProvider>().currentUser?.id;
    results.removeWhere((user) => user['id'] == myId);

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }
  }

  Future<void> _startChat(Map<String, dynamic> peerUser) async {
    final myId = context.read<AuthProvider>().currentUser?.id;
    if (myId == null) return;

    final supabase = SupabaseConfig.client;

    // 1. التحقق مما إذا كانت المحادثة موجودة مسبقاً
    final existingChats = await supabase
        .from('chats')
        .select()
        .contains('participant_ids', [myId, peerUser['id']]);

    String chatId;

    if (existingChats.isNotEmpty) {
      chatId = existingChats.first['id'];
    } else {
      // 2. إنشاء محادثة جديدة في قاعدة البيانات
      chatId = const Uuid().v4();
      await supabase.from('chats').insert({
        'id': chatId,
        'participant_ids': [myId, peerUser['id']],
        'last_message': 'بدأت المحادثة',
        'last_message_time': DateTime.now().toIso8601String(),
        'unread_count': 0,
      });
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: chatId,
            peerId: peerUser['id'],
            peerName: peerUser['username'],
            peerAvatar: peerUser['avatar_url'] ?? '',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: TextField(
          controller: _searchController,
          onChanged: _searchUsers,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'ابحث عن صديق للمراسلة...',
            hintStyle: TextStyle(color: Colors.grey.shade600),
            border: InputBorder.none,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.amberAccent))
          : ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final user = _searchResults[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade900,
                    backgroundImage: user['avatar_url'] != null &&
                            user['avatar_url'].toString().isNotEmpty
                        ? NetworkImage(user['avatar_url'])
                        : null,
                    child: user['avatar_url'] == null ||
                            user['avatar_url'].toString().isEmpty
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  title: Text(user['username'],
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(user['full_name'],
                      style: TextStyle(color: Colors.grey.shade500)),
                  onTap: () => _startChat(user),
                ).animate().fadeIn().slideX();
              },
            ),
    );
  }
}
