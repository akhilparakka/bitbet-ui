import 'package:flutter/foundation.dart';

/// Debug utilities for performance-optimized logging
/// All debug prints are wrapped in assert() to ensure they're stripped in release builds
class DebugUtils {
  DebugUtils._(); // Private constructor

  /// Print debug message - automatically stripped in release builds
  static void log(String message) {
    assert(() {
      debugPrint(message);
      return true;
    }());
  }

  /// Print debug message with emoji prefix for better visibility
  static void logInfo(String message) {
    assert(() {
      debugPrint('ℹ️ $message');
      return true;
    }());
  }

  /// Print success message
  static void logSuccess(String message) {
    assert(() {
      debugPrint('✅ $message');
      return true;
    }());
  }

  /// Print warning message
  static void logWarning(String message) {
    assert(() {
      debugPrint('⚠️ $message');
      return true;
    }());
  }

  /// Print error message
  static void logError(String message) {
    assert(() {
      debugPrint('❌ $message');
      return true;
    }());
  }

  /// Print section header for grouping logs
  static void logSection(String title) {
    assert(() {
      debugPrint('');
      debugPrint('=== $title ===');
      return true;
    }());
  }
}
