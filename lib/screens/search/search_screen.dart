import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/supabase_service.dart';
import '../../widgets/shimmer_loading.dart';
import '../profile/user_profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    // تأخير بسيط لمنع الضغط على قاعدة البيانات مع كل حرف
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final results = await SupabaseService.searchUsers(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'ابحث عن أصدقائك...',
            hintStyle: TextStyle(color: Colors.grey.shade600),
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  )
                : null,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return ListView.builder(
        itemCount: 5,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              const ShimmerLoading(width: 50, height: 50, borderRadius: 25),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerLoading(width: 150, height: 14, borderRadius: 4),
                  SizedBox(height: 8),
                  ShimmerLoading(width: 100, height: 12, borderRadius: 4),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (_searchController.text.isNotEmpty && _searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search_outlined,
                size: 80, color: Colors.grey.shade800),
            const SizedBox(height: 16),
            Text('لم نجد أحداً بهذا الاسم',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
          ],
        ).animate().fadeIn(),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Text('اكتشف مجرة سديم...',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        final avatar = user['avatar_url']?.toString() ?? '';
        final hasBadge = user['developer_badge'] == true;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade900,
            backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
            child: avatar.isEmpty
                ? const Icon(Icons.person, color: Colors.white54)
                : null,
          ),
          title: Row(
            children: [
              Text(user['username'] ?? '',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              if (hasBadge) const SizedBox(width: 4),
              if (hasBadge)
                const Icon(Icons.verified, color: Colors.amberAccent, size: 16),
            ],
          ),
          subtitle: Text(user['full_name'] ?? '',
              style: TextStyle(color: Colors.grey.shade500)),
          onTap: () {
            // الانتقال إلى بروفايل المستخدم الحقيقي
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserProfileScreen(userId: user['id']),
              ),
            );
          },
        ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1);
      },
    );
  }
}
