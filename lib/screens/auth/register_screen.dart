import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../utils/theme.dart';
import '../sadeem_center.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      final success = await authProvider.register(
        _emailController.text.trim(),
        _passwordController.text,
        _usernameController.text.trim(),
        _fullNameController.text.trim(),
      );

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SadeemCenterScreen()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'فشل التسجيل'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppTheme.blackColor,
      body: Stack(
        children: [
          // خلفية سديم - تم تصحيح مكان الـ Filter هنا
          Positioned(
            top: -100,
            right: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.amberAccent.withOpacity(0.15),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.blur_on,
                              size: 80, color: Colors.amberAccent)
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(duration: 2.seconds),
                      const SizedBox(height: 20),
                      const Text(
                        'صناعة هوية جديدة',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ).animate().fadeIn(duration: 600.ms),
                      const SizedBox(height: 40),
                      TextFormField(
                        controller: _fullNameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                            labelText: 'الاسم الكامل',
                            prefixIcon: Icon(Icons.person)),
                        validator: (val) => val == null || val.isEmpty
                            ? 'الاسم الكامل مطلوب'
                            : null,
                      ).animate().fadeIn(delay: 100.ms).slideX(),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _usernameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                            labelText: 'اسم المستخدم',
                            prefixIcon: Icon(Icons.alternate_email)),
                        validator: Validators.validateUsername,
                      ).animate().fadeIn(delay: 200.ms).slideX(),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                            labelText: 'البريد الإلكتروني',
                            prefixIcon: Icon(Icons.email_outlined)),
                        validator: Validators.validateEmail,
                      ).animate().fadeIn(delay: 300.ms).slideX(),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        style: const TextStyle(color: Colors.white),
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: Validators.validatePassword,
                      ).animate().fadeIn(delay: 400.ms).slideX(),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        style: const TextStyle(color: Colors.white),
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'تأكيد كلمة المرور',
                          prefixIcon: const Icon(Icons.lock_reset),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () => setState(() =>
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword),
                          ),
                        ),
                        validator: (val) {
                          if (val != _passwordController.text)
                            return 'كلمات المرور غير متطابقة';
                          return null;
                        },
                      ).animate().fadeIn(delay: 500.ms).slideX(),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amberAccent),
                          child: isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.black, strokeWidth: 2))
                              : const Text('إنشاء حساب',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                        ),
                      ).animate().fadeIn(delay: 600.ms).slideY(),

                      const SizedBox(height: 16),
                      // زر التسجيل بواسطة جوجل
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton.icon(
                          onPressed: isLoading ? null : () async {
                            final authProvider = context.read<AuthProvider>();
                            final success = await authProvider.signInWithGoogle();
                            if (success && mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const SadeemCenterScreen()),
                              );
                            } else if (mounted && authProvider.errorMessage != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(authProvider.errorMessage!,
                                      style: const TextStyle(color: Colors.white)),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.g_mobiledata, size: 36, color: Colors.white),
                          label: const Text('التسجيل باستخدام Google',
                              style: TextStyle(color: Colors.white, fontSize: 16)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white30),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 700.ms)
                          .scale(begin: const Offset(0.9, 0.9)),

                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen())),
                        child: const Text('لديك حساب بالفعل؟ تسجيل الدخول',
                            style: TextStyle(color: Colors.white70)),
                      ).animate().fadeIn(delay: 800.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
