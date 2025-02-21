import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_test/hive_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:postfetcher/presentation/controllers/app_controller.dart';
import 'package:path/path.dart';

class MockBox extends Mock implements Box {}

void main() {
  late Box mockBox;

  setUp(() async {
    final tempDir = await Directory.systemTemp.createTemp();
    Hive.init(tempDir.path);
    mockBox = await Hive.openBox('test_settings');
  });

  tearDown(() async {
    await mockBox.clear();
    await Hive.close();
  });

  group('AppController Theme Tests', () {
    test('Default dark theme for mobile/web platforms', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final controller = AppController(mockBox);
      expect(controller.themeMode, ThemeMode.dark);
      debugDefaultTargetPlatformOverride = null;
    });

    test('System theme default for desktop platforms', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      final controller = AppController(mockBox);
      expect(controller.themeMode, ThemeMode.system);
      debugDefaultTargetPlatformOverride = null;
    });

    test('Toggle theme mode updates state', () {
      final controller = AppController(mockBox);
      controller.toggleTheme(ThemeMode.light);
      expect(controller.themeMode, ThemeMode.light);
      expect(mockBox.get('themeMode'), 'light');
    });

    test('Defaults to dark theme on mobile/web', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final controller = AppController(mockBox);
      expect(controller.themeMode, ThemeMode.dark);
      debugDefaultTargetPlatformOverride = null;
    });

    test('Persists theme preference in Hive', () {
      final controller = AppController(mockBox);
      controller.toggleTheme(ThemeMode.light);
      expect(mockBox.get('themeMode'), 'light');
    });
  });
}
