import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/router_manager_service.dart';
import 'services/network_discovery_service.dart';
import 'services/theme_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NetworkDiscoveryService()),
        ChangeNotifierProvider(create: (_) => RouterManagerService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
      ],
      child: const WifRemoteApp(),
    ),
  );
}

class WifRemoteApp extends StatelessWidget {
  const WifRemoteApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return MaterialApp(
      title: 'wifREMOTE',
      themeMode: themeService.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey.shade100,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent,
          elevation: 0,
        ),
        cardColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
        ),
        cardColor: const Color(0xFF1E1E1E),
      ),
      home: const HomeScreen(),
    );
  }
}
