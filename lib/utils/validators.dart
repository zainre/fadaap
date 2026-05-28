class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'البريد الإلكتروني مطلوب.';
    final regex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!regex.hasMatch(value)) return 'صيغة البريد الإلكتروني غير صحيحة.';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'كلمة المرور مطلوبة.';
    if (value.length < 6) return 'كلمة المرور يجب أن لا تقل عن 6 أحرف.';
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) return 'اسم المستخدم مطلوب.';
    if (value.length < 3) return 'اسم المستخدم قصير جداً.';
    return null;
  }
}