import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthProvider() {
    _initAuthState();
  }

  void _initAuthState() {
    _firebaseAuth.authStateChanges().listen((User? user) {
      if (user != null) {
        loadCurrentUser();
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> loadCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      _isLoading = true;
      notifyListeners();
      try {
        final response = await _supabase
            .from('profiles')
            .select()
            .eq('id', user.uid)
            .single();
        _currentUser = UserModel.fromJson(response);

        // ✨ تحديث حالة الاتصال لتكون "متصل الآن"
        await _supabase
            .from('profiles')
            .update({'is_online': true}).eq('id', user.uid);
      } catch (e) {
        _errorMessage = e.toString();
        // If the profile doesn't exist yet, it will fail here.
        // It's handled during registration/login.
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      await loadCurrentUser();
      return true;
    } on FirebaseAuthException catch (_) {
      _errorMessage = "البريد الإلكتروني أو كلمة المرور غير صحيحة.";
      return false;
    } catch (e) {
      _errorMessage = "حدث خطأ غير متوقع.";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        _setLoading(false);
        return false; // User canceled
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // The Bridge: Upsert to Supabase
        await _upsertSupabaseProfile(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
          photoUrl: user.photoURL,
        );

        await loadCurrentUser();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = "فشل تسجيل الدخول باستخدام جوجل.";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(
      String email, String password, String username, String fullName) async {
    _setLoading(true);
    try {
      final UserCredential res =
          await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

      if (res.user != null) {
        final newUser = UserModel(
          id: res.user!.uid,
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
    } on FirebaseAuthException catch (_) {
      _errorMessage = "حدث خطأ أثناء التسجيل، يرجى التأكد من البيانات والمحاولة مجدداً.";
      return false;
    } catch (e) {
      _errorMessage = "حدث خطأ غير متوقع أثناء التسجيل.";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _upsertSupabaseProfile({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      // Check if profile exists
      final existing = await _supabase.from('profiles').select().eq('id', uid).maybeSingle();
      if (existing == null) {
        final username = displayName != null && displayName.isNotEmpty
            ? displayName.replaceAll(' ', '').toLowerCase()
            : email.split('@').first;

        final newUser = UserModel(
          id: uid,
          username: username,
          fullName: displayName ?? username,
          email: email,
          avatarUrl: photoUrl ?? '',
          bio: 'مرحباً، أنا أستخدم سديم!',
          isOnline: true,
          createdAt: DateTime.now(),
        );

        await _supabase.from('profiles').upsert(newUser.toJson());
      }
    } catch (e) {
      debugPrint('Error upserting profile: $e');
    }
  }

  Future<void> logout() async {
    if (_currentUser != null) {
      try {
        // ✨ تسجيل الخروج وحفظ آخر ظهور
        await _supabase.from('profiles').update({
          'is_online': false,
          'last_seen': DateTime.now().toIso8601String(),
        }).eq('id', _currentUser!.id);
      } catch (e) {
        // Ignore errors if profile update fails on logout
      }
    }
    await _firebaseAuth.signOut();
    final GoogleSignIn googleSignIn = GoogleSignIn();
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut();
    }
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _errorMessage = null;
    notifyListeners();
  }
}
