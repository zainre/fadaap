import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/supabase_config.dart';
import '../../providers/auth_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _supabase = SupabaseConfig.client;
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;

    try {
      final response = await _supabase.from('notifications').select('''
            *,
            sender:sender_id (id, username, avatar_url)
          ''').eq('user_id', userId).order('created_at', ascending: false);

      setState(() {
        _notifications = List<Map<String, dynamic>>.from(response);
      });

      // Update unread status
      final unreadIds = _notifications
          .where((n) => !(n['is_read'] ?? false))
          .map((n) => n['id'] as String)
          .toList();

      if (unreadIds.isNotEmpty) {
        await _supabase
            .from('notifications')
            .update({'is_read': true}).inFilter('id', unreadIds);
      }
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.chat_bubble;
      case 'follow':
        return Icons.person_add;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'like':
        return Colors.redAccent;
      case 'comment':
        return Colors.blueAccent;
      case 'follow':
        return Colors.greenAccent;
      default:
        return Colors.amberAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('الإشعارات',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.amberAccent))
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.notifications_off_outlined,
                          size: 80, color: Colors.white24),
                      const SizedBox(height: 16),
                      const Text('لا توجد إشعارات حتى الآن.',
                          style:
                              TextStyle(color: Colors.white54, fontSize: 16)),
                    ],
                  ).animate().fadeIn(),
                )
              : RefreshIndicator(
                  color: Colors.black,
                  backgroundColor: Colors.amberAccent,
                  onRefresh: _fetchNotifications,
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) => Divider(
                        color: Colors.white.withOpacity(0.05), height: 1),
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      final sender = notification['sender'] ?? {};
                      final type = notification['type'] as String? ?? '';
                      final isRead = notification['is_read'] as bool? ?? false;
                      final content = notification['content'] ?? 'قام بالتفاعل معك.';

                      return Container(
                        color: isRead
                            ? Colors.transparent
                            : Colors.white.withOpacity(0.05),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.grey.shade900,
                                backgroundImage: sender['avatar_url'] != null
                                    ? NetworkImage(sender['avatar_url'])
                                    : null,
                                child: sender['avatar_url'] == null
                                    ? const Icon(Icons.person,
                                        color: Colors.white54)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: _getColorForType(type),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.black, width: 2),
                                  ),
                                  child: Icon(_getIconForType(type),
                                      color: Colors.white, size: 10),
                                ),
                              ),
                            ],
                          ),
                          title: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                              children: [
                                TextSpan(
                                    text: '${sender['username'] ?? 'مستخدم'} ',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                TextSpan(
                                    text: content),
                              ],
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text('منذ قليل',
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 12)),
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('الانتقال قيد التطوير...'))
                            );
                          },
                        ).animate().fadeIn(delay: (index * 50).ms),
                      );
                    },
                  ),
                ),
    );
  }
}
