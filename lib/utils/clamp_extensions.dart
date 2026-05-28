extension ClampExtension on double {
  // دالة لضمان بقاء القيمة بين حد أدنى وحد أقصى
  double clampRange(double min, double max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }

  // دالة سحرية لتحويل قيمة من نطاق إلى نطاق آخر
  // (مثال: تحويل تمرير الشاشة من 0-100 إلى شفافية من 0.0 إلى 1.0)
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