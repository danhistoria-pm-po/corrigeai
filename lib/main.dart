import 'package:flutter/material.dart';
import 'package:corrige_ai/features/auth/presentation/pages/login_page.dart';
import 'package:corrige_ai/features/home/presentation/pages/home_page.dart';

void main() {
  runApp(const CorrigeAiApp());
}

class CorrigeAiApp extends StatelessWidget {
  const CorrigeAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CorrigeAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}