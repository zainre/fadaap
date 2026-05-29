import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../config/supabase_config.dart';
import '../../providers/auth_provider.dart';
import '../../models/story_model.dart';
import '../../providers/story_provider.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  File? _mediaFile;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickMedia() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadStory() async {
    if (_mediaFile == null) return;

    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      final fileName = '${const Uuid().v4()}.jpg';
      final storageResponse = await SupabaseConfig.client.storage
          .from('stories')
          .upload(fileName, _mediaFile!);

      final publicUrl =
          SupabaseConfig.client.storage.from('stories').getPublicUrl(fileName);

      final story = StoryModel(
        id: const Uuid().v4(),
        userId: userId,
        mediaUrl: publicUrl,
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        createdAt: DateTime.now(),
      );

      await SupabaseConfig.client.from('stories').insert(story.toJson());

      if (mounted) {
        context.read<StoryProvider>().fetchStories();
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error uploading story: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('إنشاء قصة'),
        backgroundColor: Colors.transparent,
        actions: [
          if (_mediaFile != null)
            TextButton(
              onPressed: _isLoading ? null : _uploadStory,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(color: Colors.amberAccent))
                  : const Text('نشر',
                      style: TextStyle(
                          color: Colors.amberAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
            ),
        ],
      ),
      body: Center(
        child: _mediaFile == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_photo_alternate,
                        size: 80, color: Colors.white54),
                    onPressed: _pickMedia,
                  ),
                  const Text('اضغط لاختيار صورة',
                      style: TextStyle(color: Colors.white54, fontSize: 16)),
                ],
              )
            : Image.file(_mediaFile!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity),
      ),
    );
  }
}
