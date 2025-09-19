import 'package:flutter/material.dart';
import 'capture_page.dart'; // <-- Import the new page we will create

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Image.asset(
            'assets/images/logo.png', // Your main logo
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // This now navigates to your new page!
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CapturePage()),
          );
        },
        backgroundColor: Colors.blue, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        // This now uses your custom cow icon
        child: Padding(
          padding: const EdgeInsets.all(1.0), // Adjust size with padding
          child: Image.asset(
            'assets/images/cow_icon.png',
            // 'color: Colors.white' tints your icon white to match the design
            color: Colors.white, 
          ),
        ),
      ),
    );
  }
}