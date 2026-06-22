import 'dart:async';
import 'package:connect_hub/Pages/HomePage.dart';
import 'package:connect_hub/Pages/StartingPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  // 1. Keep a reference to the timer so we can cancel it if the widget is destroyed
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), () {
      // 2. CRITICAL CHECK: Ensure the screen is still active before navigating
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => (FirebaseAuth.instance.currentUser != null)
              ? HomePage()
              : StartingPage(),
        ),
      );
    });
  }

  @override
  void dispose() {
    // 3. Clean up the timer to prevent memory leaks if the app closes fast
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          // 4. Simplified: You can drop the Column/Expanded and just use a Center widget
          child: Image.asset(
            "assets/Connect Hub Logo without BG.png",
            height: 250,
            width: 300,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
