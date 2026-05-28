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
    // نستخدم الـ Provider لإرسال طلب للذكاء الاصطناعي
    final provider = context.read<SadeemProvider>();
    final newBio = await provider.generateSmartCaption('اكتب نبذة شخصية (Bio) قصيرة جداً واحترافية لحسابي، أنا طالب ومبرمج مهتم بالذكاء الاصطناعي.');
    
    if (mounted) {
      setState(() {
        _bioController.text = newBio.replaceAll('#', '').trim(); // تنظيف الهاشتاجات إن وجدت
        _isLoading = false;
      });
    }
  }

  // حفظ البيانات
  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final userId = context.read<AuthProvider>().currentUser?.id;
      
      try {
        await SupabaseConfig.client.from('users').update({
          'full_name': _nameController.text.trim(),
          'username': _usernameController.text.trim(),
          'bio': _bioController.text.trim(),
        }).eq('id', userId!);

        // إعادة جلب بيانات المستخدم لتحديث الواجهة
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
        title: const Text('تعديل الملف', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.check, color: Colors.white, size: 30),
            onPressed: _isLoading ? null : _saveProfile,
          ).animate().fadeIn(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // تغيير الصورة
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 45,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        // فتح الاستوديو لاختيار صورة (يتطلب ImagePicker لاحقاً)
                      },
                      child: const Text('تغيير الصورة الشخصية', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1),
              
              const SizedBox(height: 24),

              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // حقل الاسم
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'الاسم الكامل',
                        labelStyle: TextStyle(color: Colors.grey.shade500),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade800)),
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                      ),
                      validator: (val) => val!.isEmpty ? 'الاسم مطلوب' : null,
                    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                    const SizedBox(height: 20),

                    // حقل اسم المستخدم
                    TextFormField(
                      controller: _usernameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'اسم المستخدم (Username)',
                        labelStyle: TextStyle(color: Colors.grey.shade500),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade800)),
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                      ),
                      validator: (val) => val!.isEmpty ? 'اسم المستخدم مطلوب' : null,
                    ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
                    const SizedBox(height: 20),

                    // حقل النبذة (Bio) مع زر سديم AI
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _bioController,
                            style: const TextStyle(color: Colors.white),
                            maxLines: 3,
                            minLines: 1,
                            decoration: InputDecoration(
                              labelText: 'النبذة (Bio)',
                              labelStyle: TextStyle(color: Colors.grey.shade500),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade800)),
                              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.auto_awesome, color: Colors.white),
                          tooltip: 'توليد بايو بالذكاء الاصطناعي',
                          onPressed: _generateSmartBio,
                        ).animate().pulse(duration: 2.seconds).repeat(),
                      ],
                    ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // زر تسجيل الخروج
              TextButton.icon(
                onPressed: () {
                  context.read<AuthProvider>().logout();
                  // يتم التوجيه تلقائياً لأن المستمع في main.dart سيكتشف الخروج
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text('تسجيل الخروج', style: TextStyle(color: Colors.redAccent, fontSize: 16)),
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}