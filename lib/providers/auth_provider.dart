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

  // جلب بيانات المستخدم الحالي إذا كان مسجلاً مسبقاً
  Future<void> loadCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      _isLoading = true;
      notifyListeners();
      try {
        final response = await _supabase.from('profiles').select().eq('id', user.id).single();
        _currentUser = UserModel.fromJson(response);
      } catch (e) {
        _errorMessage = e.toString();
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // تسجيل الدخول
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
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

  // إنشاء حساب جديد
  Future<bool> register(String email, String password, String username, String fullName) async {
    _setLoading(true);
    try {
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      if (res.user != null) {
        // تجهيز بيانات المستخدم
        final newUser = UserModel(
          id: res.user!.id,
          username: username,
          fullName: fullName,
          email: email,
          avatarUrl: '', // يمكن تعيين صورة افتراضية لاحقاً
          bio: 'مرحباً، أنا أستخدم سديم!',
          createdAt: DateTime.now(),
        );
        
        // استخدام upsert بدلاً من insert لحل مشكلة التصادم نهائياً
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

  // تسجيل الخروج
  Future<void> logout() async {
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
