import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../config/supabase_config.dart';

class FeedProvider extends ChangeNotifier {
  List<PostModel> _posts = [];
  bool _isLoading = false;

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;

  final _supabase = SupabaseConfig.client;

  Future<void> fetchPosts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _supabase.from('posts').select().order('created_at', ascending: false);
      _posts = (response as List).map((post) => PostModel.fromJson(post)).toList();
    } catch (e) {
      debugPrint("Error fetching posts: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addPost(PostModel post) async {
    try {
      await _supabase.from('posts').insert(post.toJson());
      _posts.insert(0, post); 
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error adding post: $e");
      return false;
    }
  }

  Future<void> toggleLike(String postId, String userId) async {
    try {
      final existingLike = await _supabase.from('likes').select().eq('post_id', postId).eq('user_id', userId).maybeSingle();

      if (existingLike != null) {
        await _supabase.from('likes').delete().eq('id', existingLike['id']);
      } else {
        await _supabase.from('likes').insert({
          'post_id': postId,
          'user_id': userId,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint("Error toggling like: $e");
    }
  }

  // ✨ ميزة جديدة: حفظ المنشور في المفضلة
  Future<void> toggleSavePost(String postId, String userId) async {
    // سيتم تنفيذها لاحقاً لربطها بجدول المحفوظات (Bookmarks)
    debugPrint("Post saved: $postId");
  }
}
