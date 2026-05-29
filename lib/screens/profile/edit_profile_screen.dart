import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sadeem_provider.dart';
import '../../config/supabase_config.dart';
import '../../widgets/glass_card.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // توليد بايو عبر سديم AI
  void _generateSmartBio() async {
    setState(() => _isLoading = true);
    final provider = context.read<SadeemProvider>();
    final newBio = await provider.generateSmartCaption('اكتب نبذة شخصية (Bio) قصيرة جداً واحترافية لحسابي، أنا طالب ومبرمج مهتم بالذكاء الاصطناعي.');
    
    if (mounted) {
      setState(() {
        _bioController.text = newBio.replaceAll('#', '').trim();
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✨ تم توليد البايو السحري بنجاح!', style: TextStyle(color: Colors.black)), backgroundColor: Colors.amberAccent),
      );
    }
  }

  // حفظ البيانات
  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final userId = context.read<AuthProvider>().currentUser?.id;
      
      try {
        // تم إصلاح الخطأ القاتل هنا: users تم تغييرها إلى profiles
        await SupabaseConfig.client.from('profiles').update({
          'full_name': _nameController.text.trim(),
          'username': _usernameController.text.trim(),
          'bio': _bioController.text.trim(),
        }).eq('id', userId!);

        if (mounted) {
          await context.read<AuthProvider>().loadCurrentUser();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تحديث الملف الشخصي!', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('حدث خطأ: $e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('تعديل الحساب', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            icon: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.check, color: Colors.greenAccent, size: 30),
            onPressed: _isLoading ? null : _saveProfile,
          ).animate().fadeIn(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // تغيير الصورة بشكل فخم
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
                    ),
                    Container(
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.black, size: 20),
                        onPressed: () {
                          // سيتم ربط الاستوديو لاحقاً
                        },
                      ),
                    ).animate().scale(delay: 300.ms),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1),
              
              const SizedBox(height: 30),

              GlassCard(
                padding: const EdgeInsets.all(24),
                borderRadius: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // حقل الاسم
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'الاسم الكامل',
                        labelStyle: TextStyle(color: Colors.grey.shade400),
                        prefixIcon: const Icon(Icons.person, color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade800)),
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                      ),
                      validator: (val) => val!.isEmpty ? 'الاسم مطلوب' : null,
                    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                    const SizedBox(height: 24),

                    // حقل اليوزر
                    TextFormField(
                      controller: _usernameController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'اسم المستخدم',
                        labelStyle: TextStyle(color: Colors.grey.shade400),
                        prefixIcon: const Icon(Icons.alternate_email, color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade800)),
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                      ),
                      validator: (val) => val!.isEmpty ? 'اسم المستخدم مطلوب' : null,
                    ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
                    const SizedBox(height: 24),

                    // حقل البايو
                    TextFormField(
                      controller: _bioController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      maxLines: 3,
                      minLines: 1,
                      decoration: InputDecoration(
                        labelText: 'النبذة الشخصية (Bio)',
                        labelStyle: TextStyle(color: Colors.grey.shade400),
                        prefixIcon: const Icon(Icons.info_outline, color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade800)),
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                    
                    const SizedBox(height: 20),
                    
                    // زر توليد بايو بالذكاء الاصطناعي (أصبح بارزاً وفخماً)
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _generateSmartBio,
                        icon: const Icon(Icons.auto_awesome, color: Colors.black),
                        label: const Text('كتابة بايو سحري (سديم AI)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amberAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
