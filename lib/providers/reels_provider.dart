import 'package:flutter/material.dart';
import '../models/post_model.dart'; // We use PostModel for Reels now (media_type = 'video')
import '../config/supabase_config.dart';

class ReelsProvider extends ChangeNotifier {
  List<PostModel> _reels = [];
  bool _isLoading = false;

  final Set<String> _likedReelIds = {};
  final Set<String> _savedReelIds = {};

  List<PostModel> get reels => _reels;
  bool get isLoading => _isLoading;

  bool isReelLiked(String reelId) => _likedReelIds.contains(reelId);
  bool isReelSaved(String reelId) => _savedReelIds.contains(reelId);

  final _supabase = SupabaseConfig.client;

  Future<void> fetchReels({required String currentUserId}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _supabase
          .from('posts')
          .select()
          .eq('media_type', 'video') // Fetch only videos
          .order('created_at', ascending: false);
      _reels =
          (response as List).map((reel) => PostModel.fromJson(reel)).toList();

      // Fetch user's likes and bookmarks for optimistic UI
      final likesResponse = await _supabase.from('likes').select('post_id').eq('user_id', currentUserId);
      _likedReelIds.clear();
      for (var like in (likesResponse as List)) {
        if(like['post_id'] != null) _likedReelIds.add(like['post_id']);
      }

      final bookmarksResponse = await _supabase.from('bookmarks').select('post_id').eq('user_id', currentUserId);
      _savedReelIds.clear();
      for (var bookmark in (bookmarksResponse as List)) {
        if(bookmark['post_id'] != null) _savedReelIds.add(bookmark['post_id']);
      }

    } catch (e) {
      debugPrint("Error fetching reels: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleReelLike(String reelId, String userId) async {
    final bool wasLiked = _likedReelIds.contains(reelId);

    // Optimistic Update
    if (wasLiked) {
      _likedReelIds.remove(reelId);
    } else {
      _likedReelIds.add(reelId);
    }
    notifyListeners();

    try {
      if (wasLiked) {
        await _supabase.from('likes').delete().eq('post_id', reelId).eq('user_id', userId);
      } else {
        await _supabase.from('likes').insert({
          'post_id': reelId,
          'user_id': userId,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint("Error toggling reel like: $e");
      // Revert on fail
      if (wasLiked) {
        _likedReelIds.add(reelId);
      } else {
        _likedReelIds.remove(reelId);
      }
      notifyListeners();
    }
  }

  Future<void> toggleSaveReel(String reelId, String userId) async {
    final bool wasSaved = _savedReelIds.contains(reelId);

    // Optimistic Update
    if (wasSaved) {
      _savedReelIds.remove(reelId);
    } else {
      _savedReelIds.add(reelId);
    }
    notifyListeners();

    try {
      if (wasSaved) {
        await _supabase.from('bookmarks').delete().eq('post_id', reelId).eq('user_id', userId);
      } else {
        await _supabase.from('bookmarks').insert({
          'post_id': reelId,
          'user_id': userId,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint("Error toggling save for reel: $e");
      if (wasSaved) {
        _savedReelIds.add(reelId);
      } else {
        _savedReelIds.remove(reelId);
      }
      notifyListeners();
    }
  }

  Future<void> recordView(String reelId) async {
    // In a real app we would call a Supabase RPC to increment view count
    debugPrint("Reel viewed: $reelId");
  }
}
