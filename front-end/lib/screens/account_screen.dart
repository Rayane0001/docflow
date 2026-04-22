// @author Rayane Rousseau
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:docflow/config/app_theme.dart';
import 'package:docflow/providers/theme_provider.dart';
import 'package:docflow/widgets/app_header.dart';
import 'package:docflow/widgets/nav_bar.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: const AppHeader(title: 'Account'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: kPrimary,
                  child: const Icon(Icons.person, size: 52, color: Colors.white),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: kAccent,
                    child: const Icon(Icons.edit, size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Rayane Rousseau',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
          const Center(
            child: Text(
              'Rayane Rousseau',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 32),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle:
                      const Text('Switch between light and dark theme'),
                  value: themeProvider.isDark,
                  activeColor: kAccent,
                  onChanged: (_) => themeProvider.toggle(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.folder_special_rounded),
                  title: const Text('About DocFlow'),
                  subtitle: const Text('v1.0.0 — Powered by Flux AI'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading:
                      Icon(Icons.logout_rounded, color: Colors.red[400]),
                  title: Text('Sign Out',
                      style: TextStyle(color: Colors.red[400])),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const NavBar(currentIndex: 3),
    );
  }
}
