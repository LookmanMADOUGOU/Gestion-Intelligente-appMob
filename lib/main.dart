import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/config/app_config.dart';
import 'core/storage/local_cache_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation des configurations runtime et du cache local SharedPreferences
  await AppConfig.init();
  await LocalCacheService.init();

  runApp(
    const ProviderScope(
      child: SmartTechApp(),
    ),
  );
}
