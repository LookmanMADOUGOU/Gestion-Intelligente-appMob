import 'dart:io';

enum Environment { dev, staging, prod }

class EnvironmentConfig {
  static const Environment current = Environment.dev;

  /// Détecte l'URL locale appropriée selon la plateforme
  static String get defaultBaseUrl {
    // Si Android Emulator -> 10.0.2.2 redirige vers la machine hôte
    // Si iOS Simulator -> 127.0.0.1 ou localhost
    // Si Desktop / Web -> 127.0.0.1
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000/api';
      } else if (Platform.isIOS) {
        return 'http://127.0.0.1:8000/api';
      }
    } catch (_) {
      // Fallback web / tests
    }
    return 'http://127.0.0.1:8000/api';
  }

  static const String prodBaseUrl = 'https://api.smarttech.example.com/api';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
