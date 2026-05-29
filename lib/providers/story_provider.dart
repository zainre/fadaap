import 'package:flutter/material.dart';
import '../models/story_model.dart';
import '../config/supabase_config.dart';

class StoryProvider extends ChangeNotifier {
  List<StoryModel> _stories = [];
  bool _isLoading = false;

  List<StoryModel> get stories => _stories;
  bool get isLoading => _isLoading;

  final _supabase = SupabaseConfig.client;

  Future<void> fetchStories() async {
    _isLoading = true;
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
    } catch (e) {
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
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error adding story: $e");
      return false;
    }
  }
}
