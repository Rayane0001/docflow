// @author Rayane Rousseau
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:docflow/config/app_theme.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    Future.delayed(const Duration(seconds: 3), _navigate);
  }

  void _navigate() {
    if (mounted) Navigator.pushReplacementNamed(context, '/hub');
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimary,
      body: FadeTransition(
        opacity: _fade,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.folder_special_rounded,
                    size: 52, color: kAccent),
              ),
              const SizedBox(height: 24),
              const Text(
                'DocFlow',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Powered by Flux AI',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.65), fontSize: 15),
              ),
              const SizedBox(height: 56),
              const SpinKitFadingCircle(color: kAccent, size: 44),
            ],
          ),
        ),
      ),
    );
  }
}
