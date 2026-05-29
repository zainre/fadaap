extension ClampExtension on double {
  // دالة لضمان بقاء القيمة بين حد أدنى وحد أقصى
  double clampRange(double min, double max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }

  // دالة سحرية لتحويل قيمة من نطاق إلى نطاق آخر
  double mapValue(double inMin, double inMax, double outMin, double outMax) {
    return (this - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
  }
}

extension IntClampExtension on int {
  int clampRange(int min, int max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }
}

// ✨ إضافة جديدة: تنسيق الأرقام الكبيرة بشكل احترافي (للإعجابات والمشاهدات)
extension NumFormatting on num {
  String toKMB() {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }
}

// ✨ إضافة جديدة: أدوات التعامل مع النصوص لذكاء سديم
extension StringExtensions on String {
  // تحويل أي كلمة إلى هاشتاج
  String get toHashtag => startsWith('#') ? this : '#$this';
  
  // اختصار النص الطويل مع إضافة نقاط (مفيدة للوصف)
  String limitWords(int count) {
    final words = split(' ');
    if (words.length <= count) return this;
    return '${words.take(count).join(' ')}...';
  }
}
