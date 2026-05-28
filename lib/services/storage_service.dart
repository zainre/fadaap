import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../config/supabase_config.dart';

class StorageService {
  static final _supabase = SupabaseConfig.client;

  // رفع صورة (سواء للملف الشخصي أو للمنشورات) وإرجاع الرابط العام
  static Future<String?> uploadImage(File file, String bucketName) async {
    try {
      final String fileName = '${const Uuid().v4()}.jpg';
      final String path = 'uploads/$fileName';
      
      await _supabase.storage.from(bucketName).upload(path, file);
      
      // جلب الرابط العام للصورة لعرضها في التطبيق
      final String publicUrl = _supabase.storage.from(bucketName).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      return null;
    }
  }

  // رفع فيديو (مخصص لقسم الـ Reels)
  static Future<String?> uploadVideo(File file) async {
    try {
      final String fileName = '${const Uuid().v4()}.mp4';
      final String path = 'reels/$fileName';
      
      await _supabase.storage.from('reels_bucket').upload(path, file);
      
      return _supabase.storage.from('reels_bucket').getPublicUrl(path);
    } catch (e) {
      return null;
    }
  }

  // حذف ملف من التخزين (عند حذف منشور مثلاً)
  static Future<bool> deleteFile(String bucketName, String path) async {
    try {
      await _supabase.storage.from(bucketName).remove([path]);
      return true;
    } catch (e) {
      return false;
    }
  }
}