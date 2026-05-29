import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import '../../config/supabase_config.dart';
import '../../providers/auth_provider.dart';
import '../../models/reel_model.dart';
import '../../providers/reels_provider.dart';

class CreateReelScreen extends StatefulWidget {
  const CreateReelScreen({super.key});

  @override
  State<CreateReelScreen> createState() => _CreateReelScreenState();
}

class _CreateReelScreenState extends State<CreateReelScreen> {
  File? _videoFile;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  VideoPlayerController? _videoPlayerController;
  final TextEditingController _captionController = TextEditingController();

  Future<void> _pickVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _videoFile = File(pickedFile.path);
        _videoPlayerController = VideoPlayerController.file(_videoFile!)
          ..initialize().then((_) {
            setState(() {});
            _videoPlayerController!.play();
            _videoPlayerController!.setLooping(true);
          });
      });
    }
  }

  Future<void> _uploadReel() async {
    if (_videoFile == null) return;

    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      final fileName = '${const Uuid().v4()}.mp4';
      await SupabaseConfig.client.storage
          .from('reels')
          .upload(fileName, _videoFile!);

      final publicUrl = SupabaseConfig.client.storage
          .from('reels')
          .getPublicUrl(fileName);

      final reel = ReelModel(
        id: const Uuid().v4(),
        userId: userId,
        videoUrl: publicUrl,
        caption: _captionController.text,
        aiTargetAudience: [],
        createdAt: DateTime.now(),
      );

      await SupabaseConfig.client.from('reels').insert(reel.toJson());

      if (mounted) {
        context.read<ReelsProvider>().fetchReels();
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error uploading reel: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('نشر ريلز'),
        backgroundColor: Colors.transparent,
        actions: [
          if (_videoFile != null)
            TextButton(
              onPressed: _isLoading ? null : _uploadReel,
              child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.amberAccent))
                : const Text('نشر', style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: _videoFile == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.video_library, size: 80, color: Colors.white54),
                        onPressed: _pickVideo,
                      ),
                      const Text('اضغط لاختيار فيديو', style: TextStyle(color: Colors.white54, fontSize: 16)),
                    ],
                  )
                : _videoPlayerController != null && _videoPlayerController!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _videoPlayerController!.value.aspectRatio,
                        child: VideoPlayer(_videoPlayerController!),
                      )
                    : const CircularProgressIndicator(),
          ),
          if (_videoFile != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.black.withOpacity(0.5),
                child: TextField(
                  controller: _captionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'اكتب وصفاً للريلز...',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
