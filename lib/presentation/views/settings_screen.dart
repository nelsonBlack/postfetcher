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
          title: Text(
            'Theme Mode',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          trailing: FxBuilder<AppController>(
            controller: appController,
            builder:
                (controller) => Theme(
                  data: Theme.of(
                    controller.context,
                  ).copyWith(canvasColor: theme.colorScheme.surface),
                  child: DropdownButton<ThemeMode>(
                    value: controller.themeMode,
                    dropdownColor: theme.colorScheme.surface,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    items: [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text(
                          'System',
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text(
                          'Light',
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text(
                          'Dark',
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                      ),
                    ],
                    onChanged: (mode) {
                      if (mode != null) controller.toggleTheme(mode);
                    },
                  ),
                ),
          ),
        ),
        const SizedBox(height: 16),
        // Add more settings here
      ],
    );
  }
}
