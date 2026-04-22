// @author Rayane Rousseau
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:docflow/config/app_theme.dart';
import 'package:docflow/providers/theme_provider.dart';
import 'package:docflow/screens/launch_screen.dart';
import 'package:docflow/screens/hub_screen.dart';
import 'package:docflow/screens/vault_screen.dart';
import 'package:docflow/screens/account_screen.dart';
import 'package:docflow/screens/dashboard_screen.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const DocFlowApp(),
    ),
  );
}

class DocFlowApp extends StatelessWidget {
  const DocFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'DocFlow',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.mode,
      navigatorObservers: [routeObserver],
      initialRoute: '/launch',
      routes: {
        '/launch': (_) => const LaunchScreen(),
        '/hub': (_) => const HubScreen(),
        '/vault': (_) => const VaultScreen(),
        '/account': (_) => const AccountScreen(),
        '/dashboard': (_) => const DashboardScreen(),
      },
    );
  }
}
