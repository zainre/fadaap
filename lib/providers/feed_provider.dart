import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../config/supabase_config.dart';

class FeedProvider extends ChangeNotifier {
  List<PostModel> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Optimistic UI state
  final Set<String> _likedPostIds = {};
  final Set<String> _savedPostIds = {};

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool isPostLiked(String postId) => _likedPostIds.contains(postId);
  bool isPostSaved(String postId) => _savedPostIds.contains(postId);

  final _supabase = SupabaseConfig.client;

  Future<void> fetchPosts({required String currentUserId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _supabase
          .from('posts')
          .select()
          .eq('media_type', 'image') // Feed gets images, Reels gets videos
          .order('created_at', ascending: false);

      _posts = (response as List).map((post) => PostModel.fromJson(post)).toList();

      // Fetch user's likes and bookmarks for optimistic UI
      final likesResponse = await _supabase.from('likes').select('post_id').eq('user_id', currentUserId);
      _likedPostIds.clear();
      for (var like in (likesResponse as List)) {
        if(like['post_id'] != null) _likedPostIds.add(like['post_id']);
      }

      final bookmarksResponse = await _supabase.from('bookmarks').select('post_id').eq('user_id', currentUserId);
      _savedPostIds.clear();
      for (var bookmark in (bookmarksResponse as List)) {
        if(bookmark['post_id'] != null) _savedPostIds.add(bookmark['post_id']);
      }

    } catch (e) {
      _errorMessage = "حدث خطأ أثناء جلب المنشورات. الرجاء المحاولة لاحقاً.";
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
    final bool wasLiked = _likedPostIds.contains(postId);

    // Optimistic Update
    if (wasLiked) {
      _likedPostIds.remove(postId);
    } else {
      _likedPostIds.add(postId);
    }
    notifyListeners();

    try {
      if (wasLiked) {
        await _supabase.from('likes').delete().eq('post_id', postId).eq('user_id', userId);
      } else {
        await _supabase.from('likes').insert({
          'post_id': postId,
          'user_id': userId,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint("Error toggling like: $e");
      // Revert Optimistic Update on failure
      if (wasLiked) {
        _likedPostIds.add(postId);
      } else {
        _likedPostIds.remove(postId);
      }
      notifyListeners();
    }
  }

  Future<void> toggleSavePost(String postId, String userId) async {
    final bool wasSaved = _savedPostIds.contains(postId);

    // Optimistic Update
    if (wasSaved) {
      _savedPostIds.remove(postId);
    } else {
      _savedPostIds.add(postId);
    }
    notifyListeners();

    try {
      if (wasSaved) {
        await _supabase.from('bookmarks').delete().eq('post_id', postId).eq('user_id', userId);
      } else {
        await _supabase.from('bookmarks').insert({
          'post_id': postId,
          'user_id': userId,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint("Error toggling save: $e");
      // Revert Optimistic Update on failure
      if (wasSaved) {
        _savedPostIds.add(postId);
      } else {
        _savedPostIds.remove(postId);
      }
      notifyListeners();
    }
  }
}
