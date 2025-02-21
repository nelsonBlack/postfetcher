import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutx/flutx.dart';
import 'package:hive/hive.dart';
import '../controllers/app_controller.dart';

class ScaffoldWithNavigation extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavigation({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appController = FxControllerStore.putOrFind(
      AppController(Hive.box('app_settings')),
    );
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      drawer: isMobile ? _buildMobileDrawer(context) : null,
      appBar:
          isMobile
              ? AppBar(
                automaticallyImplyLeading: true,
                title: Text(_getAppBarTitle(context)),
              )
              : null,
      body:
          isMobile
              ? child
              : Row(
                children: [
                  NavigationRail(
                    extended: MediaQuery.of(context).size.width > 800,
                    backgroundColor: theme.colorScheme.surface,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.settings_outlined),
                        selectedIcon: Icon(Icons.settings),
                        label: Text('Settings'),
                      ),
                    ],
                    selectedIndex: _calculateSelectedIndex(context),
                    onDestinationSelected:
                        (index) => _onItemTapped(index, context),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          color: theme.colorScheme.surface,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              const Spacer(),
                              FxBuilder<AppController>(
                                controller: appController,
                                builder:
                                    (controller) => IconButton(
                                      icon: Icon(
                                        controller.themeMode == ThemeMode.light
                                            ? Icons.dark_mode_outlined
                                            : Icons.light_mode_outlined,
                                      ),
                                      onPressed: () {
                                        final newMode =
                                            controller.themeMode ==
                                                    ThemeMode.light
                                                ? ThemeMode.dark
                                                : ThemeMode.light;
                                        controller.toggleTheme(newMode);
                                      },
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(child: child),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  Drawer _buildMobileDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            selected: _calculateSelectedIndex(context) == 0,
            onTap: () => _onItemTapped(0, context),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            selected: _calculateSelectedIndex(context) == 1,
            onTap: () => _onItemTapped(1, context),
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle(BuildContext context) {
    final index = _calculateSelectedIndex(context);
    return index == 0 ? 'Home' : 'Settings';
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/settings')) return 1;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.goNamed('home');
        break;
      case 1:
        context.goNamed('settings');
        break;
    }
  }
}
