// @author Rayane Rousseau
import 'package:flutter/material.dart';
import 'package:docflow/config/app_theme.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AppHeader({super.key, this.title = 'DocFlow'});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: kPrimary,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 22,
          letterSpacing: 1.2,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.person_outline_rounded, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/account'),
        ),
      ],
    );
  }
}
