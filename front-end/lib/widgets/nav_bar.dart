// @author Rayane Rousseau
import 'package:flutter/material.dart';
import 'package:docflow/config/app_theme.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;

  const NavBar({super.key, required this.currentIndex});

  void _navigate(BuildContext ctx, int index) {
    const routes = ['/hub', '/vault', '/dashboard', '/account'];
    final target = routes[index];
    if (ModalRoute.of(ctx)?.settings.name != target) {
      Navigator.pushReplacementNamed(ctx, target);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (i) => _navigate(context, i),
      indicatorColor: kAccent.withOpacity(0.2),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.folder_outlined),
          selectedIcon: Icon(Icons.folder_rounded),
          label: 'Vault',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart_rounded),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Account',
        ),
      ],
    );
  }
}
