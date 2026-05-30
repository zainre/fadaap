import 'package:flutter/material.dart';
import '../models/story_model.dart';
import '../config/supabase_config.dart';

class StoryProvider extends ChangeNotifier {
  List<StoryModel> _stories = [];
  Map<String, List<StoryModel>> _storiesByUser = {};
  bool _isLoading = false;

  List<StoryModel> get stories => _stories;
  Map<String, List<StoryModel>> get storiesByUser => _storiesByUser;
  bool get isLoading => _isLoading;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final _supabase = SupabaseConfig.client;

  void _updateGroupedStories() {
    _storiesByUser.clear();
    for (var story in _stories) {
      if (!_storiesByUser.containsKey(story.userId)) {
        _storiesByUser[story.userId] = [];
      }
      _storiesByUser[story.userId]!.add(story);
    }
  }

  List<String> getSortedUserIds(String? currentUserId) {
    final userIds = _storiesByUser.keys.toList();
    if (currentUserId != null) {
      userIds.remove(currentUserId);
      userIds.insert(0, currentUserId);
    }
    return userIds;
  }

  Future<void> fetchStories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final now = DateTime.now().toIso8601String();
      // Fetch stories where expires_at > current time to get stories from last 24h
      final response = await _supabase
          .from('stories')
          .select()
          .gt('expires_at', now)
          .order('created_at', ascending: false);
      _stories = (response as List)
          .map((story) => StoryModel.fromJson(story))
          .toList();
      _updateGroupedStories();
    } catch (e) {
      _errorMessage = "حدث خطأ أثناء جلب القصص.";
      debugPrint("Error fetching stories: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addStory(StoryModel story) async {
    try {
      await _supabase.from('stories').insert(story.toJson());
      _stories.insert(0, story);
      _updateGroupedStories();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error adding story: $e");
      return false;
    }
  }
}
