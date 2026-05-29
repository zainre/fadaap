import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../services/storage_service.dart';
import '../../services/sadeem_ai_service.dart';
import '../../services/image_generation_service.dart';
import '../../models/post_model.dart';

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
  List<String> _aiTags = [];

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
      final imageUrl = await ImageGenerationService.generateCinematicImage(prompt);

      if (imageUrl != null) {
        // Download the generated image to a temporary file
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/${const Uuid().v4()}.png');
          await file.writeAsBytes(response.bodyBytes);

          if (mounted) {
            setState(() {
              _imageFile = file;
            });
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('تم توليد الصورة بنجاح! ✨'),
                backgroundColor: Colors.green));
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('فشل تحميل الصورة المولدة.'),
                backgroundColor: Colors.redAccent));
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('فشل توليد الصورة، تحقق من مفتاح OpenAI API'),
              backgroundColor: Colors.redAccent));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('حدث خطأ أثناء الاتصال بالخادم: $e'),
            backgroundColor: Colors.redAccent));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _generateSmartCaption() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('الرجاء اختيار صورة أولاً ليتمكن سديم من وصفها.')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final bytes = await _imageFile!.readAsBytes();
      final description = await SadeemAiService.analyzeImage(bytes, 'image/jpeg');
      final caption = await SadeemAiService.generateSmartCaption(description);

      setState(() {
        _captionController.text = caption;
        _aiTags = ['سديم_الذكاء_الاصطناعي', 'فن', 'إبداع'];
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('حدث خطأ أثناء توليد الوصف.'),
          backgroundColor: Colors.redAccent));
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

    try {
      final isToxic = await SadeemAiService.isContentToxic(_captionController.text);
      if (isToxic) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('تم حظر المنشور: يحتوي على كلمات غير لائقة. سديم مجتمع آمن! 🛡️'),
            backgroundColor: Colors.redAccent));
        setState(() => _isLoading = false);
        return;
      }

      final user = context.read<AuthProvider>().currentUser;
      if (user == null) return;

      final publicUrl = await StorageService.uploadImage(_imageFile!, 'posts', userId: user.id);

      if (publicUrl != null) {
        final newPost = PostModel(
          id: const Uuid().v4(),
          userId: user.id,
          caption: _captionController.text.trim(),
          imageUrl: publicUrl,
          mediaType: 'image',
          aiTags: _aiTags,
          createdAt: DateTime.now(),
        );

        final success = await context.read<FeedProvider>().addPost(newPost);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('تم نشر إبداعك بنجاح! 🚀'),
              backgroundColor: Colors.green));
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('حدث خطأ: $e'),
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
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _generateAiImage,
                    icon: const Icon(Icons.brush, color: Colors.amberAccent),
                    label: const Text('توليد AI',
                        style: TextStyle(color: Colors.amberAccent)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent.withOpacity(0.1),
                      side: BorderSide(color: Colors.amberAccent.withOpacity(0.5)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _generateSmartCaption,
                    icon: const Icon(Icons.auto_awesome, color: Colors.amberAccent),
                    label: const Text('كابشن سحري',
                        style: TextStyle(color: Colors.amberAccent)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent.withOpacity(0.1),
                      side: BorderSide(color: Colors.amberAccent.withOpacity(0.5)),
                    ),
                  ),
                ),
              ],
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
