// lib/main.dart

import 'package:flutter/material.dart';
import 'views/home_view.dart';

void main() {
  runApp(const FormatifyApp());
}

class FormatifyApp extends StatelessWidget {
  const FormatifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Formatify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeView(),
    );
  }
}