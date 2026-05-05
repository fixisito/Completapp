import 'package:flutter/foundation.dart';

class PrefsUtils {
  static void logError(String context, Object error, [StackTrace? stackTrace]) {
    debugPrint('[$context] $error');
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }
}
