import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../config/supabase_config.dart';

class FeedProvider extends ChangeNotifier {
  List<PostModel> _posts = [];
  bool _isLoading = false;

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;

  final _supabase = SupabaseConfig.client;

  // جلب المنشورات من الأحدث للأقدم
  Future<void> fetchPosts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _supabase
          .from('posts')
          .select()
          .order('created_at', ascending: false);
      
      _posts = (response as List).map((post) => PostModel.fromJson(post)).toList();
    } catch (e) {
      debugPrint("Error fetching posts: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // إضافة منشور جديد
  Future<bool> addPost(PostModel post) async {
    try {
      await _supabase.from('posts').insert(post.toJson());
      _posts.insert(0, post); // إضافته لأعلى القائمة محلياً لتسريع العرض
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error adding post: $e");
      return false;
    }
  }

  // تسجيل الإعجاب (أو إزالته)
  Future<void> toggleLike(String postId, String userId) async {
    try {
      // التحقق مما إذا كان المستخدم قد أعجب بالمنشور مسبقاً
      final existingLike = await _supabase
          .from('likes')
          .select()
          .eq('post_id', postId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingLike != null) {
        // إزالة الإعجاب
        await _supabase.from('likes').delete().eq('id', existingLike['id']);
      } else {
        // إضافة إعجاب
        await _supabase.from('likes').insert({
          'post_id': postId,
          'user_id': userId,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
      // إعادة جلب المنشورات لتحديث العدادات (في تطبيق حقيقي نستخدم Realtime)
      await fetchPosts();
    } catch (e) {
      debugPrint("Error toggling like: $e");
    }
  }
}