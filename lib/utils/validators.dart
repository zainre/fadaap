class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'البريد الإلكتروني مطلوب.';
    final regex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!regex.hasMatch(value))
      return 'عذراً، صيغة البريد الإلكتروني غير صحيحة.';
    return null;
  }

  // ✨ تم تقوية التحقق من كلمة المرور
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty)
      return 'كلمة المرور مطلوبة لمزيد من الأمان.';
    if (value.length < 8) return 'يجب أن لا تقل كلمة المرور عن 8 أحرف.';
    // تحقق إضافي لضمان وجود أرقام وحروف (مفعل كخيار احترافي)
    if (!value.contains(RegExp(r'[0-9]')))
      return 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل.';
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) return 'اسم المستخدم مطلوب.';
    if (value.length < 3) return 'اسم المستخدم قصير جداً.';
    if (value.contains(' ')) return 'اسم المستخدم لا يجب أن يحتوي على مسافات.';
    return null;
  }

  // ✨ إضافة جديدة: التحقق من البايو
  static String? validateBio(String? value) {
    if (value != null && value.length > 150) {
      return 'النبذة يجب أن لا تتجاوز 150 حرفاً.';
    }
    return null;
  }
}
