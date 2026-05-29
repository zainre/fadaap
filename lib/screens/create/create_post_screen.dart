import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sadeem_provider.dart';
import '../../config/supabase_config.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _generateAiImage() async {
    final prompt = _captionController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('الرجاء كتابة وصف خيالي للصورة في حقل النص أدناه أولاً.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final generatedFile =
          await context.read<SadeemProvider>().generateImage(prompt);
      if (generatedFile != null) {
        setState(() => _imageFile = generatedFile);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('تم توليد الصورة بنجاح! ✨'),
            backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('فشل توليد الصورة، تحقق من الـ API Key في ملف .env'),
            backgroundColor: Colors.redAccent));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadPost() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء اختيار صورة أولاً.')));
      return;
    }

    setState(() => _isLoading = true);
    final user = context.read<AuthProvider>().currentUser;
    final postId = const Uuid().v4();
    final fileName = '${user!.id}/$postId.jpg';

    try {
      // 1. رفع الصورة إلى Supabase Storage (يجب أن يكون لديك Bucket باسم 'posts')
      await SupabaseConfig.client.storage
          .from('posts')
          .upload(fileName, _imageFile!);
      final imageUrl =
          SupabaseConfig.client.storage.from('posts').getPublicUrl(fileName);

      // 2. حفظ بيانات المنشور في جدول posts
      await SupabaseConfig.client.from('posts').insert({
        'id': postId,
        'user_id': user.id,
        'image_url': imageUrl,
        'caption': _captionController.text.trim(),
        'likes_count': 0,
        'comments_count': 0,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('تم نشر إبداعك بنجاح! 🚀'),
            backgroundColor: Colors.green));
        Navigator.pop(context); // العودة للشاشة الرئيسية
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'حدث خطأ، تأكد من إنشاء مساحة التخزين (Bucket) باسم posts: $e'),
            backgroundColor: Colors.redAccent));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('منشور جديد',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.amberAccent, strokeWidth: 2)))
              : TextButton(
                  onPressed: _uploadPost,
                  child: const Text('نشر',
                      style: TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_isLoading && _imageFile == null)
              const SizedBox(
                height: 350,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.amberAccent),
                      SizedBox(height: 16),
                      Text('سديم ينسج خيالك... ✨',
                          style: TextStyle(
                              color: Colors.amberAccent,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 350,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white24, style: BorderStyle.solid),
                    image: _imageFile != null
                        ? DecorationImage(
                            image: FileImage(_imageFile!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _imageFile == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                size: 60, color: Colors.grey.shade600),
                            const SizedBox(height: 12),
                            const Text('اضغط لاختيار صورة',
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 16)),
                          ],
                        )
                      : null,
                ),
              ).animate().fadeIn().scale(curve: Curves.easeOutBack),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _generateAiImage,
              icon: const Icon(Icons.auto_awesome, color: Colors.amberAccent),
              label: const Text('توليد صورة سحرية بالذكاء الاصطناعي ✨',
                  style: TextStyle(
                      color: Colors.amberAccent, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amberAccent.withOpacity(0.1),
                side: BorderSide(color: Colors.amberAccent.withOpacity(0.5)),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 24),
            TextField(
              controller: _captionController,
              style: const TextStyle(color: Colors.white),
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'اكتب وصفاً لإبداعك...',
                hintStyle: TextStyle(color: Colors.white34),
                border: InputBorder.none,
              ),
            ).animate().fadeIn(delay: 200.ms),
          ],
        ),
      ),
    );
  }
}
