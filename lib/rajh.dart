import 'package:flutter/material.dart';
import 'dart:async'; // for Timer

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  // 🔹 Function to move to next screen after delay
  void navigateToNext() {
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    navigateToNext(); // call function on start
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            SizedBox(height: 300),

            FadeInImage(
              placeholder: AssetImage("assets/img/logo.png"),
              image: AssetImage("assets/img/logo.png"),
              height: 230,
              width: 230,
            ),

            Spacer(),
            Text(
              "Developed By\nCODE WITH DHRUV",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// 🔹 Example Next Screen
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Page")),
      body: const Center(
        child: Text(
          "Welcome to Home Page!",
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
