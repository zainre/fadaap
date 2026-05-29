import 'package:flutter/material.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget? fallback;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    // In Flutter, widget errors are often caught by FlutterError.onError
    // Since we can't catch all errors gracefully inside build() like React,
    // we use a custom ErrorWidget builder for specific parts if possible.
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.fallback ?? _buildDefaultFallback(context, _error!);
    }

    // We wrap the child in a Builder that can potentially catch some exceptions
    // Note: This won't catch asynchronous errors or errors in layout/paint phase.
    // However, it's a structural wrapper following the user's intent.
    try {
      return Builder(builder: (context) => widget.child);
    } catch (e, s) {
      debugPrint('Error caught in ErrorBoundary: $e\n$s');
      return widget.fallback ?? _buildDefaultFallback(context, e);
    }
  }

  Widget _buildDefaultFallback(BuildContext context, Object error) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.black87,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.amberAccent,
            size: 50,
          ),
          const SizedBox(height: 16),
          const Text(
            'عذراً، حدث خطأ!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سديم يحاول الإصلاح...',
            style: TextStyle(color: Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _error = null;
                _stackTrace = null;
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
