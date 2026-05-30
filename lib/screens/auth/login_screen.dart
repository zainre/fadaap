import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/glass_card.dart';
import 'register_screen.dart';
import '../sadeem_center.dart'; // مسار الشاشة الرئيسية

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // إغلاق لوحة المفاتيح
      FocusScope.of(context).unfocus();

      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تسجيل الدخول بنجاح! مرحباً بك في سديم.',
                style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.white,
          ),
        );

        // كود الانتقال الفعلي إلى الشاشة الرئيسية (هذا هو المفتاح المفقود!)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SadeemCenterScreen()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'حدث خطأ.',
                style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.grey.shade900,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // الشعار أو اسم التطبيق مع تأثير الوميض
              const Icon(Icons.blur_on, size: 80, color: Colors.white)
                  .animate(
                      onPlay: (controller) => controller.repeat(reverse: true))
                  .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1.1, 1.1),
                      duration: 2000.ms),
              const SizedBox(height: 16),
              const Text(
                'ســديــم',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
              ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2, end: 0),
              const SizedBox(height: 8),
              Text(
                'عالمك المدار بالذكاء الاصطناعي',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade400),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 40),

              // بطاقة زجاجية تحتوي على فورم الدخول
              GlassCard(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // حقل البريد الإلكتروني
                      TextFormField(
                        controller: _emailController,
                        validator: Validators.validateEmail,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'البريد الإلكتروني',
                          labelStyle: TextStyle(color: Colors.grey.shade500),
                          enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey.shade800)),
                          focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          prefixIcon: const Icon(Icons.email_outlined,
                              color: Colors.white),
                        ),
                      ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                      const SizedBox(height: 20),

                      // حقل كلمة المرور
                      TextFormField(
                        controller: _passwordController,
                        validator: Validators.validatePassword,
                        style: const TextStyle(color: Colors.white),
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          labelStyle: TextStyle(color: Colors.grey.shade500),
                          enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey.shade800)),
                          focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: Colors.white),
                        ),
                      ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),
                      const SizedBox(height: 40),

                      // زر الدخول
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.black, strokeWidth: 2),
                                )
                              : const Text('دخول',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 600.ms)
                          .scale(begin: const Offset(0.9, 0.9)),

                      const SizedBox(height: 16),
                      // زر الدخول بواسطة جوجل
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
                                  backgroundColor: Colors.grey.shade900,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.g_mobiledata, size: 36, color: Colors.white),
                          label: const Text('الدخول باستخدام Google',
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
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

              const SizedBox(height: 24),

              // زر الانتقال للتسجيل
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const RegisterScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                    ),
                  );
                },
                child: Text(
                  'ليس لديك حساب؟ سجل الآن',
                  style: TextStyle(color: Colors.grey.shade300, fontSize: 16),
                ),
              ).animate().fadeIn(delay: 700.ms),
            ],
          ),
        ),
      ),
    );
  }
}
