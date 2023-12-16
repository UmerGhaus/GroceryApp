// splash_screen.dart
import 'package:flutter/material.dart';
import 'main_screen.dart'; // Replace with the actual file name for the main screen

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Add any initializations if needed
    _navigateToMainScreen();
  }

  void _navigateToMainScreen() {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(233, 246, 249, 1.0),
      body: Center(
        // Use the AssetImage widget to load an image from the assets folder
        child: Image.asset(
          'assets/splash_image.png', // Replace with the actual path to your image
          width: 350, // Adjust the width as needed
          height: 450, // Adjust the height as needed
          // You can also use other properties of the Image widget to customize
          // the way the image is displayed, such as fit, alignment, etc.
        ),
      ),
    );
  }
}
