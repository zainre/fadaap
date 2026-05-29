import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../config/supabase_config.dart';
import 'dart:developer' as developer;

class StorageService {
  static final _supabase = SupabaseConfig.client;

  // رفع صورة وإرجاع الرابط العام
  static Future<String?> uploadImage(File file, String bucketName, {String? userId}) async {
    try {
      final String fileName = '${const Uuid().v4()}.jpg';
      // ✨ ترتيب الملفات في مجلدات بأسماء المستخدمين إذا توفر الـ ID
      final String path = userId != null ? '$userId/$fileName' : 'uploads/$fileName';
      
      await _supabase.storage.from(bucketName).upload(path, file);
      
      final String publicUrl = _supabase.storage.from(bucketName).getPublicUrl(path);
      developer.log('✅ تم رفع الصورة بنجاح: $publicUrl', name: 'StorageService');
      return publicUrl;
    } catch (e) {
      developer.log('❌ خطأ في رفع الصورة', name: 'StorageService', error: e);
      return null;
    }
  }

  // رفع فيديو لقسم الـ Reels
  static Future<String?> uploadVideo(File file, {required String userId}) async {
    try {
      final String fileName = '${const Uuid().v4()}.mp4';
      final String path = '$userId/reels/$fileName'; // تنظيم الفيديوهات
      
      await _supabase.storage.from('reels_bucket').upload(path, file);
      
      final String url = _supabase.storage.from('reels_bucket').getPublicUrl(path);
      developer.log('✅ تم رفع الفيديو بنجاح', name: 'StorageService');
      return url;
    } catch (e) {
      developer.log('❌ خطأ في رفع الفيديو', name: 'StorageService', error: e);
      return null;
    }
  }

  // حذف ملف من التخزين
  static Future<bool> deleteFile(String bucketName, String path) async {
    try {
      await _supabase.storage.from(bucketName).remove([path]);
      developer.log('✅ تم حذف الملف بنجاح: $path', name: 'StorageService');
      return true;
    } catch (e) {
      developer.log('❌ خطأ في حذف الملف', name: 'StorageService', error: e);
      return false;
    }
  }
}
