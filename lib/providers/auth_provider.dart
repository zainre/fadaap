import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../config/supabase_config.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  final _supabase = SupabaseConfig.client;

  Future<void> loadCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      _isLoading = true;
      notifyListeners();
      try {
        final response = await _supabase.from('profiles').select().eq('id', user.id).single();
        _currentUser = UserModel.fromJson(response);
        
        // ✨ تحديث حالة الاتصال لتكون "متصل الآن"
        await _supabase.from('profiles').update({'is_online': true}).eq('id', user.id);
      } catch (e) {
        _errorMessage = e.toString();
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final AuthResponse res = await _supabase.auth.signInWithPassword(email: email, password: password);
      if (res.user != null) {
        await loadCurrentUser();
        return true;
      }
      return false;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = "حدث خطأ غير متوقع.";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String email, String password, String username, String fullName) async {
    _setLoading(true);
    try {
      final AuthResponse res = await _supabase.auth.signUp(email: email, password: password);
      if (res.user != null) {
        final newUser = UserModel(
          id: res.user!.id,
          username: username,
          fullName: fullName,
          email: email,
          avatarUrl: '', 
          bio: 'مرحباً، أنا أستخدم سديم!',
          isOnline: true, // متصل فور التسجيل
          createdAt: DateTime.now(),
        );
        
        await _supabase.from('profiles').upsert(newUser.toJson());
        _currentUser = newUser;
        return true;
      }
      return false;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = "حدث خطأ غير متوقع أثناء التسجيل.";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    if (_currentUser != null) {
      // ✨ تسجيل الخروج وحفظ آخر ظهور
      await _supabase.from('profiles').update({
        'is_online': false,
        'last_seen': DateTime.now().toIso8601String(),
      }).eq('id', _currentUser!.id);
    }
    await _supabase.auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _errorMessage = null;
    notifyListeners();
  }
}
