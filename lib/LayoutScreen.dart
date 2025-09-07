import './main.dart';
// import './Admin/AdminRegister.dart';
import 'package:flutter/material.dart';
import './Admin/AdminLogin.dart';

class Layoutscreen extends StatelessWidget {
  const Layoutscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          // Width is large (tablet / web) → show Admin Register page
          return const AdminLoginPage();
        } else {
          // Mobile → show splash or other page
          return const SplashScreen();
        }
      },
    );
  }
}
