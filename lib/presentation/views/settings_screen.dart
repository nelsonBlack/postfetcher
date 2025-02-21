import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:hive/hive.dart';
import '../controllers/app_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appController = FxControllerStore.putOrFind(
      AppController(Hive.box('app_settings')),
    );

    return _buildSettingsContent(theme, appController);
  }

  Widget _buildSettingsContent(ThemeData theme, AppController appController) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        ListTile(
          title: Text('Theme Mode', style: theme.textTheme.titleMedium),
          trailing: FxBuilder<AppController>(
            controller: appController,
            builder:
                (controller) => DropdownButton<ThemeMode>(
                  value: controller.themeMode,
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('System'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark'),
                    ),
                  ],
                  onChanged: (mode) {
                    if (mode != null) controller.toggleTheme(mode);
                  },
                ),
          ),
        ),
        const SizedBox(height: 16),
        // Add more settings here
      ],
    );
  }
}
