import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle between dark and light themes'),
            secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
            value: isDark,
            onChanged: (value) {
              themeService.toggleTheme();
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('About wifREMOTE'),
            subtitle: const Text('Version 1.0.0'),
            leading: const Icon(Icons.info),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'wifREMOTE',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.wifi, size: 50, color: Colors.blueAccent),
              );
            },
          ),
        ],
      ),
    );
  }
}
