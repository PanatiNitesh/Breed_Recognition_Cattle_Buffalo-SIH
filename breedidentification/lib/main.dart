import 'package:flutter/material.dart';
import 'home_page.dart'; // <-- Import the new page you just created

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bharat Pashudhan', // You can change this title
      debugShowCheckedModeBanner: false, // This removes the "Debug" banner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(), // <-- This sets your new HomePage as the starting screen
    );
  }
}