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
      final response = await _supabase
          .from('reels')
          .select()
          .order('created_at', ascending: false);
      
      _reels = (response as List).map((reel) => ReelModel.fromJson(reel)).toList();
    } catch (e) {
      debugPrint("Error fetching reels: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}