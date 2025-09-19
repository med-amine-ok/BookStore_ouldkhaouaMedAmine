import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Duration _splashDuration = Duration(seconds: 2);
  final AuthService _auth = AuthService();
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _initializeNavigation();
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  void _initializeNavigation() {
    _navigationTimer = Timer(_splashDuration, _decideNext);
  }

  void _decideNext() {
    if (!mounted) return;

    final bool isLoggedIn = _auth.isAuthenticated;

    if (isLoggedIn) {
      
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 244, 225),
      body: const _SplashContent(),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/images/logo3.png',
        height: 40.h,
        fit: BoxFit.contain,
      ),
    );
  }
}
