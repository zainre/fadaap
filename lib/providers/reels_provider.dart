import 'package:flutter/material.dart';
import '../models/reel_model.dart';
import '../config/supabase_config.dart';

class ReelsProvider extends ChangeNotifier {
  List<ReelModel> _reels = [];
  bool _isLoading = false;

  List<ReelModel> get reels => _reels;
  bool get isLoading => _isLoading;

  final _supabase = SupabaseConfig.client;

  Future<void> fetchReels() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _supabase.from('reels').select().order('created_at', ascending: false);
      _reels = (response as List).map((reel) => ReelModel.fromJson(reel)).toList();
    } catch (e) {
      debugPrint("Error fetching reels: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✨ ميزة جديدة: تسجيل الإعجاب للريلز
  Future<void> toggleReelLike(String reelId, String userId) async {
    try {
      final existingLike = await _supabase.from('likes').select().eq('reel_id', reelId).eq('user_id', userId).maybeSingle();

      if (existingLike != null) {
        await _supabase.from('likes').delete().eq('id', existingLike['id']);
      } else {
        await _supabase.from('likes').insert({
          'reel_id': reelId,
          'user_id': userId,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint("Error toggling reel like: $e");
    }
  }

  // ✨ ميزة جديدة: زيادة عداد المشاهدات للريلز عند تشغيله
  Future<void> recordView(String reelId) async {
    // يمكن ربطها لاحقاً بـ RPC في Supabase لزيادة العداد تلقائياً
    debugPrint("Reel viewed: $reelId");
  }
}
