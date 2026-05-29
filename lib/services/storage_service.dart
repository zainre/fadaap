import 'dart:io';
import 'package:uuid/uuid.dart';
import '../config/supabase_config.dart';
import 'dart:developer' as developer;

class StorageService {
  static final _supabase = SupabaseConfig.client;

  // 📸 رفع صورة عامة أو أفاتار
  static Future<String?> uploadImage(File file, String bucketName,
      {String? userId}) async {
    try {
      final String fileName = '${const Uuid().v4()}.jpg';
      final String path =
          userId != null ? '$userId/$fileName' : 'uploads/$fileName';

      await _supabase.storage.from(bucketName).upload(path, file);

      final String publicUrl =
          _supabase.storage.from(bucketName).getPublicUrl(path);
      developer.log('✅ تم رفع الصورة بنجاح: $publicUrl',
          name: 'StorageService');
      return publicUrl;
    } catch (e) {
      developer.log('❌ خطأ في رفع الصورة', name: 'StorageService', error: e);
      return null;
    }
  }

  // 🎥 رفع فيديو (Reel أو Story)
  static Future<String?> uploadVideo(File file, String bucketName,
      {required String userId}) async {
    try {
      final String fileName = '${const Uuid().v4()}.mp4';
      final String path = '$userId/videos/$fileName';

      await _supabase.storage.from(bucketName).upload(path, file);

      final String url =
          _supabase.storage.from(bucketName).getPublicUrl(path);
      developer.log('✅ تم رفع الفيديو بنجاح', name: 'StorageService');
      return url;
    } catch (e) {
      developer.log('❌ خطأ في رفع الفيديو', name: 'StorageService', error: e);
      return null;
    }
  }

  // 🎤 رفع مقطع صوتي (Voice Note) للدردشات
  static Future<String?> uploadVoiceNote(File file, {required String userId}) async {
    try {
      final String fileName = '${const Uuid().v4()}.m4a';
      final String path = '$userId/voice_notes/$fileName';

      await _supabase.storage.from('chats').upload(path, file);

      final String url = _supabase.storage.from('chats').getPublicUrl(path);
      developer.log('✅ تم رفع المقطع الصوتي بنجاح', name: 'StorageService');
      return url;
    } catch (e) {
      developer.log('❌ خطأ في رفع المقطع الصوتي', name: 'StorageService', error: e);
      return null;
    }
  }

  // 🗑️ حذف ملف من التخزين
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
