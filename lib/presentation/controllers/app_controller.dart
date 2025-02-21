import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;

class AppController extends FxController {
  ThemeMode _themeMode = ThemeMode.system;
  final Box _settingsBox;

  AppController(this._settingsBox) {
    final savedMode = _settingsBox.get('themeMode');

    // Set default dark theme for mobile/web if no saved preference
    if (savedMode == null) {
      if (kIsWeb ||
          defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        _themeMode = ThemeMode.dark;
        _settingsBox.put('themeMode', _modeToString(_themeMode));
      } else {
        _themeMode = ThemeMode.system;
      }
    } else {
      _themeMode = _modeFromString(savedMode);
    }
  }

  ThemeMode get themeMode => _themeMode;

  void toggleTheme(ThemeMode mode) {
    _themeMode = mode;
    _settingsBox.put('themeMode', _modeToString(mode));
    update();
  }

  ThemeMode _modeFromString(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }

  String _modeToString(ThemeMode mode) {
    return mode.toString().split('.').last;
  }

  @override
  String getTag() => 'app_controller';
}
