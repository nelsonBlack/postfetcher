import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:postfetcher/data/models/post_model.dart';
import 'core/constants/app_constants.dart';
import 'core/config/router_config.dart';
import 'core/config/url_strategy.dart';
import 'presentation/controllers/app_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure URL strategy for web
  configureUrl();

  // Initialize Hive with web support
  if (kIsWeb) {
    await Hive.initFlutter('posts_db'); // Name for IndexedDB database
  } else {
    await Hive.initFlutter();
  }

  Hive.registerAdapter(PostModelAdapter());
  final settingsBox = await Hive.openBox('app_settings');
  final postsBox = await Hive.openBox<PostModel>('posts_cache');

  final appController = FxControllerStore.putOrFind(AppController(settingsBox));

  runApp(
    FxBuilder<AppController>(
      controller: appController,
      builder:
          (controller) => Builder(
            builder:
                (context) => MaterialApp.router(
                  title: 'F4E Posts',
                  debugShowCheckedModeBanner: false,
                  theme: AppConstants.getTheme(context, controller.themeMode),
                  darkTheme: AppConstants.getTheme(
                    context,
                    controller.themeMode,
                  ),
                  themeMode: controller.themeMode,
                  routerConfig: routerConfig,
                ),
          ),
    ),
  );
}
